/*
 * video_template_timelinenode.cpp
 *
 *  Created on: 2014年9月1日
 *      Author: 尚博才
 */

#include "video_template_timelinenode.h"

namespace feinnovideotemplate {

TimeLineNode::TimeLineNode():offset_(0),duration_(10 * 25),parent_node_(NULL),node_data_(NULL) {
    // TODO Auto-generated constructor stub

}

TimeLineNode::~TimeLineNode() {
    // TODO Auto-generated destructor stub
    
    if(node_data_ != NULL){
        delete node_data_;
        node_data_ = NULL;
    }
    
    parent_node_ = NULL;
    if(child_node_list_.size() >0 ) {
        for(list<TimeLineNode*>::iterator iter = child_node_list_.begin();iter != child_node_list_.end();iter++) {
            delete *iter;
        }
        child_node_list_.clear();
    }
        
}

} /* namespace feinnovideotemplate */
