/*
 * video_template_filtereffect.cpp
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#include "video_template_filtereffect.h"
#include "video_template_filter.h"
#include <GPUImage.h>


namespace feinnovideotemplate {
    
    static CGSize image_size = {480,480};

    GPUImageView * FilterEffect::g_gpu_image_view=nil;
    
    //信号量，用于异步转同步 滤镜合成后存文件用，保持与安卓逻辑一致
    static dispatch_semaphore_t g_semaphore= dispatch_semaphore_create(0);
  
FilterEffect::FilterEffect():Effect(),gpu_image_(nil),gpu_image_view_(nil),filter_group_(nil),gpu_image_output_(nil),output_raw_data_(NULL) {
    //g_semaphore = dispatch_semaphore_create(0);
}

FilterEffect::~FilterEffect() {
    
    if(output_raw_data_){
        delete []output_raw_data_;
        output_raw_data_ = NULL;
    }
    
    [[gpu_image_ framebufferForOutput] unlock];
    [gpu_image_ removeAllTargets];
    [gpu_image_ removeOutputFramebuffer];
    gpu_image_ = nil;
    
    [[GPUImageContext sharedFramebufferCache] purgeAllUnassignedFramebuffers];
    
    
    FilterEffect::g_gpu_image_view = nil;
    
    NSLog(@"~FilterEffect \n");
}
   

unsigned char* FilterEffect::ApplyEffect(unsigned char* curFrame, bool isPreview,list<Filter*>& filterlist) {

    //输出到文件，创建输入输出。
    if(gpu_image_ == nil)
    {
        gpu_image_ = [[GPUImageRawDataInput alloc] initWithBytes:curFrame size:image_size];
        unlock_framebuffer_index_ = 0;
        
        if (isPreview) {
            if (gpu_image_view_ == nil) {
                gpu_image_view_ = FilterEffect::g_gpu_image_view;
            }
            
        } else {
            if(gpu_image_output_ == nil){
                output_raw_data_ = new unsigned char[data_size_];
                gpu_image_output_ = [[GPUImageRawDataOutput alloc] initWithImageSize:image_size resultsInBGRAFormat:YES];
            }
        }
    
    } else {
        //删除filter关联，准备重新建链
        //[gpu_image_ removeAllTargets];
        //[[gpu_image_ framebufferForOutput] clearAllLocks];
        [[gpu_image_ framebufferForOutput] unlock];
        if(unlock_framebuffer_index_ == 0){
            unlock_framebuffer_index_ ++;
            [[gpu_image_ framebufferForOutput] unlock];    
        }
       // [[gpu_image_ framebufferForOutput] unlock];
        [gpu_image_ removeOutputFramebuffer];

       // toImage(curFrame);

        //更新主视频输入数据
        [gpu_image_ updateDataFromBytes:curFrame size:image_size];
//        gpu_image_ = [[GPUImageRawDataInput alloc] initWithBytes:curFrame size:image_size];
    }
    // 添加所有gpufilter
    GPUImageFilter* nextFilter = nil;
    
//    //【【【【【【【【测试
//    static bool aaa=false ;
//    if(!aaa){ ///test 测试只设置一次值
//    //】】】】】】】】】】】】
    
    list<Filter*>::iterator iterator = filterlist.begin();
    if(iterator != filterlist.end()){
        nextFilter = (*iterator)->GetGpuImageFilter();
        [gpu_image_ addTarget:nextFilter];
    }else{
        //没有filter，返回空。应该出错
        assert(filterlist.size()>0);
        return NULL;
    }
    for (iterator++; iterator!= filterlist.end();iterator++) {
        GPUImageFilter* temp = (*iterator)->GetGpuImageFilter();
        [nextFilter addTarget: temp];
        nextFilter = temp;
    }
        
//        //需要添加图片的gpufilter，添加第二个输入
//        for (list<Filter*>::iterator iterator2 = filterlist.begin(); iterator2!= filterlist.end();iterator2++) {
//            (*iterator2)->ApplyDynamicParam();
//        }
    
//    //----------------测试【【【【【
//        aaa = true;
//    }
//    //----------------测试】】】】
    
    //添加输出 view 或 文件
    if(isPreview){
        [nextFilter addTarget:gpu_image_view_];
    } else {
        [nextFilter addTarget:gpu_image_output_];
        
        __unsafe_unretained GPUImageRawDataOutput * weakOutput = gpu_image_output_;

        [gpu_image_output_ setNewFrameAvailableBlock:^{
            [weakOutput lockFramebufferForReading];
            GLubyte *outputBytes = [weakOutput rawBytesForImage];
           // NSInteger bytesPerRow = [weakOutput bytesPerRowInOutput];
           // NSLog(@"Bytes per row: %ld", (unsigned long)bytesPerRow);
            
            //拷贝数据, 等待信号量同步再返回
            memcpy(output_raw_data_, outputBytes, data_size_);
            dispatch_semaphore_signal(g_semaphore);
            
            [weakOutput unlockFramebufferAfterReading];
        }];
    }
    //启动所有输入
    for (list<Filter*>::iterator iterator = filterlist.begin(); iterator!= filterlist.end();iterator++) {
        Filter* temp = (*iterator);
        temp-> ApplyDynamicParam();
//        if(temp->second_input() != nil) {
//            [temp->second_input() processData];
//        }
    }
    //最后开主输入，可能会阻止开始黑屏出现一下
    [gpu_image_ processData];
    
    if(!isPreview){
        //等待数据拷贝完成
         dispatch_semaphore_wait(g_semaphore, DISPATCH_TIME_FOREVER);
            
        return output_raw_data_;
    } else {
        return curFrame;
    }
}

void FilterEffect::AddEffect(GPUImageFilter* gpuImageFilter) {
    AddEffect(gpuImageFilter, -1);
}

void FilterEffect::AddEffect(GPUImageFilter *gpuImageFilter, int index) {
    
    // 此处与安卓使用filter的方法不一样，GPUImageFilterGroup 实际未用到
//    if (filter_group_ == nil) {
//        filter_group_ = [[GPUImageFilterGroup alloc] init];
//    }
//    [(GPUImageFilterGroup*)filter_group_ addFilter:(GPUImageFilter*)gpuImageFilter];
}

// list<GPUImageFilter*> FilterEffect::GetFilters() {
//  
//     list<GPUImageFilter*> group;
//     for(GPUImageFilter* filter in [(GPUImageFilterGroup*)filter_group_ initialFilters])
//     {
//         group.push_back(filter);
//     }
//     return group;
//}
    
    //未起作用
    bool FilterEffect::Contains(GPUImageFilter *filter){
        for(int i=0 ;i< [filter_group_ filterCount]; i++)
        {
            if([filter_group_ filterAtIndex:i] == filter)
                return true;
        }
        return false;
    }
    
    
    void FilterEffect::Remove(GPUImageFilter *filter){
        NSMutableArray *array = [NSMutableArray arrayWithArray:[(GPUImageFilterGroup*)filter_group_ initialFilters]];
        [array removeObject:filter ];
//        [(GPUImageFilterGroup*)filter_group_
    }


} /* namespace feinnovideotemplate */
