/*
 * video_template_tittleasset.h
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_TITTLEASSET_H_
#define VIDEO_TEMPLATE_TITTLEASSET_H_

#include "video_template_asset.h"

namespace feinnovideotemplate {

class TittleAsset: public feinnovideotemplate::Asset {
public:
    TittleAsset();
    virtual ~TittleAsset();

    unsigned char* tittle_image()  {
        return tittle_image_;
    }
    void set_tittle_image(unsigned char* tittleImage){
        tittle_image_ = tittleImage;
    }

private:
    unsigned char* tittle_image_;


};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_TITTLEASSET_H_ */
