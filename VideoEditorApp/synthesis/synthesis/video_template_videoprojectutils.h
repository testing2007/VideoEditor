//
//  video_template_videoprojectutils.h
//  libSynthesis
//
//  Created by shangbocai on 14-9-15.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef __libSynthesis__video_template_videoprojectutils__
#define __libSynthesis__video_template_videoprojectutils__

#include <iostream>
#include "video_template_videoproject.h"
#include "video_template_taskdata.h"
#include "video_template_audiogroup.h"

class ISynthesisCallback;

namespace feinnovideotemplate {
    using std::string;
    
    class VideoProjectUtils {
    private:
        
        VideoTaskData* video_processor_;
        
        // 保存输入视频的地址，用来生成输出文件的地址
        // private static Uri processVideoUri = null;
        
        /**
         * UI点击模板（或滤镜）调用的处理接口
         *
         * @param videoProcessor
         *            UI的事件处理器，这里用来设置进度和结束标记
         * @return 处理后的文件
         */
        
        //用于给界面回调处理进度
        ISynthesisCallback* callback_;
        
        //用于中断处理
        int* stop_;
    public:
        VideoProjectUtils():video_processor_(NULL){}
       
        void Excute(VideoTaskData*  newVideoProcessor, ISynthesisCallback* callback,int* stop) ;
        
        static VideoProject* BuildVideoProject(VideoTaskData*  processTask);
        string  ExcuteProject(VideoProject* videoProject) ;
        
        AudioGroup* GetAudioGroup(VideoProject* videoProject) ;
        
        /**
         * 一、简单应用，直接指定滤镜处理素材
         * 
         * @param video
         *            素材
         * @param filterId
         *            滤镜类型
         * @return 处理后的视频文件
         */
        string ApplyFilter(string& filterId, list<string>& videos) ;
        
        /**
         * 二、选择模板，处理素材
         * 
         * @param video
         *            素材
         * @param videoTemplateId
         *            视频处理模板
         * @return 处理后的视频文件
         */
         string  ApplyVideoTemplate(string videoTemplateId, list<string>& videos ) ;
        // 三、自定义模板（对一系列自定义操作的描述），或自定义模板元素（替换模板元素）
        //
        
    };
}

#endif /* defined(__libSynthesis__video_template_videoprojectutils__) */
