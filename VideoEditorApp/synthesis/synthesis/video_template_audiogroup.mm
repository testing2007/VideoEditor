/*
 * video_template_audiogroup.cpp
 *
 *  Created on: 2014年9月13日
 *      Author: 尚博才
 */

#include "video_template_audiogroup.h"

namespace feinnovideotemplate {

AudioGroup::AudioGroup() {
    // TODO Auto-generated constructor stub

}

AudioGroup::~AudioGroup() {
    // TODO Auto-generated destructor stub
    
    for( list<AudioClip*>::iterator iter = audio_clips_.begin();iter!= audio_clips_.end(); iter++){
        delete *iter;
    }
    audio_clips_.clear();
}


void AudioGroup::ApplyEffect() {
    AudioClip *audioClip = NULL;
    for (list<AudioClip*>::iterator iterator = audio_clips_.begin(); iterator != audio_clips_.end(); iterator++) {
        audioClip = *iterator;
        if (frame_index_ >= audioClip->offset()) {
            if (audioClip->effect() == NULL) {
                audioClip->ApplyEffect();
                printf("applyAudio:%s", audioClip->asset()->uri().c_str());
            }
        }
        if (frame_index_ >= audioClip->GetOutPoint()) {
            audioClip->Close();
        }
    }
}

void AudioGroup::Close() {
    for (list<AudioClip*>::iterator iterator = audio_clips_.begin(); iterator != audio_clips_.end(); iterator++) {
        (*iterator)->Close();
    }
}


unsigned char* AudioGroup::MixAudio(unsigned char* audioSrc, int size, bool useSrcAudio) {

    if (!useSrcAudio) {
        for (int i = 0; i < size; i++) {
            audioSrc[i] = 0;
        }
    }
    if(audioSrc == NULL){
        Close();
    }

    unsigned char* mixedSamples = audioSrc;
    AudioClip *audioClip = NULL;
    for (list<AudioClip*>::iterator iterator = audio_clips_.begin(); iterator != audio_clips_.end(); iterator++) {
        audioClip = *iterator;
        if (frame_index_ >= audioClip->offset() && frame_index_ < audioClip->GetOutPoint()) {
            mixedSamples = audioClip->asset()->MixAudio(mixedSamples);
            printf( "mixAudio:%s\n", audioClip->asset()->uri().c_str());
        }
    }

    return mixedSamples;
}

} /* namespace feinnovideotemplate */
