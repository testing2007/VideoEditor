/*
 * video_template_timelinenode.h
 *
 *  Created on: 2014年9月1日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_TIMELINENODE_H_
#define VIDEO_TEMPLATE_TIMELINENODE_H_

#include "video_template_types.h"
#include <string>
#include <list>

#include "video_template_mediaclip.h"

namespace feinnovideotemplate {
using std::string;
using std::list;

class TimeLineNode {
public:
    TimeLineNode();
    virtual ~TimeLineNode();


    long getOutPoint() {
        return offset_ + duration_;
    }

public:  // 存取方法

    list<TimeLineNode*>& child_node_list()  {
        return child_node_list_;
    }

    void set_child_node_list(const list<TimeLineNode*>& childNodeList) {
        child_node_list_ = childNodeList;
    }

    long duration() const {
        return duration_;
    }

    void set_duration(long duration = 10 * 25) {
        duration_ = duration;
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


    NodeType node_type() const {
        return node_type_;
    }

    void set_node_type(NodeType nodeType) {
        node_type_ = nodeType;
    }

    long offset() const {
        return offset_;
    }

    void set_offset(long offset = 0) {
        offset_ = offset;
    }


    bool is_recycle() const {
        return is_recycle_;
    }

    void set_is_recycle(bool recycle) {
        is_recycle_ = recycle;
    }

    const TimeLineNode* parent_node() const {
        return parent_node_;
    }

    void set_parent_node( TimeLineNode* parentNode) {
        parent_node_ = parentNode;
    }

     MediaClip* node_data()  {
        return node_data_;
    }

    void set_node_data(MediaClip* nodeData) {
        node_data_ = nodeData;
    }

private:

    string id_;

    string name_;

    TimeLineNode* parent_node_;

    list<TimeLineNode*> child_node_list_;

    NodeType node_type_;

    MediaClip* node_data_;

    // 入点（精确帧）
    long offset_;

    // -->出点
    long duration_;

    // 是否对齐循环
    bool is_recycle_;

};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_TIMELINENODE_H_ */
