/*
 * video_template_filtergroup.cpp
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#include "video_template_filtergroup.h"
#include "video_template_filtereffect.h"

namespace feinnovideotemplate {

FilterGroup::FilterGroup() {

}

FilterGroup::FilterGroup(list<Filter*> filters) {
    filters_ = filters;
}

FilterGroup::~FilterGroup() {

}


void FilterGroup::AddFilter(Filter* filter){
    AddFilter(filter, -1);
}

void FilterGroup::AddFilter(Filter* filter, int index) {
    if (index < 0) {
        filters_.push_front(filter);
    } else {
        int i=0;
        for(list<Filter*>::iterator iter = filters_.begin();
                i < index && iter != filters_.end(); i++, iter++) {
            filters_.insert(iter, filter);
        }
    }
    if (effect() == NULL) {
        FilterEffect *effect = new FilterEffect();
        set_effect(effect);
    }

    //fixme
    //effect().AddEffect(filter.GetGpuImageFilter(), index);
}

unsigned char* FilterGroup::ApplyEffect(unsigned char*  curFrame, bool isPreview) {
    assert(effect() != nil);

    FilterEffect* filterEffect = effect();
    
    for(list<Filter*>::iterator iter = temp_filters_.begin();iter != temp_filters_.end();iter++)
    {
        delete *iter;
    }
    temp_filters_.clear();
    
    Filter *filter = NULL;
    for (list<Filter*>::iterator iterator = filters_.begin(); iterator != filters_.end(); iterator++) {
        filter = *iterator;
        // 根据入点、出点过滤当前需要执行的滤镜
        if (frame_index() >= filter->offset()
                && frame_index() < filter->GetOutPoint()) {
            if (!filterEffect->Contains(filter->GetGpuImageFilter())) {
                filterEffect->AddEffect( filter->GetGpuImageFilter());
            }
            temp_filters_.push_back(filter);
        } else {
            //先不考虑删除
        //    filterEffect.remove(filter.getGpuImageFilter());
        }
    }

    for (list<Filter*>::iterator iterator = temp_filters_.begin(); iterator!= temp_filters_.end();iterator++) {
        (*iterator)->ApplyDynamicParam();
    }

    curFrame = effect()->ApplyEffect(curFrame, isPreview, temp_filters_);

    return curFrame;
}

//???抄错了？？fixme
//void set_frame_rate(int frameRate) {
//    Filter::set_frame_rate(frameRate);
//    for (list<Filter*>::iterator iterator = filters.iterator(); iterator.hasNext();) {
//        iterator.next().setFrameRate(frameRate);
//    }
//}
//
//void set_frame_index(long frameIndex) {
//    super.setFrameIndex(frameIndex);
//    for (Iterator<Filter> iterator = filters.iterator(); iterator.hasNext();) {
//        iterator.next().setFrameIndex(frameIndex);
//    }
//}
//
//void Close() {
//    for (Iterator<Filter> iterator = filters.iterator(); iterator.hasNext();) {
//        iterator.next().close();
//    }
//}




} /* namespace feinnovideotemplate */
