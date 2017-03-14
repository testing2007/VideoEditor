/*
 * video_template_audioclip.cpp
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#include "video_template_audioclip.h"

namespace feinnovideotemplate {

AudioClip::AudioClip(): MediaClip() {

}
AudioClip::AudioClip(Asset *asset):MediaClip(asset) {

}

AudioClip::~AudioClip() {

}


AudioEffect* AudioClip::effect() {
    return (AudioEffect*) MediaClip::effect();
}

void AudioClip::BuildEffect() {
    // //
    AudioEffect *effect = new AudioEffect();
    set_effect(effect);
}

void AudioClip::ApplyEffect() {
   
    if (effect() == NULL) {
        BuildEffect();
    }
    effect()->ApplyEffect(asset()->uri());
}


void AudioClip::Close() {

    if (effect() != NULL) {
        effect()->Close();
    }
    if (asset() != NULL) {
        asset()->CloseDecode();
    }
}

AudioAsset* AudioClip::asset() {
    return (AudioAsset*) MediaClip::asset();
}

} /* namespace feinnovideotemplate */
