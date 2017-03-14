//
//  video_template_videoproject.h
//  libSynthesis
//
//  Created by shangbocai on 14-9-15.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef __libSynthesis__video_template_videoproject__
#define __libSynthesis__video_template_videoproject__

#include <iostream>
#include "video_template_videotemplate.h"


namespace feinnovideotemplate {
    
    
    class VideoProject {
        
    public:
        VideoProject(VideoTemplate* videoTemplate);
        ~VideoProject();
        
        VideoTemplate* video_template() {
            return video_template_;
        }
        
        void set_video_template(VideoTemplate* videoTemplate) {
            video_template_ = videoTemplate;
        }
        
        /**
         * 把素材绑定到模板对应节点（暂时只实现视频轨素材绑定）
         *
         * @param mediaClip
         * @return
         */
        void AddMedia(list<MediaClip*>& mediaClips);
        
        
    private:
        VideoTemplate* video_template_;
        
    };
    
}

















#endif /* defined(__libSynthesis__video_template_videoproject__) */
