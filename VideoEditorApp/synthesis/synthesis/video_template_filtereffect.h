/*
 * video_template_filtereffect.h
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_FILTEREFFECT_H_
#define VIDEO_TEMPLATE_FILTEREFFECT_H_

#include "video_template_effect.h"
#include <list>
#include <base/ObjcClass.h>


OBJC_CLASS(GPUImageFilter);
OBJC_CLASS(GPUImageView);
OBJC_CLASS(GPUImageFilterGroup);
OBJC_CLASS(GPUImageRawDataInput);
OBJC_CLASS(GPUImageRawDataOutput);

namespace feinnovideotemplate {
using std::list;
    
 

//fixme
class FilterEffect: public feinnovideotemplate::Effect {
public:
    FilterEffect();
    virtual ~FilterEffect();

    static   GPUImageView *g_gpu_image_view;
    
    bool Contains(GPUImageFilter *filter);
    void Remove(GPUImageFilter *filter);

    unsigned char* ApplyEffect(unsigned char* curFrame, bool isPreview,list<Filter*>& filterlist);
   // list<GPUImageFilter*> GetFilters();

    void AddEffect(GPUImageFilter* gpuImageFilter);
    void AddEffect(GPUImageFilter* gpuImageFilter, int index);

private:
    //诱人出错的名字，废弃
//    GPUImageRawDataInput *GetGPUImage();
//    void SetGPUImage();

    //变量名是为了和安卓的对应，这里是视频数据RGBA格式输入
    GPUImageRawDataInput *gpu_image_;
    //GPU输出到界面
    GPUImageView *gpu_image_view_;

    // 支持多个滤镜效果，。。。。是否需要？？？可以用自己的groupfilter的templist代替？？
    GPUImageFilterGroup* filter_group_;

    //输出到文件时使用，接受处理完的图像然后自己编码存文件
    GPUImageRawDataOutput* gpu_image_output_;
    
    //图像数据数组，暂时初始化input用
    // unsigned char *raw_data_bytes_;
     const int data_size_ = 480 * 480 * 4;
    //图像数据数组，存处理完的图像
    unsigned char *output_raw_data_;
    
    //临时处理方案，gpuimagerowdatainput没找到合适的接口释放每一帧处理的内存
    //直接处理framebuffer的引用计数，将其返回gpuimage的内存池，第一次处理需调2次unlock，之后只需一次。
    int unlock_framebuffer_index_;
};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_FILTEREFFECT_H_ */
