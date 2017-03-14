/*
 * audio_resample_interface.h
 *
 *  Created on: 2014年7月16日
 *      Author: 尚博才
 */

#ifndef AUDIO_RESAMPLE_INTERFACE_H_
#define AUDIO_RESAMPLE_INTERFACE_H_

#include <base/f_audio_types.h>

//声音重采样,外部做缓存保证每次的输入全部处理完输出。

class AudioResampleCallbackIntreface{
public:
	virtual ~AudioResampleCallbackIntreface(){}
	virtual int AudioResampleCallback()=0;
};

class AudioResampleIntreface{

public:
    static const int kNoError                = 0;
    static const int kAllocContextError      = -1;
    static const int kOpenResampleError      = -2;
    static const int kResampleCountError     = -3;

public:
    virtual void SetInputAudioFormat(int sample_rate,
            FAudioChannelLayout channel_layout,
            FSampleFormat sample_format)=0;
    virtual void SetOutputAudioFormat(int sample_rate,
            FAudioChannelLayout channel_layout,
            FSampleFormat sample_format)=0;

    virtual int InitAudioResample(AudioResampleCallbackIntreface* callback)=0;

    virtual int Resample(unsigned char **output,
            int out_plane_size, int out_samples, unsigned char **input,
            int in_plane_size, int in_samples)=0;

    virtual ~AudioResampleIntreface(){}
};



#endif // AUDIO_RESAMPLE_INTERFACE_H_ 
