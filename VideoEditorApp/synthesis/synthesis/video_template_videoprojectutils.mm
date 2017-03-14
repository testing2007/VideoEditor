//
//  video_template_videoprojectutils.cpp
//  libSynthesis
//
//  Created by shangbocai on 14-9-15.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#include "video_template_videoprojectutils.h"
#include "video_template_videotemplateutils.h"
#include "video_template_videoasset.h"
#include "video_template_videoclip.h"
#include "video_template_filtergroup.h"
#include "video_template_filterutils.h"
#include "video_template_mediamgr.h"

#include <GPUImage.h>

#include "ISynthesisCallback.h"


extern dispatch_semaphore_t g_pause_signal_ ;

namespace feinnovideotemplate {
 

// 保存输入视频的地址，用来生成输出文件的地址
// private static Uri processVideoUri = null;

/**
 * UI点击模板（或滤镜）调用的处理接口
 *
 * @param videoProcessor
 *            UI的事件处理器，这里用来设置进度和结束标记
 * @return 处理后的文件
 */
 void VideoProjectUtils::Excute(VideoTaskData* newVideoProcessor, ISynthesisCallback* callback,int *stop) {
     callback_ = callback;
     stop_ = stop;
    video_processor_ = newVideoProcessor;
    
    VideoProject* project = BuildVideoProject(video_processor_);
    
    ExcuteProject(project);
     
     delete project;
}

VideoProject* VideoProjectUtils::BuildVideoProject(VideoTaskData* processTask){
    VideoProject *project = NULL;
    
    VideoTemplate *vtemplate = NULL;
    if (processTask->themeId.length() > 0 && processTask->themeId != "0") {
        vtemplate = VideoTemplateUtils::BuildFromXML(processTask->themeId);
    } else {
        // create a blank template
        vtemplate = VideoTemplateUtils::CreateBlankTemplate();
    }
    
    if (processTask->filterId.length() > 0
        && processTask->filterId != "0") {
        Filter* filter = FilterUtils::BuildFromXML(processTask->filterId);
        filter->set_offset(0);
        filter->set_duration(250);
        vtemplate->AddFilter(filter, 0);
    }
    
    
    if (processTask->titlles.size() > 0) {
        //template.addTittle(processTask.getTitlles());
        for (list<Tittle*>::iterator iter = processTask->titlles.begin(); iter!= processTask->titlles.end();iter++) {
            vtemplate->AddFilter((*iter)->GetFilter());
        }
    }
    
    if (processTask->decorateFilter != NULL) {
        vtemplate->AddFilter(processTask->decorateFilter);
    }
    
    
    if (processTask->music != NULL) {
        vtemplate->AddMusic(processTask->music);
    }
    
    if (processTask->audioClips.size() > 0) {
        vtemplate->AddAudio(processTask->audioClips);
    }
    
    project = new VideoProject(vtemplate);
        list<string> urilist;
        urilist.push_back(processTask->uri);
        list<MediaClip*> mediaClips = MediaMgr::BuildMediaClip(VIDEO, urilist);
        project->AddMedia(mediaClips);
    
        if(VideoTemplateUtils::ADD_WATERMARK){
            VideoTemplateUtils::AddWatermarkNode(vtemplate);
    }
    
    return project;
}
    
string VideoProjectUtils::ExcuteProject(VideoProject* videoProject) {
    
    // 处理进度
  //  int progress = 0;
    
    VideoTemplate *videoTemplate = videoProject->video_template();
    
    // 输出文件：暂定为输入文件同目录，文件名加上模板Id
    string outVideo;
    VideoAsset* outVideoAsset = NULL;
    if (!video_processor_->isPreview)
    {
        outVideo = video_processor_->outputVideoFile;
        outVideoAsset = new VideoAsset();
        outVideoAsset->set_uri(outVideo);
    }
    
    long totalFrame = videoTemplate->total_frame();
    TimeLineNode* renderTree = videoTemplate->render_tree();
    list<TimeLineNode*> trackList = renderTree->child_node_list();
    
    // 帧图像
    unsigned char* curFrame = NULL;
    // 滤镜特效
    FilterGroup *filter = NULL;
    VideoClip *videoClip = NULL;
    
    // 音频轨处理
    //AudioClip audioClip = null;
    AudioGroup* audioClips = GetAudioGroup(videoProject);
    
    int frameIndex = 0;
    for (; frameIndex < totalFrame; ) {
        //判断是否要求停止
        if(*stop_ == 0) {
            break;
        }else if(*stop_ == 2){ // 暂停
           
            NSLog(@"STOP_ == 2");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FMEDIA_PAUSE" object:nil];
            callback_->synPause();
            
            NSLog(@"BEFORE WAIT");
            dispatch_semaphore_wait(g_pause_signal_, DISPATCH_TIME_FOREVER);
            NSLog(@"AFTER WAIT");
            continue;
            
        }
            curFrame = NULL;
            filter = NULL;
            //long framestart = ; //fixme
            NSDate *date1 = [NSDate date];
            // 1.遍历时间线的每个轨，获取帧图像、特效、音轨、字幕
            for (list<TimeLineNode*>::iterator iterator = trackList.begin(); iterator != trackList.end(); iterator++) {
                TimeLineNode *track = *iterator;
                
                switch (track->node_type()) {
                        /** 视频轨 */
                    case VIDEO_TRACK:{
                        list<TimeLineNode*> videoNodes = track->child_node_list();
                        for (list<TimeLineNode*>::iterator iterator2 = videoNodes.begin(); iterator2 != videoNodes.end(); iterator2++) {
                            TimeLineNode *videoNode = *iterator2;
                            
                            // 取入点到出点包含当前帧序号的节点
                            if (frameIndex >= videoNode->offset() && frameIndex < videoNode->getOutPoint()) {
                                
                                // 取绑定到节点的素材 video or imageSeq?
                                switch (videoNode->node_type()) {
                                    case VIDEO_NODE:{
                                        if (videoClip != NULL
                                            && videoClip->asset() != ((VideoClip*) videoNode->node_data())->asset()){
                                            videoClip->asset()->CloseDecode();
                                        }
                                        videoClip = (VideoClip*) videoNode->node_data();
                                        
                                        // 取视频节点指定的滤镜
                                        list<TimeLineNode*>& filterNodes = videoNode->child_node_list();
                                        if (filterNodes.size() > 0) {
                                            // 只有一个滤镜节点
                                            TimeLineNode* filterNode = *(filterNodes.begin());
                                            ////////////////////////////////////////////////////////////
                                            if(filter != NULL && filter != filterNode->node_data()){
                                                filter->Close();
                                            }
                                            ////////////////////////////////////////////////////////////
                                            filter = (FilterGroup*) filterNode->node_data();
                                            //
                                        }
                                        
                                        break;
                                    }
                                    case IMAGE_NODE:
                                        
                                        break;
                                        
                                    default:
                                        break;
                                } // end switch
                                
                            } // end if
                            
                        } // end vedioNodes
                        
                        break;
                    }
                    case AUDIO_TRACK:
                        break;
                    case TRANSITION_TRACK:
                        break;
                        
                    default:
                        break;
                } // end switch
                
            } // end iterator
            
            if (frameIndex == 0) {
                // 调用解码接口开始解码，获取帧图像
                videoClip->StartDecode();
                
                if (!video_processor_->isPreview) {
                    // ////////////////////////////////////////////
                    outVideoAsset->set_width(videoClip->asset()->width());
                    outVideoAsset->set_height(videoClip->asset()->height());
                    // ////////////////////////////////////////////
                    outVideoAsset->StartEncode();
                    
                    videoClip->asset()->set_media_Target(outVideoAsset->media_Target());
                    // 消除原音
                    videoClip->asset()->set_use_src_audio(!video_processor_->isMute);
                } else {// 预览
                    // 播放原音 fixme 声音未实现
                  //  AudioEffect::PlaySrcAudio(videoClip->asset()->uri());
                  //  AudioEffect::SetSrcPlayerMute(video_processor_->isMute);
                }
            }
        
        NSLog(@"%d\t", frameIndex);
            // 获取帧图像
            curFrame = videoClip->GetNextFrame();
            if (curFrame == NULL) {
                break;
                // 异常处理
            }
            
            // 2.调用特效接口处理帧图像
            if (filter != NULL) {
                filter->set_frame_index(frameIndex);
                curFrame = filter->ApplyEffect(curFrame, video_processor_->isPreview);
            }
            // 音频效果
            audioClips->set_frame_index(frameIndex);
            if (video_processor_->isPreview) {
                audioClips->ApplyEffect();
            } else {
                videoClip->asset()->set_audio_group(audioClips);
            }
            
            // ////////////////////////////////////////////////////
            // 计算处理进度
            if (video_processor_ != NULL) {
                if(callback_ != nil && !video_processor_->isPreview){
                    float convert_progress = frameIndex / (1.0f * totalFrame);
                    callback_->synProgress(convert_progress);
                }
            }
            if(video_processor_->isPreview){
                //时间控制
                 NSDate *date2 = [NSDate date];
                long interval = [date2 timeIntervalSinceDate:date1] * 1000;
                if(interval < video_processor_->FrameRate){
                    usleep((video_processor_->FrameRate - interval) * 1000);
                }
            }else{
                
                // 3.调用编码接口合成视频
                outVideoAsset->AppendFrame(curFrame);
            }
        
            // 必须全部处理完这一帧再++
            frameIndex++;
        } // end for
        
        if (!video_processor_->isPreview) {
            videoClip->asset()->set_media_Target(NULL); //防止析构两次 media_Target
            outVideoAsset->ColseEncode();
        }
        
        AudioEffect::StopSrcPlayer();
    
        if (videoClip != NULL) {
            if(videoClip->asset() != NULL){
                videoClip->asset()->CloseDecode();
            }
        }
        if (filter != NULL) {
            filter->Close();
        }
        if (audioClips != NULL) {
            audioClips->Close();
        }
        if(curFrame != NULL){
            //				curFrame.recycle();
        }
    
        AudioEffect::StopSrcPlayer();

    video_processor_->processedUri = outVideo;

    if(outVideoAsset != NULL) {
        delete outVideoAsset;
    }
    
    //if(!*stop_){
    if(1==*stop_){
        if(video_processor_->isPreview){
            //帧数不准，无法判断处理失败
            callback_->synSuccess((SYN_MESSAGE_ID)1);
        }else{
            callback_->synSuccess((SYN_MESSAGE_ID)2);
        }
    }
    return outVideo;
}


AudioGroup* VideoProjectUtils::GetAudioGroup(VideoProject* videoProject) {
    //
    AudioGroup *audioClips = new AudioGroup();
    TimeLineNode *renderTree = videoProject->video_template()->render_tree();
    list<TimeLineNode*> trackList = renderTree->child_node_list();
    for (list<TimeLineNode*>::iterator iterator = trackList.begin(); iterator != trackList.end(); iterator++) {
        TimeLineNode* track = *iterator;
        if (track->node_type() == AUDIO_TRACK) {
            list<TimeLineNode*> audioNodes = track->child_node_list();
            for (list<TimeLineNode*>::iterator iterator2 = audioNodes.begin(); iterator2 != audioNodes.end(); iterator2++) {
                TimeLineNode *audioNode = *iterator2;
                audioClips->AddAudio((AudioClip*) audioNode->node_data());
            }
            break;
        }
    }
    
    return audioClips;
}

/**
 * 一、简单应用，直接指定滤镜处理素材
 *
 * @param video
 *            素材
 * @param filterId
 *            滤镜类型
 * @return 处理后的视频文件
 */
string  VideoProjectUtils::ApplyFilter(string& filterId, list<string>& videos) {
    //
        list<MediaClip*> mediaClips = MediaMgr::BuildMediaClip(VIDEO, videos);
    
    //
        VideoTemplate *simpleTemplate = VideoTemplateUtils::CreateSimpleTemplate(filterId);
    
    VideoProject* project = new VideoProject(simpleTemplate);
    project->AddMedia(mediaClips);
    
    // processVideoUri = videos[0];
    
    return ExcuteProject(project);
}

/**
 * 二、选择模板，处理素材
 *
 * @param video
 *            素材
 * @param videoTemplateId
 *            视频处理模板
 * @return 处理后的视频文件
 */
string  VideoProjectUtils::ApplyVideoTemplate(string videoTemplateId, list<string>& videos) {
    
    list<MediaClip*> mediaClips = MediaMgr::BuildMediaClip(VIDEO, videos);
    
    //
    VideoTemplate *videoTemplate = VideoTemplateUtils::BuildFromXML(videoTemplateId);
    
//    VideoProject *project = new VideoProject(videoTemplate);
//    project->AddMedia(mediaClips);
    
    // processVideoUri = videos[0];
    
    VideoProject project(videoTemplate);
    project.AddMedia(mediaClips);
    
    return ExcuteProject(&project);
    
}

// 三、自定义模板（对一系列自定义操作的描述），或自定义模板元素（替换模板元素）
//

    
}
