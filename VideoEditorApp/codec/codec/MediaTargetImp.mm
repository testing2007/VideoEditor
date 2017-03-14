//
//  MediaTargetImp.cpp
//  libCodec
//
//  Created by wangxiang on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#include "MediaTargetImp.h"


int CMediaTarget::open(const std::string &file_name) {
    audio_sample_count_ = 0;
    video_frame_count_ = 0;
    
    video_frame_time_.timescale = 25;
    video_frame_time_.flags = kCMTimeFlags_Valid;
    video_frame_time_.value = 0;
    
    audio_frame_time_.timescale = 44100;
    audio_frame_time_.flags = kCMTimeFlags_Valid;
    audio_frame_time_.value = 0;
    
    int nchannels = 2;
    AudioStreamBasicDescription audioFormat = {0};
    audioFormat.mSampleRate = 44100;
    audioFormat.mFormatID   = kAudioFormatLinearPCM;
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mChannelsPerFrame = 2;
    int bytes_per_sample = sizeof(short);
    audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsAlignedHigh;
    audioFormat.mBitsPerChannel = bytes_per_sample * 8;
    audioFormat.mBytesPerPacket = bytes_per_sample * nchannels;
    audioFormat.mBytesPerFrame = bytes_per_sample * nchannels;
    
    CMAudioFormatDescriptionCreate(kCFAllocatorDefault,
                                   &audioFormat,
                                   0,
                                   NULL,
                                   0,
                                   NULL,
                                   NULL,
                                   &audio_fmt_desc_
                                   );
    
    NSURL *file_url = [NSURL fileURLWithPath:@(file_name.c_str())];
    target_ = [[FMediaTarget alloc] initWithURL:file_url fileType:AVFileTypeMPEG4];
    
    if(!target_) {
        return -1;
    }
    return 0;
}
void CMediaTarget::close() {
    [target_ close];
}

void CMediaTarget::set_info(MediaFileInfoKey key, int v) {
    
}

void CMediaTarget::push_video_frame(unsigned char *video) {
    video_frame_time_.value = video_frame_count_;
    [target_ pushVideoData:video withPresentationTime:video_frame_time_];
    video_frame_count_ ++;
}

void CMediaTarget::push_audio_frame(unsigned char *audio) {
    unsigned char *tmp_audio_buffer = (unsigned char *)malloc(1024 * 2 * 2 + 1024);
    memcpy(tmp_audio_buffer, audio, 1024 * 2 * 2);
    audio_frame_time_.value = 0;
    CMBlockBufferRef audio_block_buffer = nullptr;
    CMSampleBufferRef audio_sample = nullptr;
    CMBlockBufferCreateWithMemoryBlock(
                                       kCFAllocatorDefault,
                                       tmp_audio_buffer,
                                       1024 * 2 * 2,
                                       kCFAllocatorNull,
                                       nullptr,
                                       0,
                                       1024 * 2 * 2,
                                       0,
                                       &audio_block_buffer);
    CMAudioSampleBufferCreateWithPacketDescriptions(
                                                    nullptr,
                                                    audio_block_buffer,
                                                    TRUE,
                                                    0,
                                                    nullptr,
                                                    audio_fmt_desc_,
                                                    1024,
                                                    audio_frame_time_,
                                                    NULL,
                                                    &audio_sample);
    [target_ pushAudioSample:audio_sample];
}