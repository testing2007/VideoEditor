/*
 * video_template_tittle.cpp
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#include "video_template_tittle.h"
#include "video_template_filterutils.h"

namespace feinnovideotemplate {

    Tittle::Tittle():filter_(NULL) {

}
Tittle::Tittle(Asset* asset)
    : feinnovideotemplate::MediaClip(asset),filter_(NULL){

}

Tittle::~Tittle() {
    if(filter_ != NULL){
        delete filter_;
        filter_ = NULL;
    }
}

TittleAsset* Tittle::asset() {
    return (TittleAsset*)asset();
}

Filter* Tittle::GetFilter() {
    if(filter_ == NULL){
        filter_ = FilterUtils::BuildTittleFilter();
        //fixme
        unsigned char* bitmap = asset()->tittle_image();
        filter_->set_attach_image(bitmap);
        filter_->set_offset(offset());
        filter_->set_duration(duration());

    }
    return filter_;
}

} /* namespace feinnovideotemplate */
