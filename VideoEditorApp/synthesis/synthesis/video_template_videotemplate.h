/*
 * video_template_videotemplate.h
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_VIDEOTEMPLATE_H_
#define VIDEO_TEMPLATE_VIDEOTEMPLATE_H_

#include <string>
#include <list>

#include "video_template_timelinenode.h"
#include "video_template_audioclip.h"
#include "video_template_filter.h"
#include "video_template_tittle.h"

namespace feinnovideotemplate {
using std::string;
using std::list;

/**
 *
 * 视频处理模板
 *
 */
class VideoTemplate {
public:
    VideoTemplate();
    VideoTemplate(const string& id);
    virtual ~VideoTemplate();


    void AddFilter(Filter* filter);
    void AddFilter(Filter* filter, int index);
    void AddTittle(list<Tittle*> &tittles);
    void AddAudio(list<AudioClip*> &audioClips);
    void AddMusic(AudioClip* music);


public: //[ ===== 存取方法 ======
    int frame_rate() const {
        return frame_rate_;
    }

    void set_frame_rate(int frameRate) {
        frame_rate_ = frameRate;
    }

    int height() const {
        return height_;
    }

    void set_height(int height) {
        height_ = height;
    }

    const string& id() const {
        return id_;
    }

    void set_id(const string& id) {
        id_ = id;
    }

    const string& name() const {
        return name_;
    }

    void set_name(const string& name) {
        name_ = name;
    }

    TimeLineNode* render_tree() {
        return render_tree_;
    }

    void set_render_tree(TimeLineNode* renderTree) {
        render_tree_ = renderTree;
    }

    long total_frame() const {
        return total_frame_;
    }

    void set_total_frame(long totalFrame) {
        total_frame_ = totalFrame;
    }

    int width() const {
        return width_;
    }

    void set_width(int width) {
        width_ = width;
    }
    //] ===== 存取方法 ======

private:

    string id_;

    string name_;

    // 总时长（帧）
    long total_frame_;

    // 帧率
    int frame_rate_;

    // frameSize
    int width_;

    int height_;

    // 渲染树
    TimeLineNode* render_tree_;


};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_VIDEOTEMPLATE_H_ */
