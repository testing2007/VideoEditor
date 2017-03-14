/*
 * video_template_filter.h
 *
 *  Created on: 2014年9月1日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_FILTER_H_
#define VIDEO_TEMPLATE_FILTER_H_

#include "video_template_mediaclip.h"
#include <string>
#include <cmath>
#include "video_template_imageseqasset.h"
#include "video_template_filtereffect.h"

#include "base/ObjcClass.h"

OBJC_CLASS(GPUImageFilter);
//OBJC_CLASS(FilterAdjuster);
OBJC_CLASS(GPUImageRawDataInput);
OBJC_CLASS(GPUImagePicture);

namespace feinnovideotemplate {
using std::string;

class Filter: public feinnovideotemplate::MediaClip {
public:
    Filter();
    virtual ~Filter();

    // [ ======= 存取方法 ==========

    const string& filter_type() const {
        return filter_type_;
    }

    void set_filter_type(const string& filter_type) {
        filter_type_ = filter_type;
    }

    int percentage() const {
        return percentage_;
    }

    void set_percentage(const int percentage) {
        percentage_ = percentage;
    }

    const string& attachment() const {
        return attachment_;
    }

    void set_attachment(const string& attachment) {
        attachment_ = attachment;
    }

    int attach_id() const {
        return attach_id_;
    }

    void set_attach_id(int attach_id) {
        attach_id_ = attach_id;
    }

    const string& name() const {
        return name_;
    }

    void set_name(const string& name) {
        name_ = name;
    }

    void set_fade_in(int fade_in) {
        fade_in_ = fade_in / 40;
    }

    void set_fade_out(int fade_out) {
        fade_out_ = fade_out / 40;
    }

    long frame_index() const {
        return frame_index_;
    }

    void set_frame_index(long frame_index) {
        frame_index_ = frame_index;
    }
    
    unsigned char* attach_image() {
        return attach_image_;
    }
    
    void set_attach_image(unsigned char* attach_image) {
        if(attach_image_ != NULL) {
            delete []attach_image_;
            attach_image_ = NULL;
        }
        attach_image_ = attach_image;
    }
    
    

    // ] ====== 存取方法 ===========
public:
	 FilterEffect* effect() {
         return (FilterEffect*) MediaClip::effect();
	}
    
    /**
     * 设置动态参数
     */
    void ApplyDynamicParam();

    void Close();

    //fixme
    GPUImageFilter* GetGpuImageFilter();
    
    GPUImageRawDataInput* second_input(){
        return second_input_;
    }
    
    void set_second_input(GPUImageRawDataInput* secondInput)
    {
        second_input_ = secondInput;
    }
    
protected:
    void CalFadeIn(int fade) {
        float fpercent =  (frame_index_ - offset()) / (float)fade;
        // 模拟指数曲线
        percentage_ = (int)(((exp(fpercent) - 1) / (MATH_E - 1)) * 100);
    }

    void CalFadeOut(int fade) {
        float fpercent =  (GetOutPoint() - frame_index_) / (float)fade;
        // 模拟指数曲线
        percentage_ = (int)(((exp(fpercent) - 1) / (MATH_E - 1)) * 100);
    }

    //fixme
    unsigned char* GetTemplateImage();








private:

    /**
     * 根据模板处理的时序（毫秒）计算混合滤镜的背景图片索引
     *
     * @return
     */
    //fixme
    int GetImageIndex(ImageSeqAsset *imageSeqAsset, long frameIndex);


private:

    /** 滤镜类型（GPUImage FilterType） */
    string filter_type_;

    /** 滤镜的可调参数 */
    int percentage_;

    /** 附加素材 */
    string attachment_;

    int attach_id_;

    unsigned char* attach_image_;

    string name_;

    //
    GPUImageFilter* gpu_image_filter_;

    //叠加的图片，源数据格式输入
    GPUImageRawDataInput* second_input_;
    
    //fixme 没用
    //FilterAdjuster* adjuster_;

    int fade_in_;

    int fade_out_;

    /** 当前模板处理的帧序号 */
    long frame_index_;

    // 特殊的东西，GPUImageLookupFilter专用
    unsigned char* GPUImageLookupFilter_second_data_;
    
    //处理gpuimagerawdatainput内存临时方法，直接访问framebuffer的unlock
    //首次要unlock 2次
    int unlock_framebuffer_index_;
    
    
    GPUImagePicture* gpuimage_input2_; //INSTAINKWELL
    GPUImagePicture* gpuimage_input3_;
    GPUImagePicture* gpuimage_input4_;
    GPUImagePicture* gpuimage_input5_;
    GPUImagePicture* gpuimage_input6_;
    
};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_FILTER_H_ */
