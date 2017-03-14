/*
 * video_template_audioclip.h
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_AUDIOCLIP_H_
#define VIDEO_TEMPLATE_AUDIOCLIP_H_

#include "video_template_mediaclip.h"
#include "video_template_audioeffect.h"
#include "video_template_audioasset.h"

namespace feinnovideotemplate {

class AudioClip: public feinnovideotemplate::MediaClip {
public:
    AudioClip();
    AudioClip(Asset* asset);
    virtual ~AudioClip();


   AudioEffect* effect();

    void ApplyEffect();


    void Close();

   AudioAsset* asset();
private:

   void BuildEffect();

};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_AUDIOCLIP_H_ */
