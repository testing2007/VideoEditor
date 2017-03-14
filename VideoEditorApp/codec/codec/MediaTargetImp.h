//
//  MediaTargetImp.h
//  libCodec
//
//  Created by wangxiang on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef __libCodec__MediaTargetImp__
#define __libCodec__MediaTargetImp__

#include <iostream>
#include "CodecInterface.h"

#include "FMediaTarget.h"

class CMediaTarget : public IMediaTarget {
public:
    virtual int open(const std::string &file_name);
    virtual void close();
    
    virtual void set_info(MediaFileInfoKey key, int v);
    virtual void push_video_frame(unsigned char *video);
    virtual void push_audio_frame(unsigned char *audio);
    
    CMediaTarget(const std::string &file_name) :
        target_(nil),
        audio_sample_count_(0),
        video_frame_count_(0),
        video_frame_time_{ 0 },
        audio_frame_time_{ 0 },
        audio_fmt_desc_{ nullptr }{
    }
        
private:
    FMediaTarget *target_;
    int audio_sample_count_;
    int video_frame_count_;
    CMTime video_frame_time_;
    CMTime audio_frame_time_;
    CMAudioFormatDescriptionRef audio_fmt_desc_;
};

#endif /* defined(__libCodec__MediaTargetImp__) */
