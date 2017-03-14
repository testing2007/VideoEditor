/*
 * video_template_videoclip.cpp
 *
 *  Created on: 2014年9月3日
 *      Author: 尚博才
 */

#include "video_template_videoclip.h"

namespace feinnovideotemplate {

VideoClip::VideoClip():MediaClip() {
    // TODO Auto-generated constructor stub

}

VideoClip::VideoClip( Asset* asset):MediaClip(asset) {

}

VideoClip::~VideoClip() {
    // TODO Auto-generated destructor stub
}


void VideoClip::StartDecode() {
    asset()->StartDecode();
    // 跳转到素材入点
    if (offset() > asset()->cursor()) {
        int deffer = (int) (offset() - asset()->cursor());
        for (int i = 0; i < deffer; i++) {
            GetNextFrame();
        }
    }
}

unsigned char* VideoClip::GetNextFrame() {
    unsigned char* curFrame = asset()->GetNextFrame();
    // 当素材到达出点，关闭解码文件
//      if(getAsset().getCursor() == getOutPoint()){
//          getAsset().closeDecode();
//      }
    return curFrame;
}

} /* namespace feinnovideotemplate */
