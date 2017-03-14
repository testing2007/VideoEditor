/*
 * video_template_mediamgr.cpp
 *
 *  Created on: 2014年9月3日
 *      Author: 尚博才
 */

#include "video_template_mediamgr.h"
#include "video_template_assetmgr.h"
#include "video_template_videoclip.h"
#include "video_template_tittleasset.h"
#include "video_template_tittle.h"
#include "video_template_imageseqclip.h"

namespace feinnovideotemplate {

MediaMgr::MediaMgr() {
    // TODO Auto-generated constructor stub

}

MediaMgr::~MediaMgr() {
    // TODO Auto-generated destructor stub
}



// 构造没有裁剪的视频素材对象
list<MediaClip*> MediaMgr::BuildMediaClip(AssetType assetType,  list<string>& uris) {
    list<MediaClip*> mediaClips;
    for (list<string>::iterator uri = uris.begin(); uri != uris.end(); uri++) {
        VideoAsset *videoAsset = (VideoAsset*) AssetMgr::BuildAsset(assetType, uri->c_str());
        mediaClips.push_back(BuildMediaClip(videoAsset, 0, videoAsset->duration()));
    }
    //
    //
    return mediaClips;
}

// 从资源裁剪得到素材
 MediaClip* MediaMgr::BuildMediaClip(Asset* asset, long offset, long duration) {

    MediaClip *mediaClip = CreateMediaClip(asset->asset_type(), asset);

    mediaClip->set_offset(offset);
    mediaClip->set_duration(duration);

    return mediaClip;
}

MediaClip* MediaMgr::CreateMediaClip(AssetType type, Asset* asset) {


    time_t now;
    time(&now);
    struct tm * timeinfo;
    timeinfo = localtime(&now);
    char time_string[64];
    sprintf(time_string, "%d%d%d%d%d%d", timeinfo->tm_year, timeinfo->tm_mon,
            timeinfo->tm_mday, timeinfo->tm_hour, timeinfo->tm_min,
            timeinfo->tm_sec);
//fixme 时间到秒是否够用
    string id = GetAssetTypeString(type).append(time_string);


    switch (type) {
    case VIDEO:{
       VideoClip *vc = new VideoClip();
       vc->set_asset(asset);
       vc->set_id(id);
       return vc;
    }
    case IMAGE:{
       ImageSeqClip *ic = new ImageSeqClip();
       ic->set_asset(asset);
       ic->set_id(id);
       return ic;
    }
    case AUDIO:{
       AudioClip *ac = new AudioClip();
       ac->set_asset(asset);
        ac->set_id(id);
        return ac;
    }
    case TITTLE:{
        Tittle *tc = new Tittle;
       tc->set_asset(asset);
        tc->set_id(id);
        return tc;
    }
    default:
       break;
    }

    assert(false);
    //不会执行到，为Objc编译能过
    //MediaClip mc;
    return NULL;

}

/**
 * 获得字幕素材包装对象
 * @param tittleImage 字幕转成的iamge
 * @param offset 入点（帧序号）
 * @param duration 时长（持续帧数）
 * @return
 */
Tittle* MediaMgr::CreateTittle(unsigned char* tittleImage, long offset, long duration) {
    TittleAsset* tittleAsset = (TittleAsset*)(AssetMgr::BuildAsset( TITTLE, ""));
    //
    tittleAsset->set_tittle_image(tittleImage);

    Tittle *tittle = (Tittle*)(BuildMediaClip(tittleAsset, offset, duration));

    return tittle;
}

/**
 * 获得音频素材包装对象
 * @param audioUri 音频文件uri
 * @param offset 入点（帧序号）
 * @param duration 时长（持续帧数）
 * @return
 */
 AudioClip* MediaMgr::CreateAudio(const string& audio_uri, long offset, long duration) {

    Asset *asset = AssetMgr::BuildAsset(AUDIO, audio_uri);

    AudioClip *audio = (AudioClip*)BuildMediaClip(asset, offset, duration);

    return audio;
}

} /* namespace feinnovideotemplate */
