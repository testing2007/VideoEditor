/*
 * video_template_tittleasset.cpp
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#include "video_template_tittleasset.h"

namespace feinnovideotemplate {

TittleAsset::TittleAsset():Asset(),tittle_image_(NULL) {
    set_asset_type(TITTLE);
}

TittleAsset::~TittleAsset() {
    if(tittle_image_ != NULL){
        free(tittle_image_);
        tittle_image_ = 0;
    }
}



} /* namespace feinnovideotemplate */
