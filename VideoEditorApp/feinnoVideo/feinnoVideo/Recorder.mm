//
//  Recorder.m
//  VideoShow
//
//  Created by coCo on 14-7-29.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import "Recorder.h"

#define knumberBuffers =    3
#define t_sample            UInt32
#define kSamplingRate       44100
#define kNumberChannels     1
#define kBitsPerChannels   (sizeof(t_sample) *8)
#define kBytesPerFrame      (kNumberChannels * sizeof(t_sample))
#define kFrameSize          1000


@implementation Recorder
@synthesize aqc;
@synthesize audioDataLength;

//AudioQueueNewInput(                 const AudioStreamBasicDescription *inFormat,
//                   AudioQueueInputCallback         inCallbackProc,
//                   void * __nullable               inUserData,
//                   CFRunLoopRef __nullable         inCallbackRunLoop,
//                   CFStringRef __nullable          inCallbackRunLoopMode,
//                   UInt32                          inFlags,
//                   AudioQueueRef __nullable * __nonnull outAQ)          __OSX_AVAILABLE_STARTING(__MAC_10_5,__IPHONE_2_0);
//
//typedef void (*AudioQueueInputCallback)(
//void * __nullable               inUserData,
//AudioQueueRef                   inAQ,
//AudioQueueBufferRef             inBuffer,
//const AudioTimeStamp *          inStartTime,
//UInt32                          inNumberPacketDescriptions,
//const AudioStreamPacketDescription * __nullable inPacketDescs);


static void AQInputCallback (void * __nullable inUserData,
                             AudioQueueRef          inAudioQueue,
                             AudioQueueBufferRef    inBuffer,
                             const AudioTimeStamp   * inStartTime,
                             UInt32          inNumPackets,
                             const AudioStreamPacketDescription * inPacketDesc)
{
    
    Recorder * engine = (__bridge Recorder *) inUserData;
    if (inNumPackets > 0)
    {
        [engine processAudioBuffer:inBuffer withQueue:inAudioQueue];
    }
    
    if (engine.aqc.run)
    {
        AudioQueueEnqueueBuffer(engine.aqc.queue, inBuffer, 0, NULL);
    }
}

- (id) init
{
    self = [super init];
    if (self)
    {
        aqc.mDataFormat.mSampleRate = kSamplingRate;
        aqc.mDataFormat.mFormatID = kAudioFormatLinearPCM;
        aqc.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger |kLinearPCMFormatFlagIsPacked;
        aqc.mDataFormat.mFramesPerPacket = 1;
        aqc.mDataFormat.mChannelsPerFrame = kNumberChannels;
        aqc.mDataFormat.mBitsPerChannel = kBitsPerChannels;
        aqc.mDataFormat.mBytesPerPacket = kBytesPerFrame;
        aqc.mDataFormat.mBytesPerFrame = kBytesPerFrame;
        aqc.frameSize = kFrameSize;
        
//        AudioQueueNewInput(&aqc.mDataFormat,
//                           AQInputCallback,
//                           (__bridge void*)(self),
//                           NULL,
//                           kCFRunLoopCommonModes,
//                           0,
//                           &aqc.queue);
        AudioQueueNewInput(&aqc.mDataFormat, AQInputCallback, NULL, NULL, kCFRunLoopCommonModes, 0, &aqc.queue);
//        AudioQueueNewInput(&aqc.mDataFormat,
//                           AQInputCallback,
//                           (__bridge void *)(self),
//                           NULL,
//                           kCFRunLoopCommonModes,
//                           0,
//                           &aqc.queue);
        
        for (int i=0;i<3;i++)
        {
            AudioQueueAllocateBuffer(aqc.queue, aqc.frameSize, &aqc.mBuffers[i]);
            AudioQueueEnqueueBuffer(aqc.queue, aqc.mBuffers[i], 0, NULL);
        }
        aqc.recPtr = 0;
        aqc.run = 1;
    }
    audioDataIndex = 0;
    return self;
}

- (void) dealloc
{
    AudioQueueStop(aqc.queue, true);
    aqc.run = 0;
    AudioQueueDispose(aqc.queue, true);
}

- (void) start
{
    AudioQueueStart(aqc.queue, NULL);
}

- (void) stop
{
    AudioQueueStop(aqc.queue, true);
}

- (void) pause
{
    AudioQueuePause(aqc.queue);
}

- (Byte *)getBytes
{
    return audioByte;
}

- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue
{
    NSLog(@"processAudioData :%ld", buffer->mAudioDataByteSize);
    //处理data
    memcpy(audioByte+audioDataIndex, buffer->mAudioData, buffer->mAudioDataByteSize);
    audioDataIndex +=buffer->mAudioDataByteSize;
    audioDataLength = audioDataIndex;
    NSLog(@"%ld",audioDataLength);
    NSLog(@"%ld",audioDataIndex);
}
@end
