/*
 * video_template_assetmgr.h
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_ASSETMGR_H_
#define VIDEO_TEMPLATE_ASSETMGR_H_

#include <string>

#include "video_template_asset.h"

namespace feinnovideotemplate {
using std::string;


class AssetMgr {
private:
    AssetMgr();
    virtual ~AssetMgr();
public:
    static Asset* BuildAsset(AssetType assetType, const string& uri);

private:
    static Asset* CreateAsset(AssetType assetType, const string& uri);

};


} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_ASSETMGR_H_ */
