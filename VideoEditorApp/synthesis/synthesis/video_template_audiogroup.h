/*
 * video_template_audiogroup.h
 *
 *  Created on: 2014年9月13日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_AUDIOGROUP_H_
#define VIDEO_TEMPLATE_AUDIOGROUP_H_

#include "video_template_audioclip.h"

#include <list>

namespace feinnovideotemplate {
using std::list;

class AudioGroup: public feinnovideotemplate::AudioClip {
public:
    AudioGroup();
    virtual ~AudioGroup();

    void AddAudio(AudioClip* audioClip) {
        audio_clips_.push_back(audioClip);
    }

    void set_frame_index(long frameIndex) {
        frame_index_ = frameIndex;
    }

    void ApplyEffect();
    void Close();
    unsigned char* MixAudio(unsigned char* audioSrc, int size, bool useSrcAudio);

private:
    list<AudioClip*> audio_clips_;

    long frame_index_;

};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_AUDIOGROUP_H_ */
