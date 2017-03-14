//
//  SynthesisImpl.cpp
//  libSynthesis
//
//  Created by wzq on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#include "SynthesisImpl.h"
#include <GPUImageView.h>
#include "video_template_videotemplateutils.h"
#include "video_template_videoprojectutils.h"
#include "video_template_mediamgr.h"
#include "video_template_filterutils.h"
#include <base/SynthesisParameterInfo.h>
#include <base/Common.h>

#include <CoreGraphics/CGImage.h>
#import <ImageIO/ImageIO.h>
#import <Foundation/NSException.h>

#include <cassert>


using namespace feinnovideotemplate;

dispatch_semaphore_t g_pause_signal_ = dispatch_semaphore_create(0);

static void param2VideoTaskData(VideoTaskData& taskData, SynthesisParameterInfo& param, bool isPreview){
    taskData.filterId = param._strFilterVideoPath;
    taskData.themeId = param._strThemeVideoPath;
    taskData.uri = param._strSrcVideoPath;
    taskData.outputVideoFile = param._strPhotoAlbumTempPath.length() > 0 ? param._strPhotoAlbumTempPath : param._saveVideoPath;
    taskData.isMute=param._bMute;
    taskData.isPreview=isPreview;
    taskData.isSaveFile = !isPreview;
    
    if(param._strBgMusicPath.length()>0){
        taskData.music =  MediaMgr::CreateAudio(param._strBgMusicPath, 0,250);//param._nBgMusicStartTime, param._nBgMusicDuration);
    }
    
    // 录音，目前用不到
    //    if(param.){
    //        taskData.audioClips.push_back(MediaMgr::CreateAudio(param.,
    //                                                           dubAudioTime / 40, dubAudioTimeLength / 40));
    //    }
    
    //读取图片
    if(param._strDecorateImgPath.length()>0){
        unsigned char* image = VideoTemplateUtils::GetDataFromImgFile(param._strDecorateImgPath);
        if(image != NULL){
            taskData.decorateFilter = FilterUtils::BuildDecorateFilter();
            taskData.decorateFilter->set_attach_image(image);
            taskData.decorateFilter->set_offset(0);
            taskData.decorateFilter->set_duration(250);
        }
    }
    
    if(param._strSubtitleImgPath.length()>0){
        unsigned char* image = VideoTemplateUtils::GetDataFromImgFile(param._strSubtitleImgPath);
        if(image != NULL){
            taskData.titlles.push_back(MediaMgr::CreateTittle(image, param._nSubtitleStartTime / 40, param._nSubitileEndTime / 40));
        }
    }
}

SynthesisImpl::SynthesisImpl():callback_(NULL),play_state_(0){
    
}

void SynthesisImpl::registerCallback(ISynthesisCallback* synCallback)
{
    callback_ = synCallback;
}

void SynthesisImpl::stop()
{
    play_state_ = 0;
}

void SynthesisImpl::doProcess(SynthesisParameterInfo& param, bool ispreview) {
    
     @autoreleasepool {
        play_state_ = 1;
        
        FilterEffect::g_gpu_image_view = param._gpuImageView;
        
        VideoTaskData data;
        param2VideoTaskData(data, param, ispreview);
        
        VideoProjectUtils vp;
        vp.Excute(&data, callback_, &play_state_);
        
        NSLog(@"结束了\n");
     }
}

void SynthesisImpl::preview(SynthesisParameterInfo& param)
{
    doProcess(param ,true);
    
}

void SynthesisImpl::save(SynthesisParameterInfo& param)
{
    //测试
    //param._bMute = false;
    
    doProcess(param ,false);
}

void SynthesisImpl::pause(){
    play_state_ = 2;
    NSLog(@"PLAY_STATE == 2");
}

void SynthesisImpl::resume() {
    play_state_ = 1;
    NSLog(@"PLAY_STATE == 1 BEFORE SIGNAL");
    dispatch_semaphore_signal(  g_pause_signal_);
    NSLog(@"PLAY_STATE == 1 AFTER SIGNAL");
}
