/*
 * video_template_assetmgr.cpp
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#include "video_template_assetmgr.h"

#include <ctime>

#include "video_template_audioasset.h"
#include "video_template_tittleasset.h"
#include "video_template_imageseqasset.h"
#include "video_template_videoasset.h"


namespace feinnovideotemplate {


AssetMgr::AssetMgr() {
    // TODO Auto-generated constructor stub

}

AssetMgr::~AssetMgr() {
    // TODO Auto-generated destructor stub
}


Asset* AssetMgr::BuildAsset(AssetType assetType, const string& uri) {

    // AssetType assetType = AssetType.valueOf(type);

   return CreateAsset(assetType, uri);

}

Asset* AssetMgr::CreateAsset(AssetType assetType, const string& uri) {

//    time_t now;
//    time(&now);
//    struct tm * timeinfo;
//    timeinfo = localtime(&now);
//    char time_string[64];
//    sprintf(time_string, "%d%d%d%d%d%d", timeinfo->tm_year, timeinfo->tm_mon,
//            timeinfo->tm_mday, timeinfo->tm_hour, timeinfo->tm_min,
//            timeinfo->tm_sec);
////fixme 时间到秒是否够用
//    string id = GetAssetTypeString(assetType).append(time_string);

    //id没有用，空着吧
    string id;
    switch (assetType) {
    case VIDEO:{
        VideoAsset* va = new VideoAsset();
        va->set_uri(uri);
        va->set_id(id);
        return va;
    }
        break;
    case AUDIO:{
        AudioAsset *aa = new AudioAsset();
        aa->set_uri(uri);
        aa->set_id(id);
        return aa;
    }
        break;
    case IMAGE:{
        ImageSeqAsset *ia = new ImageSeqAsset();
        ia->set_uri(uri);
        ia->set_id(id);
        return ia;
    }
    case TITTLE:{
        TittleAsset *ta = new TittleAsset();
        ta->set_uri(uri);
        ta->set_id(id);
        return ta;
    }
    default:{
        //代码错误，不应该执行到此处。
        assert(false);
        //Asset a;
        return NULL;
    }
    }

}

} /* namespace feinnovideotemplate */
