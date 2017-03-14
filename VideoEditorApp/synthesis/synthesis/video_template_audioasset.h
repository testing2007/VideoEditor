/*
 * video_template_audioasset.h
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_AUDIOASSET_H_
#define VIDEO_TEMPLATE_AUDIOASSET_H_

#include "video_template_asset.h"

class IMediaSource;

namespace feinnovideotemplate {

class AudioAsset: public feinnovideotemplate::Asset {
public:
    AudioAsset();
    virtual ~AudioAsset();

public: // 存取方法
    long duration();

    void set_duration(long duration);
    
     void StartDecode();

      void CloseDecode();

     unsigned char* GetNextAudioSamples();

     unsigned char* MixAudio(unsigned char* audio2);

private:
    // 资源长度（帧数）
    long duration_;

    
    IMediaSource *media_source_;
};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_AUDIOASSET_H_ */
