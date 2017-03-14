/*
 * video_template_videoasset.h
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_VIDEOASSET_H_
#define VIDEO_TEMPLATE_VIDEOASSET_H_

#include "video_template_asset.h"
#include "Codec/CodecInterface.h"
#include "video_template_audiogroup.h"


namespace feinnovideotemplate {
    
class VideoAsset: public feinnovideotemplate::Asset {
public:
    VideoAsset();
    virtual ~VideoAsset();

    void StartDecode();
    unsigned char* GetNextFrame();
    void CloseDecode();
    void StartEncode();
    void AppendFrame(unsigned char* frame);
    void ColseEncode();


public:
    long cursor() const {
        return cursor_;
    }

    void set_cursor(long cursor = 0) {
        cursor_ = cursor;
    }

    //fixme
    long duration()  {
        if (media_source_ == NULL) {
            StartDecode();
        }
        if(duration_ == -1)
        {
            duration_ = media_source_->info(kMediaFileInfoKeyDuration) * 25 / 1000;
        }
        return duration_;
    }

    void set_duration(long duration) {
        duration_ = duration;
    }

    int height() const {
        return height_;
    }

    void set_height(int height) {
        height_ = height;
    }

    void set_use_src_audio(bool useSrcAudio) {
        use_src_audio_ = useSrcAudio;
    }

    int width() const {
        return width_;
    }

    void set_width(int width) {
        width_ = width;
    }

    
    void set_audio_group(AudioGroup* audioGroup) {
        audio_group_ = audioGroup;
    }

    IMediaTarget* media_Target() const {
        return media_target_;
    }

    void set_media_Target(IMediaTarget* mediaTarget) {
        media_target_ = mediaTarget;
    }

private:

    // 资源长度 （精确到帧）
     long duration_;

    // 资源使用游标，即当前处理的帧序号
     long cursor_ = 0;

     int width_;

     int height_;

     //fixme
     IMediaSource *media_source_;

    IMediaTarget *media_target_;

    // 添加音乐
    AudioGroup *audio_group_;

    // 消除原音
     bool use_src_audio_;

    //
    int audio_buffer_getted_;

};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_VIDEOASSET_H_ */
