/*
 * video_template_filterutils.h
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_FILTERUTILS_H_
#define VIDEO_TEMPLATE_FILTERUTILS_H_

#include "video_template_filter.h"

#include "base/ObjcClass.h"
OBJC_CLASS(GPUImageFilter);

namespace feinnovideotemplate {
using std::string;
    
class FilterUtils {
public:

    static Filter* BuildFromXML(const string& id);
    static Filter* BuildFromXML(const string& filterPath, const string& metaName);
    static GPUImageFilter* GenGPUImageFilter( Filter* filter);
    static Filter* BuildWatermarkFilter();
    static Filter* BuildTittleFilter();
    static Filter* BuildDecorateFilter();
    static Filter* BuildBlankFilter();



};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_FILTERUTILS_H_ */
