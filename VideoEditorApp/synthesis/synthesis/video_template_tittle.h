/*
 * video_template_tittle.h
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_TITTLE_H_
#define VIDEO_TEMPLATE_TITTLE_H_

#include "video_template_mediaclip.h"
#include "video_template_tittleasset.h"
#include "video_template_filter.h"

namespace feinnovideotemplate {

class Tittle: public feinnovideotemplate::MediaClip {
public:
    Tittle();
    Tittle(Asset* asset);
    virtual ~Tittle();

    TittleAsset* asset();
    Filter* GetFilter();

private:
    Filter* filter_;
    bool is_initialized_;
};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_TITTLE_H_ */
