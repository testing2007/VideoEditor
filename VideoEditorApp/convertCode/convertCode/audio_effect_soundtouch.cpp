/*
 * audio_effect_soundtouch.cpp
 *
 *  Created on: 2014年7月21日
 *      Author: 尚博才
 */

#include "audio_effect_soundtouch.h"

#include <stdlib.h>

#include "soundtouch/SoundTouch.h"

#include "audio_utils.h"

    AudioEffectSoundtouch::AudioEffectSoundtouch() :
        soundtouch_(NULL){

    }
    AudioEffectSoundtouch::~AudioEffectSoundtouch(){
        if(soundtouch_ != NULL){
            delete soundtouch_;
            soundtouch_ = NULL;
        }
    }

int AudioEffectSoundtouch::InitAudioEffect(int channel_count,
        int sample_rate, AudioEffect effect){
    soundtouch_ = new soundtouch::SoundTouch();
    soundtouch_->setChannels(channel_count);
    soundtouch_->setSampleRate(sample_rate);

    F_AUDIO_LOG_INFO("channel count %d sample rate %d", channel_count, sample_rate);

    return SetEffect(effect);
}

int AudioEffectSoundtouch::PutSamples(short *data, int sample_count){

    soundtouch_->putSamples(data, sample_count);

    return kNoError;
}

 int AudioEffectSoundtouch::ReceiveSamples(short* data, int max_sample_count){
     return soundtouch_->receiveSamples(data,max_sample_count);
 }

  int AudioEffectSoundtouch::GetRemainedSampleCount(){

      return soundtouch_->numSamples();
 }


 int AudioEffectSoundtouch::SetEffect(AudioEffect effect){
     int ret_val = kNoError;
     bool is_speech = true;
     switch(effect){
     case kMale:
         soundtouch_->setPitchSemiTones(-4);
         break;
     case kFemale:
         soundtouch_->setPitchSemiTones(4);
         break;
     case kLabixiaoxin:
         soundtouch_->setPitchSemiTones(12);
         break;
     default:
         ret_val = kNoSupportEffect;
         is_speech = false;
         break;
     }

     if(is_speech){
         // use settings for speech processing
         soundtouch_->setSetting(SETTING_SEQUENCE_MS, 40);
         soundtouch_->setSetting(SETTING_SEEKWINDOW_MS, 15);
         soundtouch_->setSetting(SETTING_OVERLAP_MS, 8);
     }

     return ret_val;
  }

