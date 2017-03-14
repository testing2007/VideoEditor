//
//  MediaSourceImp.h
//  libCodec
//
//  Created by wangxiang on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef __libCodec__MediaSourceImp__
#define __libCodec__MediaSourceImp__

#include <iostream>
#include "CodecInterface.h"
#include "FMediaSource.h"

class CMediaSource : public IMediaSource {
 public:
    virtual int open(const std::string &file_name);
    virtual void close();
    
    virtual unsigned char * next_video_frame();
    virtual unsigned char * next_audio_frame();
    virtual int info(MediaFileInfoKey key);
    
    CMediaSource(const std::string file_name) :
        source_(nil),
        image_buffer_(nil),
        pcm_buffer_(nullptr),
        width_(0),
        height_(0),
        duration_(0),
        audio_frame_index_(0),
        video_frame_index_(0),
        last_video_frame_pts_(0),
        last_audio_sample_(nullptr),
        offset_audio_block_buffer_(0) {
    }
    
private:
    size_t copy_audio_sample_data(size_t len, unsigned char *des_buffer);
    
private:
    const size_t kAudioBufferLength = 2 * 2 * 1024;
    
    FMediaSource *source_;
    unsigned char *image_buffer_;
    unsigned char *pcm_buffer_;
    int width_;
    int height_;
    int duration_;
    int audio_frame_index_;
    int video_frame_index_;
    float last_video_frame_pts_;
    CMSampleBufferRef last_audio_sample_;
    size_t offset_audio_block_buffer_;
};

#endif /* defined(__libCodec__MediaSourceImp__) */
