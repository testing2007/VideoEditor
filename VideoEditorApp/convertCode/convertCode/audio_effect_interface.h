/*
 * audio_effect_interface.h
 *
 *  Created on: 2014年7月16日
 *      Author: 尚博才
 */

#ifndef AUDIO_EFFECT_INTERFACE_H_
#define AUDIO_EFFECT_INTERFACE_H_

#include <base/f_audio_types.h>

//音效处理
class AudioEffectInterface{
public:

    static const int kNoError             = 0;
    static const int kNoSupportEffect     = -1;


    //初始化
    virtual int InitAudioEffect(int channel_count, int sample_rate, AudioEffect effect)=0;

    //输入PCM数据
    virtual int PutSamples(short *data, int sample_count)=0;

    //取出处理过的PCM，data是输出，max_sample_count是最大输出采样数
    virtual int ReceiveSamples(short* data, int max_sample_count)=0;

    //处理后还未输出的采样数
    virtual int GetRemainedSampleCount()=0;

    virtual ~AudioEffectInterface(){}
};



#endif // AUDIO_EFFECT_INTERFACE_H_ 
