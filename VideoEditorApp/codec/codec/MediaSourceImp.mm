//
//  MediaSourceImp.cpp
//  libCodec
//
//  Created by wangxiang on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#include "MediaSourceImp.h"

void CMediaSource::close() {
    if (image_buffer_) {
        free(image_buffer_);
        image_buffer_ = nil;
    }
    if (pcm_buffer_) {
        free(pcm_buffer_);
        pcm_buffer_ = nil;
    }
    [source_ close];
}

int CMediaSource::open(const std::string &file_name) {
    NSURL *file_url = [NSURL fileURLWithPath:@(file_name.c_str())];
    source_ = [[FMediaSource alloc] initWithURL:file_url setBGRA32Pixel:YES];
    
    if(!source_) {
        return -1;
    }
    duration_ = source_.durationMiliSecond;
    width_ = source_.width;
    height_ = source_.height;
    
    if(width_ && height_) {
        image_buffer_ = (unsigned char *)malloc(width_ * height_ * 4 + 1024);
    }
    pcm_buffer_ = (unsigned char *)malloc(kAudioBufferLength + 1024);
    video_frame_index_ = 0;
    last_video_frame_pts_ = 0;
    return 0;
}

size_t CMediaSource::copy_audio_sample_data(size_t len, unsigned char *des_buffer) {
    if(!last_audio_sample_) {
        last_audio_sample_ = [source_ nextAudioSample];
        offset_audio_block_buffer_ = 0;
        
        if(!last_audio_sample_)
            return 0;
    }
    
    CMBlockBufferRef audio_block_buffer = CMSampleBufferGetDataBuffer(last_audio_sample_);
    size_t audio_block_buffer_len = CMBlockBufferGetDataLength(audio_block_buffer) - offset_audio_block_buffer_;
    
    if (audio_block_buffer_len > len) {
        CMBlockBufferCopyDataBytes(audio_block_buffer, offset_audio_block_buffer_, len, des_buffer);
        offset_audio_block_buffer_ += len;
        return len;
        
    } else {
        CMBlockBufferCopyDataBytes(audio_block_buffer, offset_audio_block_buffer_, audio_block_buffer_len, des_buffer);
        CFRelease(last_audio_sample_);
        last_audio_sample_ = nullptr;
        return audio_block_buffer_len;
    }
    
    return 0;
}

unsigned char * CMediaSource::next_audio_frame() {
    int needed_audio_data_len = kAudioBufferLength;
    unsigned char *des_buffer = pcm_buffer_;
    
    while (needed_audio_data_len > 0) {
        int copied_audio_data_len = copy_audio_sample_data(needed_audio_data_len, des_buffer);
        if (!copied_audio_data_len) {
            if (needed_audio_data_len == kAudioBufferLength) {
                return nullptr;
            }
            break;
        }
        
        des_buffer += copied_audio_data_len;
        needed_audio_data_len -= copied_audio_data_len;
    }
    
    return pcm_buffer_;
}

unsigned char * CMediaSource::next_video_frame() {
    float timeIn25fps = (float)video_frame_index_ / 25;
    if ((timeIn25fps + 0.01) < last_video_frame_pts_) {
        video_frame_index_ ++;
        NSLog(@"duplicate frame at index: %d", video_frame_index_);
        return image_buffer_;
    }
    
    CMSampleBufferRef video_sample = [source_ nextVideoSample];
    if (!video_sample) {
        return nil;
    }
    
    CMTime video_frame_tm = CMSampleBufferGetPresentationTimeStamp(video_sample);
    last_video_frame_pts_ = (float)video_frame_tm.value / video_frame_tm.timescale;
    CVPixelBufferRef video_pixel_buffer = CMSampleBufferGetImageBuffer(video_sample);
    CVPixelBufferLockBaseAddress(video_pixel_buffer, 0);
    
    unsigned char *baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(video_pixel_buffer);
    size_t dataSize = CVPixelBufferGetDataSize(video_pixel_buffer);
    memcpy(image_buffer_, baseAddress, dataSize);
    
    CVPixelBufferUnlockBaseAddress(video_pixel_buffer, 0);
    CFRelease(video_sample);
    video_frame_index_ ++;
    return image_buffer_;
}

int CMediaSource::info(MediaFileInfoKey key) {
    switch (key) {
        case kMediaFileInfoKeyDuration:
            return duration_;
            
        case kMediaFileInfoKeyWidth:
            return width_;
            
        case kMediaFileInfoKeyHeight:
            return height_;
            
        default:
            break;
    }
    return 0;
}