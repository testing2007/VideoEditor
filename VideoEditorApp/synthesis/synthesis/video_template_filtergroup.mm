/*
 * video_template_filtergroup.cpp
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#include "video_template_filtergroup.h"
#include "video_template_filtereffect.h"
#include <GPUImage.h>

namespace feinnovideotemplate {

FilterGroup::FilterGroup() {

}

FilterGroup::FilterGroup(list<Filter*> filters) {
    if(filters_.size() >0) {
        for(list<Filter*>::iterator iter = filters_.begin();iter != filters_.end(); iter++) {
            delete *iter;
        }
        filters_.clear();
    }
    filters_ = filters;
}

FilterGroup::~FilterGroup() {

    if(temp_filters_.size()>0) {
        temp_filters_.clear();
    }
    if(filters_.size() >0) {
        for(list<Filter*>::iterator iter = filters_.begin();iter != filters_.end(); iter++) {
            delete *iter;
        }
        filters_.clear();
    }
}


void FilterGroup::AddFilter(Filter* filter){
    AddFilter(filter, -1);
}

void FilterGroup::AddFilter(Filter* filter, int index) {
    if (index < 0) {
        //0，插到队列头；其他插入队列后面，排序的情况以后再说
        //filters_.push_front(filter);
        filters_.push_back(filter);
    } else {
//        int i=0;
//        for(list<Filter*>::iterator iter = filters_.begin();
//                i < index && iter != filters_.end(); i++, iter++) {
//            filters_.insert(iter, filter);
//        }
        
        //filters_.push_back(filter);
        filters_.push_front(filter);
    }
    if (effect() == NULL) {
        FilterEffect *effect = new FilterEffect();
        set_effect(effect);
    }

    //fixme
    effect()->AddEffect(filter->GetGpuImageFilter(), index);
}

unsigned char* FilterGroup::ApplyEffect(unsigned char*  curFrame, bool isPreview) {
    assert(effect() != nil);

    FilterEffect* filterEffect = effect();
    
    for(list<Filter*>::iterator iter = temp_filters_.begin();iter != temp_filters_.end();iter++)
    {
        Filter* myfilter = *iter;
        [myfilter->GetGpuImageFilter() removeAllTargets];
    }
    temp_filters_.clear();
    
    // 找出当前帧用到的滤镜效果（自己的filter），加入到temp_filters_，给filterEffect应用
    Filter *filter = NULL;
    for (list<Filter*>::iterator iterator = filters_.begin(); iterator != filters_.end(); iterator++) {
        filter = *iterator;
        // 根据入点、出点过滤当前需要执行的滤镜
        if (frame_index() >= filter->offset()
                && frame_index() < filter->GetOutPoint()) {
            temp_filters_.push_back(filter);
        }
    }

    curFrame = filterEffect->ApplyEffect(curFrame, isPreview, temp_filters_);

    return curFrame;
}

void FilterGroup::set_frame_rate(int frameRate) {
    Filter::set_frame_rate(frameRate);
    for (list<Filter*>::iterator iterator = filters_.begin(); iterator != filters_.end(); iterator++) {
         (*iterator)->set_frame_rate(frameRate);
    }
}

void FilterGroup::set_frame_index(long frameIndex) {
        Filter::set_frame_index(frameIndex);
    for (list<Filter*>::iterator iterator = filters_.begin(); iterator != filters_.end(); iterator++) {
        (*iterator)->set_frame_index(frameIndex);
    }
}

void FilterGroup::Close() {
        for (list<Filter*>::iterator iterator = filters_.begin(); iterator != filters_.end(); iterator++) {
        (*iterator)->Close();
    }
}




} /* namespace feinnovideotemplate */
