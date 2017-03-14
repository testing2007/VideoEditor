/*
 * audio_reader.cpp
 *
 *  Created on: 2014年7月22日
 *      Author: 尚博才
 */

#ifndef __CANNOT_USE_LIBAV__

#include "audio_reader.h"
#include "audio_utils.h"
#include "audio_resample_libav.h"

#include <stdlib.h>

extern "C" {
#include "libavformat/avformat.h"
#include "libavcodec/avcodec.h"
}

AudioReader::AudioReader() :
        state_(0), stream_index_(-1), avcodec_context_(NULL), avformat_context_(NULL), avframe_(
                NULL), channel_count_(0), bit_rate_(-1), channel_layout_(kMono), sample_format_(
                kSampleFmtS16), sample_rate_(-1), buffer_size_(0) {
}

AudioReader::~AudioReader() {
    F_AUDIO_LOG_VERBOSE("begin");
    if (avformat_context_ != NULL) {
        avformat_close_input(&avformat_context_);
    }
    if (avframe_ != NULL) {
        av_freep(&avframe_);
    }
    F_AUDIO_LOG_VERBOSE("end");
}

int AudioReader::InitInputFile(const char* file_name) {
    F_AUDIO_LOG_VERBOSE("begin");
    int error;

    av_register_all();

    error = OpenInputAudioFile(file_name, &avformat_context_, &avcodec_context_, stream_index_);
    if(error != kNoError) return error;

    is_planar_ = av_sample_fmt_is_planar(avcodec_context_->sample_fmt);
    sample_rate_ = avcodec_context_->sample_rate;
    sample_format_ = AudioUtil::libav2FSampleFormat(avcodec_context_->sample_fmt);
    bit_rate_ = avcodec_context_->bit_rate;
    channel_count_ = avcodec_context_->channels;
    channel_layout_ = AudioUtil::libav2AudioChannelLayout(avcodec_context_->channel_layout);
    buffer_size_ = av_samples_get_buffer_size(NULL, avcodec_context_->channels,
            avcodec_context_->frame_size, avcodec_context_->sample_fmt, 0);

    F_AUDIO_LOG_INFO("file %s:sample rate %d,frame size %d, format %d,bitrate %d, channel count %d,channel layout %d,buffer size %d,codec %s",
           file_name, sample_rate_,avcodec_context_->frame_size, sample_format_,bit_rate_,channel_count_,channel_layout_,buffer_size_,avcodec_context_->codec->name);

    if(buffer_size_ <= 0)
    	buffer_size_ = kMaxAudioBufferSize;
    avframe_ = av_frame_alloc();
    if (avframe_ == NULL) {
        F_AUDIO_LOG_ERROR("av frame alloc failed");
        return kAvframeMallocError;
    }
    F_AUDIO_LOG_VERBOSE("end");
    return error;
}

int AudioReader::GetFrame(short* data, int& sample_count, int &is_finished) {
    F_AUDIO_LOG_VERBOSE("begin");

    int error;
    error = DecodeAudioFrame(avframe_, avformat_context_, avcodec_context_, stream_index_,
            &sample_count, &is_finished);
    if(error != kNoError) return error;
    if(sample_count > 0) {
        int data_size = av_samples_get_buffer_size(avframe_->linesize,
              avcodec_context_->channels,avframe_->nb_samples,avcodec_context_->sample_fmt,0);
        F_AUDIO_LOG_ASSERT(avframe_->data != NULL && avframe_->data[0] != NULL,
                "avframe data can not null,avframe_->data %p,data_size %d",avframe_->data,data_size);
        if(is_planar_){
            for(int i = 0; i < channel_count_; ++i){
                memcpy(((unsigned char*)data)+i*(buffer_size_/channel_count_),avframe_->data[i], data_size/channel_count_);
            }
        }else{
            memcpy(data,avframe_->data[0],data_size);
        }
        F_AUDIO_LOG_VERBOSE("DecodeAudioFrame data_size %d format %d sample_count %d isplanar %d",
                data_size, avframe_->format,sample_count,is_planar_);
    }
    F_AUDIO_LOG_VERBOSE("end");
    return kNoError;
}

int AudioReader::CloseInputFile() {
    F_AUDIO_LOG_VERBOSE("begin");
    if (avformat_context_ != NULL) {
        avformat_close_input(&avformat_context_);
    }

    F_AUDIO_LOG_VERBOSE("end");
    return kNoError;
}

//FIXME 找到第一路音频解码，是否需考虑多路
int AudioReader::OpenInputAudioFile(const char* filename, AVFormatContext ** fmt_ctx,
        AVCodecContext **av_ctx, int& stream_index) {

    int error;
    if ((error = avformat_open_input(fmt_ctx, filename, NULL, NULL)) < 0) {
        char error_buffer[255];
        av_strerror(error, error_buffer, sizeof(error_buffer));
        F_AUDIO_LOG_ERROR("Could not open source file %s (error:%s)", filename, error_buffer);
        return kCannotOpenInputFile;
    }

    AVFormatContext *fmt = *fmt_ctx;
    if ((error = avformat_find_stream_info(fmt, NULL)) < 0) {
        char error_buffer[255];
        av_strerror(error, error_buffer, sizeof(error_buffer));
        F_AUDIO_LOG_ERROR("Could not find stream information in file %s (error:%s)", filename,
                error_buffer);
        return kNotFindStream;
    }
    if (fmt->nb_streams < 1) {
        F_AUDIO_LOG_ERROR("no stream");
        return kNotFindStream;
    }

    int i = 0;
    for (; i < fmt->nb_streams; i++) {
        if (fmt->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO) {
            int error = 0;
            AVCodec *codec;
            if ((codec = avcodec_find_decoder(fmt->streams[i]->codec->codec_id)) == NULL) {
                F_AUDIO_LOG_ERROR("Could not find input codec %s",
                        AvcodecGetName(fmt->streams[i]->codec->codec_id));
                avformat_close_input(&fmt);
                return kNotFindCodec;
            }

            if ((error = avcodec_open2(fmt->streams[i]->codec, codec, NULL)) < 0) {
                char error_buffer[255];
                av_strerror(error, error_buffer, sizeof(error_buffer));
                F_AUDIO_LOG_ERROR("Could not open input codec (error:%s)", error_buffer);
                avformat_close_input(&fmt);
                return kCannotOpenCodec;
            }
            *av_ctx = fmt->streams[i]->codec;
            stream_index = i;
            return kNoError;
        }
    }
    F_AUDIO_LOG_ERROR("Could not find audio stream.");
    return kNotFindAudioStream;
}

int AudioReader::DecodeAudioFrame(AVFrame *frame, AVFormatContext *fmtctx, AVCodecContext *avctx,
        int stream_index, int *datapresent, int *finished) {

    AVPacket pkt;
    int error;
    av_init_packet(&pkt);
    pkt.size = 0;
    pkt.data = NULL;

    *datapresent = 0;
    *finished = 0;

    while (true) {
        if ((error = av_read_frame(fmtctx, &pkt)) < 0) {
            if (error == AVERROR_EOF) {
                *finished = 1;
            } else {
                char error_buffer[255];
                av_strerror(error, error_buffer, sizeof(error_buffer));
                F_AUDIO_LOG_ERROR("Could not read frame (error:%s)", error_buffer);

                av_free_packet(&pkt);
                return kReadFrameError;
            }
        }
        if (pkt.stream_index == stream_index)
            break;
        av_free_packet(&pkt);
    }
    // LOGD("start decode a frame");
    if ((error = avcodec_decode_audio4(avctx, frame, datapresent, &pkt)) < 0) {
        char error_buffer[255];
        av_strerror(error, error_buffer, sizeof(error_buffer));
        F_AUDIO_LOG_ERROR("Could not decode frame (error:%s)", error_buffer);
        av_free_packet(&pkt);
        return kDecodeFrameError;
    }
    if (*finished && *datapresent)
        *finished = 0;
    if (*finished) {
        F_AUDIO_LOG_DEBUG("File end");
        return kFileEnd;
    }
    *datapresent = frame->nb_samples;
    return kNoError;
}

const char *AudioReader::AvcodecGetName(int id) {
    const AVCodecDescriptor *cd;
    AVCodec *codec;

    if (id == AV_CODEC_ID_NONE)
        return "none";
    cd = avcodec_descriptor_get((AVCodecID) id);
    if (cd)
        return cd->name;
    av_log(NULL, AV_LOG_WARNING, "Codec 0x%x is not in the full list.\n", id);
    codec = avcodec_find_decoder((AVCodecID) id);
    if (codec)
        return codec->name;
    codec = avcodec_find_encoder((AVCodecID) id);
    if (codec)
        return codec->name;
    return "unknown_codec";
}

#endif // __CANNOT_USE_LIBAV__
