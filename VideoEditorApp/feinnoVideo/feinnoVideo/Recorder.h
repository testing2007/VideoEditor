//
//  Recorder.h
//  VideoShow
//
//  Created by coCo on 14-7-29.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AudioToolbox/AudioToolbox.h>

#define knumberBuffers =    3
#define t_sample            UInt32
#define kSamplingRate       44100
#define kNumberChannels     1
#define kBitsPerChannels   (sizeof(t_sample) *8)
#define kBytesPerFrame      (kNumberChannels * sizeof(t_sample))
#define kFrameSize          1000
//typedef struct AQCallbackStruct
//{
//    AudioStreamBasicDescription mDataFormat;
//    AudioQueueRef               queue;
//    AudioQueueBufferRef         mBuffers;
//    AudioFileID                 outputFile;
//    
//    unsigned long               frameSize;
//    long long                   recPtr;
//    int                         run;
//} AQCallbackStruct;
//
//
//@interface Recorder: NSObject
//{
//    AQCallbackStruct aqc;
//    AudioFileTypeID fileFormat;
//}
//
//- (id) init;
//- (void) start;
//- (void) stop;
//- (void) pause;
//
//- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue;
//
//@property (nonatomic, assign) AQCallbackStruct aqc;
typedef struct AQCallbackStruct
{
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         mBuffers[3];
    AudioFileID                 outputFile;
    
    unsigned long               frameSize;
    long long                   recPtr;
    int                         run;
    
} AQCallbackStruct;


@interface Recorder : NSObject
{
    AQCallbackStruct aqc;
    AudioFileTypeID fileFormat;
    long audioDataLength;
    Byte audioByte[999999];
    long audioDataIndex;
}
- (id) init;
- (void) start;
- (void) stop;
- (void) pause;
- (Byte *) getBytes;
- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue;

@property (nonatomic, assign) AQCallbackStruct aqc;
@property (nonatomic, assign) long audioDataLength;
@end
