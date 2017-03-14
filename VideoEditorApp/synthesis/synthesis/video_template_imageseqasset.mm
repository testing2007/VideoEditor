/*
 * video_template_imageseqasset.cpp
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#include "video_template_imageseqasset.h"
#include "video_template_videotemplateutils.h"

namespace feinnovideotemplate {

ImageSeqAsset::ImageSeqAsset():Asset(),attach_size_(0) {
    // TODO Auto-generated constructor stub
    set_asset_type(IMAGE);
}

ImageSeqAsset::~ImageSeqAsset() {
    // TODO Auto-generated destructor stub
    image_uri_list_.clear();
    
    for(list<unsigned char*>::iterator iter = image_list_.begin();iter != image_list_.end();iter++){
        delete [](*iter);
    }
    image_list_.clear();
}

  
    
void ImageSeqAsset::LoadImage() {
    
    for(list<string>::iterator iter = image_uri_list_.begin();iter != image_uri_list_.end();iter++){
        unsigned char* image_buffer = VideoTemplateUtils::GetDataFromImgFile(*iter);
        //toImage(image_buffer);
        image_list_.push_back(image_buffer);
    }

}



} /* namespace feinnovideotemplate */
