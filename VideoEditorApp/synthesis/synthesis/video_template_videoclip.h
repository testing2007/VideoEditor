/*
 * video_template_videoclip.h
 *
 *  Created on: 2014年9月3日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_VIDEOCLIP_H_
#define VIDEO_TEMPLATE_VIDEOCLIP_H_

#include "video_template_mediaclip.h"
#include "video_template_videoasset.h"

namespace feinnovideotemplate {

class VideoClip: public feinnovideotemplate::MediaClip {
public:
    VideoClip();
    VideoClip(Asset* asset);
    virtual ~VideoClip();

    VideoAsset* asset() {
        return (VideoAsset*)(MediaClip::asset());
    }

    void StartDecode();
    unsigned char* GetNextFrame();

};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_VIDEOCLIP_H_ */
