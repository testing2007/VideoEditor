/*
 * audio_convert.cpp
 *
 *  Created on: 2014年7月24日
 *      Author: 尚博才
 */

#include "audio_convert.h"
#include "audio_utils.h"

#include <stdlib.h>

#include "audio_instance_factory.h"

AudioConvert::AudioConvert(char* libname) :
        reader_(NULL), recorder_(NULL),
        audio_frame_buffer_(NULL), encode_frame_buffer_(NULL) {

    reader_ = AudioInstanceFactory::GetAudioReaderInstance(libname);
    recorder_ = AudioInstanceFactory::GetAudioRecorderInstance(libname);

    F_AUDIO_LOG_ASSERT(reader_ != NULL && recorder_ != NULL,
            "reader or recorder can not null, check up libname: %s", libname);
}

AudioConvert::~AudioConvert() {
    // is_stopped = true;
    if (reader_ != NULL) {
        delete reader_;
        reader_ = NULL;
    }
    if (recorder_ != NULL) {
        delete recorder_;
        recorder_ = NULL;
    }
    if (audio_frame_buffer_ != NULL) {
        delete[] audio_frame_buffer_;
        audio_frame_buffer_ = NULL;
    }
    if (encode_frame_buffer_ != NULL) {
        delete encode_frame_buffer_;
        encode_frame_buffer_ = NULL;
    }
}

void AudioConvert::AddAudioEffect(AudioEffect effect) {
    recorder_->SetAudioEffect(effect);
}

void AudioConvert::SetOutPutAudioFormat(int sample_rate,
        FAudioChannelLayout channel_layout, FSampleFormat sample_format,
        int channel_count, int bit_rate) {
    recorder_->SetOutPutAudioFormat(sample_rate, channel_layout, sample_format,
            channel_count, bit_rate);
}

int AudioConvert::Init(const char* in, const char* out) {
    F_AUDIO_LOG_VERBOSE("begin");
    int error;

    if ((error = reader_->InitInputFile(in)) != kNoError)
        return error;

    recorder_->SetInputAudioFormat(reader_->sample_rate(),
            reader_->channel_layout(), reader_->sample_format(),
            reader_->channel_count(), reader_->bit_rate());
    if ((error = recorder_->InitAudioFile(kEncoder, out)) != kNoError)
        return error;
    audio_frame_buffer_ = new unsigned char[reader_->GetBufferSize()];
    if (audio_frame_buffer_ == NULL) {
        F_AUDIO_LOG_ERROR("alloc memory failed");
        return kAllocMemoryError;
    }
    encode_frame_buffer_ = new unsigned char*[reader_->channel_count()];
    for (int i = 0; i < reader_->channel_count(); ++i) {
        encode_frame_buffer_[i] = audio_frame_buffer_
                + i * reader_->GetBufferSize() / reader_->channel_count();
    }
    //is_stopped = false;

    F_AUDIO_LOG_VERBOSE("end");
    return kNoError;
}

int AudioConvert::Convert() {
    F_AUDIO_LOG_VERBOSE("begin");
    int sample_count, is_finished, error;
    for (;;) {
        //     if(is_stopped) break;
        error = reader_->GetFrame((short*) audio_frame_buffer_, sample_count,
                is_finished);
        if (error != kNoError) {
            if (is_finished) {
                recorder_->CloseAudioFile();
                break;
            } else
                return error;
        }
        F_AUDIO_LOG_DEBUG("sample count %d", sample_count);
        error = recorder_->EncodeAudioFrame(encode_frame_buffer_, sample_count);
        if (error != kNoError)
            return error;
    }
    F_AUDIO_LOG_VERBOSE("end");
    return kNoError;
}
