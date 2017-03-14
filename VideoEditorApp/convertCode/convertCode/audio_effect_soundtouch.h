/*
 * audio_effect_soundtouch.h
 *
 *  Created on: 2014年7月21日
 *      Author: 尚博才
 */

#ifndef AUDIO_EFFECT_SOUNDTOUCH_H_
#define AUDIO_EFFECT_SOUNDTOUCH_H_

#include "audio_effect_interface.h"

namespace soundtouch{
class SoundTouch;
}

//soundtouch实现音效,只支持16位采样（soundtouch的采样位数是通过宏指定的，只能在编译时改变）
class AudioEffectSoundtouch : public AudioEffectInterface{
public:
    AudioEffectSoundtouch();
    ~AudioEffectSoundtouch();

    virtual int InitAudioEffect(int channel_count, int sample_rate, AudioEffect effect);

    virtual int PutSamples(short *data, int sample_count);

    virtual int ReceiveSamples(short* data, int max_sample_count);

    virtual int GetRemainedSampleCount();


private:
    int SetEffect(AudioEffect effect);


soundtouch::SoundTouch *soundtouch_;

};



#endif // AUDIO_EFFECT_SOUNDTOUCH_H_ 
