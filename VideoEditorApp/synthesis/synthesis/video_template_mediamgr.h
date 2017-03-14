/*
 * video_template_mediamgr.h
 *
 *  Created on: 2014年9月3日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_MEDIAMGR_H_
#define VIDEO_TEMPLATE_MEDIAMGR_H_

#include <list>
#include <string>
#include "video_template_audioclip.h"
#include "video_template_tittle.h"

namespace feinnovideotemplate {
using std::string;
using std::list;


class MediaMgr {
public:
    MediaMgr();
    virtual ~MediaMgr();

    static MediaClip* BuildMediaClip(Asset* asset, long offset, long duration);
    static Tittle* CreateTittle(unsigned char* tittleImage, long offset, long duration);
    static AudioClip* CreateAudio(const string& audio_uri, long offset, long duration);
//protected:
    static list<MediaClip*> BuildMediaClip(AssetType assetType,  list<string>& uris);

private:
    static MediaClip* CreateMediaClip(AssetType type, Asset* asset);

};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_MEDIAMGR_H_ */
