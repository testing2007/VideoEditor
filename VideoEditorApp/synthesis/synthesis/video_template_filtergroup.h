/*
 * video_template_filtergroup.h
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_FILTERGROUP_H_
#define VIDEO_TEMPLATE_FILTERGROUP_H_

#include "video_template_filter.h"
#include <list>

namespace feinnovideotemplate {
using std::list;

class FilterGroup: public feinnovideotemplate::Filter {
public:
    FilterGroup();
    FilterGroup(list<Filter*> filters);
    virtual ~FilterGroup();


    void AddFilter(Filter* filter);
    void AddFilter(Filter* filter, int index);
    unsigned char* ApplyEffect(unsigned char* curFrame, bool isPreview);
    void SetFrameRate(int frameRate);

public: //继承的接口
    void set_frame_rate(int frameRate);
    void set_frame_index(long frameIndex);
    void Close();

public: // 存取方法
    list<Filter*>& filters() {
        return filters_;
    }

private:
    list<Filter*> filters_;
    list<Filter*> temp_filters_;

};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_FILTERGROUP_H_ */
