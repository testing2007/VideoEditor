/*
 * audio_resample_libav.cpp
 *
 *  Created on: 2014年7月17日
 *      Author: 尚博才
 */

#ifndef __CANNOT_USE_LIBAV__

#include "audio_resample_libav.h"
#include "audio_utils.h"

#include <stdlib.h>

extern "C"{
#include <libavresample/avresample.h>
#include <libavutil/opt.h>
}

AudioResampleLibav::AudioResampleLibav():
    audio_resample_context_(NULL),
    in_channel_layout_(kMono),
    in_sample_rate_(44100),
    in_sample_format_(kSampleFmtS16),
    out_channel_layout_(kMono),
    out_sample_rate_(44100),
    out_sample_format_(kSampleFmtS16){

}

AudioResampleLibav::~AudioResampleLibav(){
    if(audio_resample_context_ != NULL){
        avresample_close(audio_resample_context_);
        avresample_free(&audio_resample_context_);
    }
}

    void AudioResampleLibav::SetInputAudioFormat(int sample_rate,
           FAudioChannelLayout channel_layout,
           FSampleFormat sample_format){
    in_sample_rate_ = sample_rate;
        in_channel_layout_ = channel_layout;
        in_sample_format_ = sample_format;
        return ;
    }
    void AudioResampleLibav::SetOutputAudioFormat(int sample_rate,
           FAudioChannelLayout channel_layout,
           FSampleFormat sample_format){
        out_sample_rate_ = sample_rate;
               out_channel_layout_ = channel_layout;
               out_sample_format_ = sample_format;
    }

    int AudioResampleLibav::InitAudioResample(AudioResampleCallbackIntreface* callback){
        F_AUDIO_LOG_VERBOSE("begin");

        resampleCallback_ = callback;

        audio_resample_context_ = avresample_alloc_context();
        if(audio_resample_context_ == NULL){
            F_AUDIO_LOG_ERROR("avresample alloc context failed");
            return kAllocContextError;
        }

        av_opt_set_int(audio_resample_context_, "in_channel_layout",
                AudioUtil::AudioChannelLayout2libav(in_channel_layout_),  0);
        av_opt_set_int(audio_resample_context_, "out_channel_layout",
                AudioUtil::AudioChannelLayout2libav(out_channel_layout_),  0);
        av_opt_set_int(audio_resample_context_, "in_sample_rate",  in_sample_rate_,  0);
        av_opt_set_int(audio_resample_context_, "out_sample_rate", out_sample_rate_, 0);
        av_opt_set_int(audio_resample_context_, "in_sample_fmt",
                AudioUtil::FSampleFormat2libav(in_sample_format_), 0);
        av_opt_set_int(audio_resample_context_, "out_sample_fmt",
                AudioUtil::FSampleFormat2libav(out_sample_format_), 0);
        int error = avresample_open(audio_resample_context_);
        if(error < 0){
            char error_buffer[255];
            av_strerror(error, error_buffer, sizeof(error_buffer));
                 F_AUDIO_LOG_ERROR("Could not get frame buffer (error '%s')\n",
                                         error_buffer);
                 avresample_free(&audio_resample_context_);
                 return kOpenResampleError;
        }
        F_AUDIO_LOG_INFO("in_channel_layout %d,out_channel_layout %d,in_sample_rate %d,"
                "out_sample_rate %d,in_sample_fmt %d,out_sample_fmt %d",
                in_channel_layout_,
                out_channel_layout_,
                in_sample_rate_,
                out_sample_rate_,
                in_sample_format_,
                out_sample_format_);

        F_AUDIO_LOG_VERBOSE("end");
        return kNoError;
    }

int AudioResampleLibav::Resample(uint8_t **output, int out_plane_size,
		int out_samples, uint8_t **input, int in_plane_size, int in_samples) {

	// 重采样，不取出，内部有缓存
	int ret = avresample_convert(audio_resample_context_,
	NULL, 0, 0, input, in_plane_size, in_samples);
	if (ret < 0) {
		F_AUDIO_LOG_ERROR("Error feeding audio data to the resampler\n");
		return kResampleCountError;
	}

	F_AUDIO_LOG_VERBOSE(
			"resample,in_samples %d, out_samples %d, resampled fifo %d",
			in_samples, out_samples,
			avresample_available(audio_resample_context_));

	// 此处用回调更合理，如果保证不多于一次符合条件才能这么做，否则丢数据
	while (avresample_available(audio_resample_context_) >= out_samples) {
		ret = avresample_read(audio_resample_context_, output, out_samples);
		if (ret < 0) {
			F_AUDIO_LOG_ERROR("Error while resampling\n");
			return kResampleCountError;
		}
		ret = resampleCallback_->AudioResampleCallback();
		if(ret != kNoError) return ret;
	}

	//重采样后多余的未输出数据量
	//avresample_available(audio_resample_context_);
	//输入后未重采样的数据量..
	//avresample_get_delay(audio_resample_context_);

	return kNoError;
}

#endif //__CANNOT_USE_LIBAV__
