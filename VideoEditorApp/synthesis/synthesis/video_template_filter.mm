/*
 * video_template_filter.cpp
 *
 *  Created on: 2014年9月1日
 *      Author: 尚博才
 */

#include "video_template_filter.h"
#include "video_template_adjuster.h"
#include "video_template_videoasset.h"
#include "video_template_filterutils.h"
#include "video_template_videotemplateutils.h"
#include <GPUImage.h>

namespace feinnovideotemplate {

    static CGSize image_size = {480,480};
    
Filter::Filter():percentage_(50),fade_in_(0),fade_out_(0),
    attach_image_(NULL),gpu_image_filter_(nil),second_input_(nil),GPUImageLookupFilter_second_data_(NULL) {
    // TODO Auto-generated constructor stub

}

Filter::~Filter() {
    Close();
//    if(adjuster_ != NULL){
//        delete adjuster_;
//        adjuster_  = NULL;
//    }
    if(attach_image_ != NULL){
        delete []attach_image_;
        attach_image_ = NULL;
        [[second_input_ framebufferForOutput] unlock];
    }
    if(GPUImageLookupFilter_second_data_){
        delete []GPUImageLookupFilter_second_data_;
        GPUImageLookupFilter_second_data_ = NULL;
        [[second_input_ framebufferForOutput] unlock];
    }
    
    [[second_input_ framebufferForOutput] unlock];
    [second_input_ removeAllTargets];
    [second_input_ removeOutputFramebuffer];
    
    second_input_ = nil;
    
    [gpu_image_filter_ removeAllTargets];
    gpu_image_filter_ = nil;
    
     [gpuimage_input2_ removeAllTargets]; //INSTAINKWELL
     [gpuimage_input3_ removeAllTargets];
     [gpuimage_input4_ removeAllTargets];
     [gpuimage_input5_ removeAllTargets];
     [gpuimage_input6_ removeAllTargets];

    
    printf("~Filter %s\n", filter_type_.c_str());
}


void Filter::ApplyDynamicParam() {

    //1个滤镜添加多个图片素材的情况，根据配置文件的滤镜名来处理
    if(filter_type_ == "INSTAINKWELL"){
        if(gpuimage_input2_ == Nil){
            UIImage *img = [UIImage imageNamed:@"inkwellMap.png"];
            gpuimage_input2_ = [[GPUImagePicture alloc] initWithImage:img];
            
            [gpuimage_input2_ addTarget:gpu_image_filter_];
            img = nil;
        }
        [gpuimage_input2_ processImage];
        
    } else if(filter_type_ == "INSTAEARLYBIRD") {
        if(gpuimage_input2_ == Nil){
            UIImage *img = [UIImage imageNamed:@"earlyBirdCurves.png"];
            gpuimage_input2_ = [[GPUImagePicture alloc] initWithImage:img];
            [gpuimage_input2_ addTarget:gpu_image_filter_];
            
            img = [UIImage imageNamed:@"earlybirdOverlayMap.png"];
            gpuimage_input3_ = [[GPUImagePicture alloc] initWithImage:img];
            [gpuimage_input3_ addTarget:gpu_image_filter_];
            
            img = [UIImage imageNamed:@"vignetteMap.png"];
            gpuimage_input4_ = [[GPUImagePicture alloc] initWithImage:img];
            [gpuimage_input4_ addTarget:gpu_image_filter_];
            
            img = [UIImage imageNamed:@"earlybirdBlowout.png"];
            gpuimage_input5_ = [[GPUImagePicture alloc] initWithImage:img];
            [gpuimage_input5_ addTarget:gpu_image_filter_];
            
            img = [UIImage imageNamed:@"earlybirdMap.png"];
            gpuimage_input6_ = [[GPUImagePicture alloc] initWithImage:img];
            [gpuimage_input6_ addTarget:gpu_image_filter_];
            
            img = nil;
        }
        [gpuimage_input2_ processImage];
        [gpuimage_input3_ processImage];
        [gpuimage_input4_ processImage];
        [gpuimage_input5_ processImage];
        [gpuimage_input6_ processImage];
    }
    else if(filter_type_ == "INSTAHUDSON"){
        if(gpuimage_input2_ == Nil){
            
            UIImage *img = [UIImage imageNamed:@"hudsonBackground.png"];
            gpuimage_input2_ = [[GPUImagePicture alloc] initWithImage:img];
            [gpuimage_input2_ addTarget:gpu_image_filter_];
            
            img = [UIImage imageNamed:@"overlayMap.png"];
            gpuimage_input3_ = [[GPUImagePicture alloc] initWithImage:img];
            [gpuimage_input3_ addTarget:gpu_image_filter_];
            
            img = [UIImage imageNamed:@"hudsonMap.png"];
            gpuimage_input4_ = [[GPUImagePicture alloc] initWithImage:img];
            [gpuimage_input4_ addTarget:gpu_image_filter_];
            
            img = nil;
        }
        [gpuimage_input2_ processImage];
        [gpuimage_input3_ processImage];
        [gpuimage_input4_ processImage];

    } else if(filter_type_ == "INSTAHEFE") {
        if(gpuimage_input2_ == Nil){
            
            UIImage *img = [UIImage imageNamed:@"edgeBurn.png"];
            gpuimage_input2_ = [[GPUImagePicture alloc] initWithImage:img];
            [gpuimage_input2_ addTarget:gpu_image_filter_];
            
            img = [UIImage imageNamed:@"hefeMap.png"];
            gpuimage_input3_ = [[GPUImagePicture alloc] initWithImage:img ];
            [gpuimage_input3_ addTarget:gpu_image_filter_];
            
            img = [UIImage imageNamed:@"hefeSoftLight.png"];
            gpuimage_input4_ = [[GPUImagePicture alloc] initWithImage:img ];
            [gpuimage_input4_ addTarget:gpu_image_filter_];
            
            img = [UIImage imageNamed:@"hefeMetal.png"];
            gpuimage_input5_ = [[GPUImagePicture alloc] initWithImage:img ];
            [gpuimage_input5_ addTarget:gpu_image_filter_];
            
            img = nil;
        }
        [gpuimage_input2_ processImage];
        [gpuimage_input3_ processImage];
        [gpuimage_input4_ processImage];
        [gpuimage_input5_ processImage];

    } else if(filter_type_ == "INSTAKELVIN"){
        if(gpuimage_input2_ == Nil){
            UIImage *img = [UIImage imageNamed:@"kelvinMap.png"];
            gpuimage_input2_ = [[GPUImagePicture alloc] initWithImage:img];
            [gpuimage_input2_ addTarget:gpu_image_filter_];
            
            img = nil;
        }
        [gpuimage_input2_ processImage];
       
    } else if(filter_type_ == "INSTALOFI"){
        if(gpuimage_input2_ == Nil){
            
            UIImage *img = [UIImage imageNamed:@"lomoMap.png"];
            gpuimage_input2_ = [[GPUImagePicture alloc] initWithImage:img];
            [gpuimage_input2_ addTarget:gpu_image_filter_];
            
            img = [UIImage imageNamed:@"vignetteMap.png"];
            gpuimage_input3_ = [[GPUImagePicture alloc] initWithImage:img];
            [gpuimage_input3_ addTarget:gpu_image_filter_];
            
            img = nil;
        }
        [gpuimage_input2_ processImage];
        [gpuimage_input3_ processImage];

    }
  else
    // 设置背景图片
    if ([(GPUImageFilter*)gpu_image_filter_ isKindOfClass:GPUImageTwoInputFilter.class]) {
        
        unsigned char* bitmap = NULL;
        // 对GPUImageLookupFilter 特殊处理。逻辑设计问题，filter不能配置第二输入
        if([(GPUImageFilter*)gpu_image_filter_ isKindOfClass:GPUImageLookupFilter.class]){
            if(GPUImageLookupFilter_second_data_ == NULL) {
                string GPUImageLookupFilter_imgfile = [[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/lookup_amatorka.png"] UTF8String];
                
                GPUImageLookupFilter_second_data_ = VideoTemplateUtils::GetDataFromImgFile(GPUImageLookupFilter_imgfile);
            }
            bitmap = GPUImageLookupFilter_second_data_;
        }
        else if(attach_image_ != NULL){ // 装饰 和 字幕
            bitmap = attach_image_;
        }
        else //主题 和 滤镜
        {
           bitmap = GetTemplateImage();
        }
        if (bitmap != NULL) {
            // 先释放前次加载的图像
            //((GPUImageTwoInputFilter) gpuImageFilter).onDestroy();
            //((GPUImageTwoInputFilter) gpuImageFilter).setBitmap(bitmap);
            
         //   VideoTemplateUtils::toImage(bitmap, "Filter::ApplyDynamicParam");
            
            //添加第二输入
            if(second_input_ == nil){
                unlock_framebuffer_index_ = 0;
                
                // png图片rgba格式，视频bgra格式
                GPUPixelFormat pixelFormat = GPUPixelFormatRGBA;
                if(asset() != NULL && GetAssetType() == VIDEO){
                    pixelFormat = GPUPixelFormatBGRA;
                }
                
                CGSize imageSize = image_size;
                if(  name() == "LookupFilter"){
                    imageSize = {512,512};
                }
                second_input_ = [[GPUImageRawDataInput alloc] initWithBytes:bitmap size:imageSize
                                                                pixelFormat:pixelFormat];
                [second_input_ addTarget:gpu_image_filter_];
              //  [second_input_ processData];
            }else{
                // attach_image_ 不空的时候，是传入装饰图片，不需更新数据
                // GPUImageLookupFilter_second_data_ 不为空的时候是特殊滤镜GPUImageLookupFilter需要加载第二输入图片，不需更新数据
                if(attach_image_ == NULL && GPUImageLookupFilter_second_data_ == NULL) {
                    // 释放framebuffer，让gpuimage回收内存
                    [[second_input_ framebufferForOutput] unlock];
                    if(unlock_framebuffer_index_ ==0 ){
                        unlock_framebuffer_index_++;
                        [[second_input_ framebufferForOutput] unlock];
                    }
                    [second_input_ updateDataFromBytes:bitmap size:image_size];
                    
                }
            }
            
        }
        [second_input_ processData];
    }
    
    if(frame_index_ < offset() + fade_in_){
        CalFadeIn(fade_in_);
        FilterAdjuster::adjust(gpu_image_filter_, percentage_);
    } else if(frame_index_ >= GetOutPoint() - fade_out_){
        CalFadeOut(fade_out_);
        FilterAdjuster::adjust(gpu_image_filter_, percentage_);
    }
}

void Filter::Close() {
    // fixme
    if (asset() != NULL && asset()->asset_type() == VIDEO) {
        ((VideoAsset*) asset())->CloseDecode();
    }
}
 
    GPUImageFilter* Filter::GetGpuImageFilter(){
        if(gpu_image_filter_ == nil){
			gpu_image_filter_ = FilterUtils::GenGPUImageFilter(this);
			//adjuster = new GPUImageFilterTools.FilterAdjuster(gpuImageFilter);
			//if (adjuster != NULL) {
			//	adjuster.adjust(percentage_);
			//}
            FilterAdjuster::adjust(gpu_image_filter_, percentage_);
		}
		return gpu_image_filter_;
    }
    
    int Filter::GetImageIndex(ImageSeqAsset *imageSeqAsset, long frameIndex)
    {
        return 1;
    }
    
    unsigned char* Filter::GetTemplateImage(){
//        if (GetAssetType() == NULL) {
//			return NULL;
//		}
		switch (GetAssetType()) {
            case IMAGE:{
                ImageSeqAsset *imageSeqAsset = (ImageSeqAsset*) asset();
                if (imageSeqAsset->attach_size() == 1) {
                    if (frame_index_ == offset()) {
                        return imageSeqAsset->GetImage(0);
                    }
                } else {
                    int imageIndex = GetImageIndex(imageSeqAsset, frame_index_);
                    if (imageIndex >= 0) {
                        return imageSeqAsset->GetImage(imageIndex);
                    }
                }
                return NULL;
                //break;
            }
            case VIDEO:
            {
                // 视频，需要先解码
                VideoAsset *videoAsset = (VideoAsset*)asset();
                unsigned char* frame = NULL;
                if (videoAsset->cursor() == 0) {
                    videoAsset->StartDecode();
                }
                if (videoAsset->cursor() < GetOutPoint()) {
                    frame = videoAsset->GetNextFrame();
                }
                if (frame == NULL) {
                    if (recycle()) {
                        videoAsset->StartDecode();
                        frame = videoAsset->GetNextFrame();
                    }
                }
                return frame;
                //break;
            }
            default:
                return NULL;
                //break;
		}

    }
    

} /* namespace feinnovideotemplate */
