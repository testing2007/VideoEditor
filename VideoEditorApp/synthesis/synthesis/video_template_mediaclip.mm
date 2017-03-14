/*
 * video_template_mediaclip.cpp
 *
 *  Created on: 2014年9月1日
 *      Author: 尚博才
 */

#include "video_template_mediaclip.h"
#include <cassert>

namespace feinnovideotemplate {

MediaClip::MediaClip(): recycle_(true),asset_(NULL),effect_(NULL) {

}
MediaClip::MediaClip(Asset* asset) : recycle_(true),asset_(NULL),effect_(NULL) {
    asset_ = asset;
}
MediaClip::~MediaClip() {
    
    if(asset_ != NULL){
        delete asset_;
        asset_ = NULL;
    }
    
    if(effect_ != NULL) {
        delete effect_;
        effect_ = NULL;
    }
}

} /* namespace feinnovideotemplate */
