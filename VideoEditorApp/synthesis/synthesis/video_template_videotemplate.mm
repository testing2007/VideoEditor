/*
 * video_template_videotemplate.cpp
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#include "video_template_videotemplate.h"
#include "video_template_filterutils.h"
#include "video_template_filtergroup.h"

namespace feinnovideotemplate {

VideoTemplate::VideoTemplate():total_frame_(10 * 25),frame_rate_(25),render_tree_(NULL) {

}

VideoTemplate::VideoTemplate(const string& id):total_frame_(10 * 25),frame_rate_(25) ,render_tree_(NULL) {
   id_ = id;
}

VideoTemplate::~VideoTemplate() {
    // TODO Auto-generated destructor stub
    if(render_tree_ != NULL) {
        delete render_tree_;
        render_tree_ = NULL;
    }
}


void VideoTemplate::AddFilter(Filter* filter) {
    AddFilter(filter, -1);
}

void VideoTemplate::AddFilter(Filter* filter, int index) {
//fixme
    list<TimeLineNode*> &trackList = render_tree()->child_node_list();

    TimeLineNode *videoTrack = NULL;
    for (list<TimeLineNode*>::iterator iterator = trackList.begin(); iterator != trackList.end(); iterator++) {
        TimeLineNode *trackNode = *iterator;
        if (trackNode->node_type() == VIDEO_TRACK) {
            videoTrack = trackNode;
            break;
        }
    }

    list<TimeLineNode*> &videoNodes = videoTrack->child_node_list();
    TimeLineNode *videoNode = NULL;
    for (list<TimeLineNode*>::iterator iterator2 = videoNodes.begin(); iterator2 != videoNodes.end(); iterator2++) {
        videoNode = *iterator2;
        if (videoNode->node_data() != NULL) {
            continue;
        }
        // /////////////////////////////////////////////////

        TimeLineNode *filterNode = *(videoNode->child_node_list().begin());
        FilterGroup *filterGroup = (FilterGroup*)(filterNode->node_data());
        //
        if (index >= 0) {
            filterGroup->AddFilter(filter, index);
        } else {
            //
//            if (filterGroup->filters().size() > 0) {
//                Filter *lastFilter = *(filterGroup->filters().rbegin());
//                if (lastFilter->filter_type().find_first_of("BLEND") == 0) {
//                    Filter *blank = FilterUtils::BuildBlankFilter();
//                    blank->set_offset(filter->offset());
//                    blank->set_duration(filter->duration());
//                    filterGroup->AddFilter(blank);
//                }
//            } else if(filter->offset() > 0 || filter->duration() < videoNode->duration()){
//                Filter *blank = FilterUtils::BuildBlankFilter();
//                blank->set_offset(videoNode->offset());
//                blank->set_duration(videoNode->duration());
//                filterGroup->AddFilter(blank);
//            }
            //
            filterGroup->AddFilter(filter);
        }
    }

}

/**
 * 增加字幕素效果
 * @return
 */
void VideoTemplate::AddTittle(list<Tittle*> &tittles){

    // fixme
    list<TimeLineNode*> &trackList = render_tree()->child_node_list();

    TimeLineNode *tittleTrack = NULL;
    for (list<TimeLineNode*>::iterator iterator = trackList.begin(); iterator != trackList.end();) {
        TimeLineNode *trackNode = *iterator;
        if (trackNode->node_type() == TITTLE_TRACK) {
            tittleTrack = trackNode;
            break;
        }
        iterator++;
    }
    if (tittleTrack == NULL) {
        tittleTrack = new TimeLineNode();
        tittleTrack->set_name("Tittle");
        tittleTrack->set_node_type(TITTLE_TRACK);
        tittleTrack->set_parent_node(render_tree_);
        trackList.push_back(tittleTrack);
    }
//    //不可能为空，使用的list不是指针类型
//    if(tittleTrack->child_node_list() == NULL){
//        tittleTrack.setChildNodeList(new ArrayList<TimeLineNode>());
//    }

    for (list<Tittle*>::iterator i = tittles.begin(); i != tittles.end(); i++) {
        TimeLineNode *tittleNode = new TimeLineNode();
        tittleNode->set_node_type(TITTLE_NODE);
        tittleNode->set_offset((*i)->offset());
        tittleNode->set_duration((*i)->duration());
        tittleNode->set_node_data((*i));

        tittleTrack->child_node_list().push_back(tittleNode);
    }

}


/**
 * 增加音频效果
 * @return
 */
void VideoTemplate::AddAudio(list<AudioClip*> &audioClips) {
//fixme
    list<TimeLineNode*> &trackList = render_tree()->child_node_list();

    TimeLineNode *audioTrack = NULL;
    for (list<TimeLineNode*>::iterator iterator = trackList.begin(); iterator != trackList.end();) {
        TimeLineNode *trackNode = (*iterator);
        if (trackNode->node_type() == AUDIO_TRACK) {
            audioTrack = trackNode;
            break;
        }
        iterator++;
    }
    if (audioTrack == NULL) {
        audioTrack = new TimeLineNode();
        audioTrack->set_name("Audio");
        audioTrack->set_node_type(AUDIO_TRACK);
        audioTrack->set_parent_node(render_tree_);
        trackList.push_back(audioTrack);
    }
// list,不是指针类型。不会空
    //    if(audioTrack->child_node_list() == null){
//        audioTrack.setChildNodeList(new ArrayList<TimeLineNode>());
//    }

    for (list<AudioClip*>::iterator i = audioClips.begin(); i != audioClips.end(); i++) {
        TimeLineNode *audioNode = new TimeLineNode();
        audioNode->set_node_type(AUDIO_TRACK);
        audioNode->set_offset((*i)->offset());
        audioNode->set_duration((*i)->duration());
        audioNode->set_node_data((*i));
      //  (*i)->set_effect(NULL);

        audioTrack->child_node_list().push_back(audioNode);
    }

}

/**
 * 用本地音乐替换模板音乐
 * @return
 */
void VideoTemplate::AddMusic(AudioClip* music) {

    list<TimeLineNode*> &trackList = render_tree_->child_node_list();

    TimeLineNode *audioTrack = NULL;
    for (list<TimeLineNode*>::iterator iterator = trackList.begin(); iterator != trackList.end();iterator++) {
        TimeLineNode *trackNode = *iterator;
        if (trackNode->node_type() == AUDIO_TRACK) {
            audioTrack = trackNode;
            break;
        }
    }
    if (audioTrack == NULL) {
        audioTrack = new TimeLineNode();
        audioTrack->set_name("Audio");
        audioTrack->set_node_type(AUDIO_TRACK);
        audioTrack->set_parent_node(render_tree_);
        trackList.push_back(audioTrack);
    }
// list 不会为空
    //    if (audioTrack->child_node_list() == NULL) {
//        audioTrack.setChildNodeList(new ArrayList<TimeLineNode>());
//    }

    // fixme 删除第一个？？？
    if (audioTrack->child_node_list().size() > 0) {
        delete audioTrack->child_node_list().front();
        audioTrack->child_node_list().pop_front();
    }

    TimeLineNode *audioNode = new TimeLineNode();
    audioNode->set_node_type(AUDIO_TRACK);
    audioNode->set_offset(music->offset());
    audioNode->set_duration(music->duration());
    audioNode->set_node_data(music);
  //  music->set_effect(NULL);

    audioTrack->child_node_list().push_back(audioNode);
}


} /* namespace feinnovideotemplate */
