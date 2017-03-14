//
//  CodecInterface.h
//  libCodec
//
//  Created by wangxiang on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef __libCodec__CodecInterface__
#define __libCodec__CodecInterface__

#include <iostream>

enum MediaFileInfoKey {
    kMediaFileInfoKeyDuration = 0,
    kMediaFileInfoKeyWidth,
    kMediaFileInfoKeyHeight
};

class IMediaSource {
public:
    virtual int open(const std::string &file_name) = 0;
    virtual void close() = 0;
    
    virtual int info(MediaFileInfoKey key) = 0;
    virtual unsigned char * next_video_frame() = 0;
    virtual unsigned char * next_audio_frame() = 0;
    
    virtual ~IMediaSource() {
        
    }
};

class IMediaTarget {
public:
    virtual int open(const std::string &file_name) = 0;
    virtual void close() = 0;
    
    virtual void set_info(MediaFileInfoKey key, int v) = 0;
    virtual void push_video_frame(unsigned char *video) = 0;
    virtual void push_audio_frame(unsigned char *audio) = 0;
    
    virtual ~IMediaTarget() {
        
    }
};

IMediaSource *CreateMediaSource(const std::string &file_name);
IMediaTarget *CreateMediaTarget(const std::string &file_name);

#endif /* defined(__libCodec__CodecInterface__) */
