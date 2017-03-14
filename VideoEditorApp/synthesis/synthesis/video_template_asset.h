/*
 * video_template_asset.h
 *
 *  Created on: 2014年9月1日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_ASSET_H_
#define VIDEO_TEMPLATE_ASSET_H_


#include "video_template_types.h"
#include <string>

namespace feinnovideotemplate {
using std::string;

class Asset {
public:
    Asset();
    virtual ~Asset();

public:
    // [ ====== 存取方法 ==========

    const string& id() const {
        return id_;
    }
    void set_id(const string& id) {
        id_ = id;
    }

    const AssetType asset_type() const {
        return asset_type_;
    }

    void set_asset_type(AssetType assetType) {
        asset_type_ = assetType;
    }

    const string& uri() const {
        return uri_;
    }

    void set_uri(const string& uri) {
        uri_ = uri;
    }
    // ] ====== 存取方法 ==========

private:
    string id_;

    // 资源类型
    AssetType asset_type_;

    //
    string uri_;

};



} // namespace feinnovideotemplate

#endif /* VIDEO_TEMPLATE_ASSET_H_ */
