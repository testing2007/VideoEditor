/*
 * video_template_mediaclip.h
 *
 *  Created on: 2014年9月1日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_MEDIACLIP_H_
#define VIDEO_TEMPLATE_MEDIACLIP_H_

#include "video_template_types.h"
#include "video_template_asset.h"
#include "video_template_effect.h"

#include <string>

namespace feinnovideotemplate {
using std::string;

/**
 *
 * 视频处理的素材抽象类
 *
 */
class MediaClip {
public:
    MediaClip();
    MediaClip(Asset* asset);
    virtual ~MediaClip();

public:
    // [ ======== 存取方法 ===========
    const std::string& id() const {
        return id_;
    }

    void set_id(const std::string& id) {
        id_ = id;
    }

    virtual Asset* asset()  {
        return asset_;
    }

    void set_asset(Asset* asset) {
        asset_ = asset;
    }

    long duration() const {
        return duration_;
    }

    void set_duration(long duration) {
        duration_ = duration;
    }

    long offset() const {
        return offset_;
    }

    void set_offset(long offset) {
        offset_ = offset;
    }

    bool recycle() const {
        return recycle_;
    }

    void set_recycle(bool recycle) {
        recycle_ = recycle;
    }

    int frame_rate() const {
        return frame_rate_;
    }

    void set_frame_rate(int frame_rate) {
        frame_rate_ = frame_rate;
    }

    const Effect* effect() const {
        return effect_;
    }

    void set_effect(Effect* effect) {
        effect_ = effect;
    }
    // ] ======== 存取方法 ===========

public:
    AssetType GetAssetType() {
        return  asset_->asset_type();
    }

    long GetOutPoint() {
        return offset_ + duration_;
    }

private:

    std::string id_;

    /** 引用资源 */
    Asset* asset_;

    /** 资源长度 */
    long duration_;

    /** 素材入点（精确帧） */
    long offset_;

    // 素材出点（精确帧）

    /** 是否对齐循环 */
    bool recycle_;

    /** 帧率 */
    int frame_rate_;

    Effect* effect_;

};

}; /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_MEDIACLIP_H_ */
