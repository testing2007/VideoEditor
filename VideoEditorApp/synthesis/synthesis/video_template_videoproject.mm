//
//  video_template_videoproject.cpp
//  libSynthesis
//
//  Created by shangbocai on 14-9-15.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#include "video_template_videoproject.h"
#include "video_template_filtergroup.h"
#include "video_template_filterutils.h"



namespace feinnovideotemplate {
    
    VideoProject::VideoProject(VideoTemplate* videoTemplate) {
        assert(videoTemplate != NULL);
        video_template_ = videoTemplate;
    }
    
    VideoProject::~VideoProject(){
        if(video_template_ != NULL){
            delete video_template_;
            video_template_ = NULL;
        }
    }
    
    /**
     * 把素材绑定到模板对应节点（暂时只实现视频轨素材绑定）
     *
     * @param mediaClip
     * @return
     */
    void VideoProject::AddMedia(list<MediaClip*>& mediaClips) {
        assert(video_template_ != NULL && video_template_->render_tree() != NULL);
        
        long totalFrame = 0;
        TimeLineNode* renderTree = video_template_->render_tree();
        list<TimeLineNode*>& trackList = renderTree->child_node_list();
        for (list<TimeLineNode*>::iterator iterator = trackList.begin(); iterator != trackList.end(); iterator++) {
            TimeLineNode *trackNode = *iterator;
            if (trackNode->node_type() == VIDEO_TRACK) {
                list<TimeLineNode*>& videoNodes = trackNode->child_node_list();
                list<MediaClip*>::iterator mediaIter = mediaClips.begin();
                TimeLineNode *videoNode = NULL;
                for (list<TimeLineNode*>::iterator iterator2 = videoNodes.begin(); iterator2 != videoNodes.end(); iterator2++) {
                    videoNode = *iterator2;
                    //todo
//                    if (videoNode->node_data() != NULL) {
//                        // 模板自带素材节点，如“片头”
//                        continue;
//                    }
                    ///////////////////////////////////////////////////
                    MediaClip *clip =  *mediaIter++;
                    videoNode->set_node_data(clip);
                    //////////////////////
                    totalFrame += clip->duration();
                    //////////////////////
                    if(clip->duration() < videoNode->duration()){
                        videoNode->set_duration(clip->duration());
                    }
                    TimeLineNode *filterNode = *(videoNode->child_node_list().begin());
                    FilterGroup *filterGroup = (FilterGroup*)filterNode->node_data();
                    if(filterGroup->effect() == NULL){
                        Filter *filter = FilterUtils::BuildBlankFilter();
                        filter->set_offset(videoNode->offset());
                        filter->set_duration(videoNode->duration());
                        filterGroup->AddFilter(filter);
                    }
                    ///////////////////////////////////////////////////
                    
                    if (mediaIter == mediaClips.end()) {
                        break;
                    }
                    
                }
                
                
            }
        }
        video_template_->set_total_frame(totalFrame);
    }
    
}