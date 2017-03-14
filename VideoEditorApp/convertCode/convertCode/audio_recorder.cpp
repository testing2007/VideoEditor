/*
 * audio_recorder.cpp
 *
 *  Created on: 2014年7月17日
 *      Author: 尚博才
 */

#ifndef __CANNOT_USE_LIBAV__

#include "audio_recorder.h"
#include "audio_utils.h"

#include <stdlib.h>

extern "C"{
#include "libavformat/avformat.h"
#include "libavutil/audio_fifo.h"
#include "libavutil/opt.h"
}

#include "audio_resample_libav.h"
#include "audio_denoise_speex.h"
#include "audio_effect_soundtouch.h"

AudioRecorder::AudioRecorder() :
        audio_resample_(NULL),
        audio_denoise_(NULL),
        audio_effect_(NULL),
        avformat_context_(NULL),
        avcodec_context_(NULL),
        avframe_(NULL),
      //  fifo_frame_size_(0),
        audio_fifo_(NULL),
    //    fifo_frame_data_(NULL),
    //    fifo_frame_data_size_(0),
        fifo_avframe_(NULL){
    output_format_.bit_rate = 64000;
    output_format_.sample_format = kSampleFmtS16;
    output_format_.channel_count = 2;
    output_format_.channel_layout = kStereo;
    output_format_.sample_rate = 44100;
}

AudioRecorder::~AudioRecorder() {
    F_AUDIO_LOG_VERBOSE("begin");
    if (avcodec_context_ != NULL) {
        F_AUDIO_LOG_DEBUG("avcodec context close");
        avcodec_close(avcodec_context_);
        avcodec_context_ = NULL;
    }
    if (avframe_ != NULL) {
        F_AUDIO_LOG_DEBUG("av freep avframe");
        av_frame_free(&avframe_);
    }
    if(fifo_avframe_ != NULL){
        av_frame_free(&fifo_avframe_);
    }
    if (avformat_context_ != NULL) {
        F_AUDIO_LOG_DEBUG("avformat free context ");
        avformat_free_context(avformat_context_);
        avformat_context_ = NULL;
    }
    if(audio_resample_ != NULL){
        F_AUDIO_LOG_DEBUG("delete resample");
        delete audio_resample_;
        audio_resample_ = NULL;
    }
    if(audio_fifo_ != NULL){
        F_AUDIO_LOG_DEBUG("free fifo");
          av_audio_fifo_free(audio_fifo_);
          audio_fifo_ = NULL;
      }
    if(audio_denoise_ != NULL){
        F_AUDIO_LOG_DEBUG("delete denoise");
        delete audio_denoise_;
        audio_denoise_ = NULL;
    }
    if(audio_effect_ != NULL){
        F_AUDIO_LOG_DEBUG("delete effect");
        delete audio_effect_;
        audio_effect_ = NULL;
    }
//    if(fifo_frame_data_ != NULL){
//        F_AUDIO_LOG_DEBUG("delete fifo frame data");
//        F_AUDIO_LOG_VERBOSE("fifo_frame_data_ address %p",fifo_frame_data_);
//        delete []fifo_frame_data_;
//        fifo_frame_data_ = NULL;
//    }
    F_AUDIO_LOG_VERBOSE("end");
}

void AudioRecorder::SetInputAudioFormat(int sample_rate,
        FAudioChannelLayout channel_layout, FSampleFormat sample_format,
        int channel_count, int bit_rate) {
    F_AUDIO_LOG_VERBOSE("begin");
    input_format_.bit_rate = bit_rate;
    input_format_.sample_format = sample_format;
    input_format_.channel_count = channel_count;
    input_format_.channel_layout = channel_layout;
    input_format_.sample_rate = sample_rate;
    F_AUDIO_LOG_VERBOSE("end");
}

void AudioRecorder::SetOutPutAudioFormat(int sample_rate,
        FAudioChannelLayout channel_layout, FSampleFormat sample_format,
        int channel_count, int bit_rate) {
    F_AUDIO_LOG_VERBOSE("begin");
    output_format_.bit_rate = bit_rate;
    output_format_.sample_format = sample_format;
    output_format_.channel_count = channel_count;
    output_format_.channel_layout = channel_layout;
    output_format_.sample_rate = sample_rate;
    F_AUDIO_LOG_VERBOSE("end");
}


void AudioRecorder::SetAudioDenoise(){
    F_AUDIO_LOG_VERBOSE("begin");
audio_denoise_ = new AudioDenoiseSpeex();
F_AUDIO_LOG_VERBOSE("end");
}

void AudioRecorder::SetAudioEffect(AudioEffect audio_effect){
    F_AUDIO_LOG_VERBOSE("begin");
    audio_effect_ = new AudioEffectSoundtouch();
    audio_effect_name_ = audio_effect;
    F_AUDIO_LOG_VERBOSE("end");
}

int AudioRecorder::InitAudioFile(AudioEncoderName codec_name,
        const char* filename) {
    F_AUDIO_LOG_VERBOSE("begin");

    av_register_all();
    int error = OpenOutputAudioFile(codec_name, filename, &avformat_context_,
            &avcodec_context_);
    if (error != kNoError)
        return error;

    error = InitAvframe();
    if (error != kNoError)
        return error;

    //是否需要重采样
    if(input_format_.sample_rate != output_format_.sample_rate
            || input_format_.channel_layout != output_format_.channel_layout
            || input_format_.sample_format != output_format_.sample_format) {
        audio_resample_ = new AudioResampleLibav();
        audio_resample_->SetInputAudioFormat(input_format_.sample_rate,
                input_format_.channel_layout,input_format_.sample_format);
        audio_resample_->SetOutputAudioFormat(output_format_.sample_rate,
                output_format_.channel_layout, output_format_.sample_format);
        error = audio_resample_->InitAudioResample(this);
        if(error != kNoError) return error;
    }

    error = InitAudioFifo();
    if(error != kNoError) return error;

    InitAudioDenoise();
    InitAudioEffect();

    F_AUDIO_LOG_VERBOSE("end");
    return kNoError;
}
//缓存->[降噪]->重采样->[音效]->编码
int AudioRecorder::EncodeAudioFrame(uint8_t **data, int sample_count) {
    F_AUDIO_LOG_VERBOSE("begin");

    int error;

    //缓存
    if ((error = AddFrameToBuffer(data, sample_count)) != kNoError)
        return error;


    while (true) {
        int get_sample_count = 0;
        if ((error = GetFrameFromBuffer(fifo_avframe_->data, get_sample_count))
                      != kNoError)
            return error;
        if (get_sample_count == 0)
            break;

        //从缓存得到合适的帧，继续处理

        //降噪
        Denoise();

        //重采样
        if ((error = Resample()) != kNoError)
            return error;
    };

    F_AUDIO_LOG_VERBOSE("end");
    return kNoError;
}

int AudioRecorder::CloseAudioFile() {
    F_AUDIO_LOG_VERBOSE("begin");

    int error = av_write_trailer(avformat_context_);
    if(error < 0){
        char error_buffer[255];
        av_strerror(error, error_buffer, sizeof(error_buffer));
        F_AUDIO_LOG_ERROR("write trailer of output file %s error: %s",
                avformat_context_->filename, error_buffer);
        return kWriteFileTrailerError;
    }

    F_AUDIO_LOG_VERBOSE("end");
    return kNoError;
}

//音效 -》 编码
int AudioRecorder::AudioResampleCallback(){

	int error;
    //音效
    if (audio_effect_ != NULL) {
    	F_AUDIO_LOG_VERBOSE("Add Audio effect");
        audio_effect_->PutSamples((short*) avframe_->data[0],
                avframe_->nb_samples);
        while (audio_effect_->GetRemainedSampleCount()
                >= avframe_->nb_samples) {
            audio_effect_->ReceiveSamples((short*) avframe_->data[0],
                    avframe_->nb_samples);
            //编码
            if ((error = Encode()) != kNoError)
                return error;
        }
    } else {
        if ((error = Encode()) != kNoError)
            return error;
    }
    return kNoError;
}

int AudioRecorder::OpenOutputAudioFile(AudioEncoderName codec_name,
        const char *filename, AVFormatContext **fmt_ctx,
        AVCodecContext **codec_ctx) {
    AVIOContext *avio = NULL;
    AVStream *stream = NULL;
    AVCodec *acodec = NULL;
    int error;
    if ((error = avio_open(&avio, filename, AVIO_FLAG_WRITE)) < 0) {
        char error_buffer[255];
        av_strerror(error, error_buffer, sizeof(error_buffer));
        F_AUDIO_LOG_ERROR("could not open output file %s err %s", filename,
                error_buffer);
        return kCannotOpenOutputFile;
    }
    *fmt_ctx = avformat_alloc_context();
    if (*fmt_ctx == NULL) {
        F_AUDIO_LOG_ERROR("could not alloc avformat context");
        avio_closep(&avio);
        return KAllocAvformatError;
    }
    (*fmt_ctx)->pb = avio;

    if (((*fmt_ctx)->oformat = av_guess_format(NULL, filename, NULL)) == NULL) {
        F_AUDIO_LOG_ERROR("Could not find output file format");
        avio_closep(&avio);
        avformat_free_context(*fmt_ctx);
        *fmt_ctx = NULL;
        return kNotSupportFormatOfOutputFile;
    }

    strcpy((*fmt_ctx)->filename, filename);

    char codec_name_string[32];
    AudioUtil::AudioEncoderName2String(codec_name, codec_name_string);
    if ((acodec = avcodec_find_encoder_by_name(codec_name_string)) == NULL) {
        F_AUDIO_LOG_ERROR("Could not find encoder(%s)", codec_name_string);
        avio_closep(&avio);
        avformat_free_context(*fmt_ctx);
        *fmt_ctx = NULL;
        return kNotFoundEncoder;
    }
    stream = avformat_new_stream(*fmt_ctx, acodec);
    if (stream == NULL) {
        F_AUDIO_LOG_ERROR("Could not alloc new Stream");
        avio_closep(&avio);
        avformat_free_context(*fmt_ctx);
        *fmt_ctx = NULL;
        return kAllocStreamError;
    }
    *codec_ctx = stream->codec;
    (*codec_ctx)->channels = output_format_.channel_count;
    (*codec_ctx)->channel_layout = AudioUtil::AudioChannelLayout2libav(
            output_format_.channel_layout);
    (*codec_ctx)->sample_fmt = (AVSampleFormat) AudioUtil::FSampleFormat2libav(
            output_format_.sample_format);
    (*codec_ctx)->bit_rate = output_format_.bit_rate;
    (*codec_ctx)->sample_rate = output_format_.sample_rate;
    (*codec_ctx)->time_base.num = 1;
    (*codec_ctx)->time_base.den = (*codec_ctx)->sample_rate;

    if ((*fmt_ctx)->oformat->flags & AVFMT_GLOBALHEADER)
        (*codec_ctx)->flags |= CODEC_FLAG_GLOBAL_HEADER;

    if ((error = avcodec_open2(*codec_ctx, acodec, NULL)) < 0) {
        char error_buffer[255];
        av_strerror(error, error_buffer, sizeof(error_buffer));
        F_AUDIO_LOG_ERROR("Could not open avcodec (error:%s)", error_buffer);
        avio_closep(&avio);
        avformat_free_context(*fmt_ctx);
        *fmt_ctx = NULL;
        return kAllocStreamError;
    }
    F_AUDIO_LOG_INFO("file %s:sample rate %d,channel count %d,sample format %d(ff),bitrate %d,layout %lld(ff),isplanar %d",
            filename,(*codec_ctx)->sample_rate,(*codec_ctx)->channels,
            (*codec_ctx)->sample_fmt, (*codec_ctx)->bit_rate,(*codec_ctx)->channel_layout,
            av_sample_fmt_is_planar((AVSampleFormat)
                        AudioUtil::FSampleFormat2libav(input_format_.sample_format)));

    if ((error = avformat_write_header(*fmt_ctx, NULL)) < 0) {
        char error_buffer[255];
        av_strerror(error, error_buffer, sizeof(error_buffer));
        F_AUDIO_LOG_ERROR("write file header error:%s", error_buffer);
        avio_closep(&avio);
        avcodec_close(*codec_ctx);
        *codec_ctx = NULL;
        avformat_free_context(*fmt_ctx);
        *fmt_ctx = NULL;
        return kWriteFileHeaderError;
    }
    return kNoError;
}

int AudioRecorder::InitAvframe() {
    int error;
    avframe_ = av_frame_alloc();
    if (avframe_ == NULL) {
        F_AUDIO_LOG_ERROR("avframe alloc failed");
        avcodec_close(avcodec_context_);
        av_freep(&avcodec_context_);
        return kFrameAllocError;
    }
    avframe_->nb_samples = avcodec_context_->frame_size;
    avframe_->format = avcodec_context_->sample_fmt;
    avframe_->channel_layout = avcodec_context_->channel_layout;

    error = av_frame_get_buffer(avframe_, 0);
    if (error < 0) {
        char error_buffer[255];
        av_strerror(error, error_buffer, sizeof(error_buffer));
        F_AUDIO_LOG_ERROR("Could not get frame buffer (error '%s')\n",
                error_buffer);
        av_frame_free(&avframe_);
        avcodec_close(avcodec_context_);
        av_freep(&avcodec_context_);
        return kAvframeGetbufferError;
    }

    return kNoError;
}

int AudioRecorder::Encode() {

    AVPacket pkt;
    int error;
    av_init_packet(&pkt);
    int got = 0;
    pkt.size = 0;
    pkt.data = NULL;

    if ((error = avcodec_encode_audio2(avcodec_context_, &pkt, avframe_, &got))
            < 0) {
        char error_buffer[255];
        av_strerror(error, error_buffer, sizeof(error_buffer));
        F_AUDIO_LOG_ERROR("encode audio error:%s)", error_buffer);
        return kAudioEncodeError;
    }

    if (got && pkt.size > 0) {
        error = av_interleaved_write_frame(avformat_context_, &pkt);
        av_free_packet(&pkt);
        if(error < 0){
            char error_buffer[255];
            av_strerror(error, error_buffer, sizeof(error_buffer));
            F_AUDIO_LOG_ERROR("write audio frame to file error:%s)", error_buffer);
            return kWriteFrameError;
        }
    }

    return kNoError;
}

int AudioRecorder::InitAudioFifo(){

// 使重采样后的数据量等于编码需要的数据量，不可行
//   int fifo_frame_size = avcodec_context_->frame_size *
//            input_format_.sample_rate / output_format_.sample_rate;

	int fifo_frame_size;
	// 采样率不一样时，一次处理20毫秒的数据量
	if(input_format_.sample_rate != output_format_.sample_rate){
		fifo_frame_size = 20 * input_format_.sample_rate / 1000;
	} else {
		fifo_frame_size = avcodec_context_->frame_size;
	}
    audio_fifo_ = av_audio_fifo_alloc(
            (AVSampleFormat)AudioUtil::FSampleFormat2libav(input_format_.sample_format),
            input_format_.channel_count,1);
    if(audio_fifo_ == NULL){
        F_AUDIO_LOG_ERROR("audio fifo alloc error");
        return kFifoAllocError;
    }

    fifo_avframe_ = av_frame_alloc();
    if (avframe_ == NULL) {
           F_AUDIO_LOG_ERROR("fifo avframe alloc failed");
           return kFrameAllocError;
       }
    fifo_avframe_->nb_samples = fifo_frame_size;
    fifo_avframe_->format = AudioUtil::FSampleFormat2libav( input_format_.sample_format);
    fifo_avframe_->channel_layout = AudioUtil::AudioChannelLayout2libav(input_format_.channel_layout);

       F_AUDIO_LOG_VERBOSE("fifo_avframe_ nb_samples %d format %d channel_layout %d",
               fifo_avframe_->nb_samples, fifo_avframe_->format,fifo_avframe_->channel_layout);

      int error = av_frame_get_buffer(fifo_avframe_, 0);
       if (error < 0) {
           char error_buffer[255];
           av_strerror(error, error_buffer, sizeof(error_buffer));
           F_AUDIO_LOG_ERROR("Could not get fifo frame buffer (error '%s')\n",
                   error_buffer);
           av_frame_free(&avframe_);
           return kAvframeGetbufferError;
       }

    return kNoError;
}

int AudioRecorder::AddFrameToBuffer(uint8_t **data,
        const int frame_size){
    F_AUDIO_LOG_VERBOSE("add to audio fifo ");
    int error;
       if ((error = av_audio_fifo_realloc(audio_fifo_,
               av_audio_fifo_size(audio_fifo_) + frame_size)) < 0) {
           char error_buffer[255];
                 av_strerror(error, error_buffer, sizeof(error_buffer));
                 F_AUDIO_LOG_ERROR("could not reallocate FIFO error: %s",  error_buffer);
                 return kCannotReallocateFifo;
       }
       if ((error = av_audio_fifo_write(audio_fifo_, (void **)data,
                               frame_size)) < frame_size) {
           char error_buffer[255];
                            av_strerror(error, error_buffer, sizeof(error_buffer));
                            F_AUDIO_LOG_ERROR("could not write data to FIFO error: %s",  error_buffer);
           return kCannotWriteFifo;
       }
    return kNoError;
}

int AudioRecorder::GetFrameFromBuffer(uint8_t **data, int& sample_count) {
    if (av_audio_fifo_size(audio_fifo_) >= fifo_avframe_->nb_samples ) {
         if ((sample_count = av_audio_fifo_read(audio_fifo_, (void**) data,
                fifo_avframe_->nb_samples)) < fifo_avframe_->nb_samples) {
            F_AUDIO_LOG_VERBOSE("av_audio_fifo_read error");
            char error_buffer[255];
            av_strerror(sample_count, error_buffer, sizeof(error_buffer));
            F_AUDIO_LOG_ERROR("could not read data from FIFO error: %s",
                    error_buffer);
            return kCannotReadFifo;
        }
    } else {
        sample_count = 0;
    }
    return kNoError;
}

//int  AudioRecorder::GetFifoFrameDataSize(){
//    int sample_in_byte = 0;
//    switch(input_format_.sample_format){
//    case kSampleFmtU8:
//    case kSampleFmtU8p:
//        sample_in_byte = 1;
//        break;
//    case kSampleFmtS16:
//    case kSampleFmtS16p:
//        sample_in_byte = 2;
//        break;
//    case kSampleFmtS32:
//    case kSampleFmtS32p:
//    case kSampleFmtFlt:
//    case kSampleFmtFltp:
//            sample_in_byte = 4;
//            break;
//    case kSampleFmtDbl:
//    case kSampleFmtDblp:
//        sample_in_byte = 8;
//        break;
//    default:
//        F_AUDIO_LOG_ASSERT(sample_in_byte != 0,"unkown channel layout");
//        break;
//    }
//   return fifo_frame_size_ * input_format_.channel_count * sample_in_byte;
//}

int AudioRecorder::Resample(){
    F_AUDIO_LOG_ASSERT(audio_resample_ != NULL,"audio_resample_ can not NULL");
    F_AUDIO_LOG_VERBOSE("audio Resample");
    int error = audio_resample_->Resample(
            avframe_->data,avframe_->linesize[0],avframe_->nb_samples,
            fifo_avframe_->data,fifo_avframe_->linesize[0],fifo_avframe_->nb_samples);

    if(error != kNoError) return error;
    return kNoError;
}
void AudioRecorder::InitAudioDenoise(){
    if(audio_denoise_ != NULL){
        audio_denoise_->Init(/*fifo_frame_size_*/fifo_avframe_->nb_samples, input_format_.sample_rate, input_format_.channel_count);
    }
}
void AudioRecorder::InitAudioEffect() {
    if(audio_effect_ != NULL) {
        int error = audio_effect_->InitAudioEffect(output_format_.channel_count,
                output_format_.sample_rate,audio_effect_name_);
        if(error != kNoError){
            delete audio_effect_;
            audio_effect_ = NULL;
        }
    }
}
int AudioRecorder::Denoise(){
    if(audio_denoise_ == NULL) return kNoError;
    audio_denoise_->Denoise((short*)fifo_avframe_->data[0]);
    return kNoError;
}

#endif // __CANNOT_USE_LIBAV__
