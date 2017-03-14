/*
 * video_template_videoasset.cpp
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#include "video_template_videoasset.h"

#include <GPUImage.h>

namespace feinnovideotemplate {

VideoAsset::VideoAsset() : media_source_(NULL), media_target_(NULL),audio_group_(NULL),duration_(-1),audio_buffer_getted_(1),height_(480),width_(480) {
    set_asset_type(VIDEO);
}

VideoAsset::~VideoAsset() {
    // TODO Auto-generated destructor stub
    CloseDecode();
    ColseEncode();
    
    if(audio_group_ != NULL) {
        delete audio_group_;
        audio_group_ = NULL;
    }
    
    printf("~VideoAsset %s", uri().c_str());
}


void VideoAsset::StartDecode() {
    if (media_source_ != NULL) {
        return;
    }
    media_source_ = CreateMediaSource("");
    int opencode = media_source_->open(uri());
    if (opencode != 0) {
        // 异常处理
        printf("open source fail:%d @ %s", opencode, uri().c_str());
    }
    printf( "startDecode: %s @ %p", uri().c_str() , media_source_);
}

    
    const int samplesize_test = 1024*2*2*10; //保证够用
   // static unsigned char* pcmData = (unsigned char*)malloc(samplesize_test);
    
//    static CMSampleBufferRef createAudioref(){
//        
//        
//        
//        OSStatus stat;
//        
//        AudioStreamBasicDescription asbd;
//        
//        ///设置音频参数
//        asbd.mSampleRate = 44100;//采样率
//        asbd.mFormatID = kAudioFormatLinearPCM;
//        asbd.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
//        asbd.mChannelsPerFrame = 2;///单声道
//        asbd.mFramesPerPacket = 1;//每一个packet一侦数据
//        asbd.mBitsPerChannel = 16;//每个采样点16bit量化
//        asbd.mBytesPerFrame = (asbd.mBitsPerChannel/8) * asbd.mChannelsPerFrame;
//        asbd.mBytesPerPacket = asbd.mBytesPerFrame ;
//        
//        CMTime audio_frame_time_;
//        audio_frame_time_.timescale = 44100;
//        audio_frame_time_.flags = kCMTimeFlags_Valid;
//        audio_frame_time_.value = 0;
//        
//        //    CMFormatDescriptionRef cm = NULL;
//        //    stat = CMFormatDescriptionCreate(kCFAllocatorDefault, kCMMediaType_Audio, NULL, NULL, &cm);
//        
//        CMAudioFormatDescriptionRef acm;
//        stat = CMAudioFormatDescriptionCreate(kCFAllocatorDefault, &asbd, 0, NULL, 0, NULL, NULL, &acm);
//        
//        CMBlockBufferRef cmref;
//        //  stat = CMBlockBufferCreateEmpty(NULL, 1, kCMBlockBufferAssureMemoryNowFlag, &cmref);
//        
//        //
//        stat =  CMBlockBufferCreateWithMemoryBlock(NULL, pcmData, samplesize_test, kCFAllocatorNull, NULL, 0, samplesize_test, kCMBlockBufferAssureMemoryNowFlag, &cmref);
//        //kCFAllocatorNull
//        
//        CMSampleBufferRef ss;
//        stat = CMAudioSampleBufferCreateWithPacketDescriptions(kCFAllocatorDefault, cmref, true, NULL, NULL, acm, 1024, audio_frame_time_, NULL, &ss);
//        
//
//        return ss;
//    }
    
// //测试代码，音频 unsigned  char* 转 CMSampleBufferRef
//    static unsigned char* testaudioref(unsigned char* ref){
//        
//        unsigned char* pcmData = (unsigned char*)malloc(samplesize_test);
////        
////        static CMSampleBufferRef outref = createAudioref();
////        CMBlockBufferRef outbuffer = CMSampleBufferGetDataBuffer(outref);
////        AudioBufferList outList;
////        
////        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(outref,
////                                                                NULL,
////                                                                &outList,
////                                                                sizeof(outList),
////                                                                NULL,
////                                                                NULL,
////                                                                kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
////                                                                &outbuffer
////                                                                );
////        NSLog(@"out buffer count %d",outList.mNumberBuffers);
//        //========================
//        
//        CMSampleBufferRef inref = (CMSampleBufferRef)ref;
//        
//        
//        
//        CMBlockBufferRef buffer = CMSampleBufferGetDataBuffer(inref);
//        CMItemCount numSamplesInBuffer = CMSampleBufferGetNumSamples(inref);
//        AudioBufferList audioBufferList;
//        
//        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(inref,
//                                                                NULL,
//                                                                &audioBufferList,
//                                                                sizeof(audioBufferList),
//                                                                NULL,
//                                                                NULL,
//                                                                kCMSampleBufferFlag_AudioBufferList_Assure16ByteAlignment,
//                                                                &buffer
//                                                                );
//        //passing a live pointer to the audio buffers, try to process them in-place or we might have syncing issues.
//        for (int bufferCount=0; bufferCount < audioBufferList.mNumberBuffers; bufferCount++) {
//            SInt16 *samples = (SInt16 *)audioBufferList.mBuffers[bufferCount].mData;
//            
//            memcpy( pcmData, samples, audioBufferList.mBuffers[bufferCount].mDataByteSize);
////            
////            outList.mBuffers[0].mDataByteSize = audioBufferList.mBuffers[bufferCount].mDataByteSize;
////            outList.mBuffers[0].mNumberChannels = audioBufferList.mBuffers[bufferCount].mNumberChannels;
//            
//            
//         //++++++++++++++++++++++++++++++++++++++++++++++++++++++
//            CMAudioFormatDescriptionRef audio_fmt_desc_ = nil;
//            int nchannels = 2;
//            AudioStreamBasicDescription audioFormat;
//            bzero(&audioFormat, sizeof(audioFormat));
//            audioFormat.mSampleRate = 44100;
//            audioFormat.mFormatID   = kAudioFormatLinearPCM;
//            audioFormat.mFramesPerPacket = 1;
//            audioFormat.mChannelsPerFrame = nchannels;
//            int bytes_per_sample = sizeof(short);
//            audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsAlignedHigh;
//            audioFormat.mBitsPerChannel = bytes_per_sample * 8;
//            audioFormat.mBytesPerPacket = bytes_per_sample * nchannels;
//            audioFormat.mBytesPerFrame = bytes_per_sample * nchannels;
//            
//            CMAudioFormatDescriptionCreate(kCFAllocatorDefault,
//                                           &audioFormat,
//                                           0,
//                                           NULL,
//                                           0,
//                                           NULL,
//                                           NULL,
//                                           &audio_fmt_desc_
//                                           );
//            
//            //NSLog(@"writeAudioBuffer");
//            OSStatus status;
//            CMBlockBufferRef bbuf = NULL;
//            CMSampleBufferRef sbuf = NULL;
//            
//            size_t buflen = audioBufferList.mBuffers[bufferCount].mDataByteSize;//n * nchans * 2;
//            // Create sample buffer for adding to the audio input.
//            status = CMBlockBufferCreateWithMemoryBlock(
//                                                        kCFAllocatorDefault,
//                                                        pcmData,
//                                                        //samples,
//                                                        buflen,
//                                                        kCFAllocatorNull,
//                                                        NULL,
//                                                        0,
//                                                        buflen,
//                                                        0,
//                                                        &bbuf);
//            
//            if (status != noErr) {
//                NSLog(@"CMBlockBufferCreateWithMemoryBlock error");
//               // return -1;
//            }
//            static int sample_position_ = 0;
//            CMTime timestamp = CMTimeMake(sample_position_, 44100);
//            sample_position_ += numSamplesInBuffer;//n;
//            
//            status = CMAudioSampleBufferCreateWithPacketDescriptions(kCFAllocatorDefault, bbuf, TRUE, 0, NULL, audio_fmt_desc_, numSamplesInBuffer, timestamp, NULL, &sbuf);
//            
//            return (unsigned char*)sbuf;
//            //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//        }
//        
//        
//        return NULL;// (unsigned char *)outref;
//    }
    
    
unsigned char* VideoAsset::GetNextFrame() {
    unsigned char* currentFrame = media_source_->next_video_frame();
    
  //  toImage(currentFrame);
    
    
    //取音频
    if (media_target_ != NULL) {

        if (audio_group_ != NULL) {
            // 取一次视频同时取2次声音，视频结束后把音频取完
//            while( ++audio_buffer_getted_ % 3 == 0 ||
//                  currentFrame != NULL)
            for(int i=0;i<2;i++)
            {
                //NSLog(@"get audio %d\t",audio_buffer_getted_);
                unsigned char* audio_buffer = audio_group_->MixAudio(
                          media_source_->next_audio_frame(), use_src_audio_,
                          SAMPLES_COUNT_PER_AUDIO_BUFFER);
                if(audio_buffer != NULL){
                    
                    //测试代码
                 //   audio_buffer = testaudioref(audio_buffer);
                    
                    // 混音
                    media_target_->push_audio_frame(audio_buffer);
                } else {
                    break;
                }
            }
            
        }
    }
    
    // 移动游标
    cursor_++;
    printf("%s\t%ld\n", uri().c_str(),cursor_);
    if (cursor_ >= duration() || currentFrame == NULL) {
        CloseDecode();
        return NULL;
    }
    
    return currentFrame;

}

void VideoAsset::CloseDecode() {
    if (media_source_ != NULL) {
        media_source_->close();
        printf("closeDecode: %s @ %p", uri().c_str(), media_source_);
        delete media_source_;
        media_source_ = NULL;
        cursor_ = 0;
    }
}

void VideoAsset::StartEncode() {
    if (media_target_ != NULL) {
        return;
    }
    media_target_ = CreateMediaTarget("");
    int err = media_target_->open(uri());
  
    printf("media target %p open %s renturn %d", media_target_, uri().c_str(), err);
}

void VideoAsset::AppendFrame(unsigned char* frame) {
    media_target_->push_video_frame(frame);
}

void VideoAsset::ColseEncode() {
    if (media_target_ != NULL) {
        media_target_->close();
        printf( "colseEncode:%p", media_target_);
        delete media_target_;
        media_target_ = NULL;
    }
}


} /* namespace feinnovideotemplate */
