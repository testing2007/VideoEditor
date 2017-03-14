//
//  FMediaTarget.m
//  FVideo
//
//  Created by wangxiang on 14-9-11.
//  Copyright (c) 2014年 wangxiang. All rights reserved.
//

#import "FMediaTarget.h"

typedef struct {
    CVPixelBufferRef frameData;
    CMTime frameTime;
    int frameIndex;
} VideoFrameData;

typedef struct {
    CMSampleBufferRef audioData;
    CMTime audioTime;
    int frameIndex;
} AudioFrameData;

@implementation FMediaTarget {
    AVAssetWriter *_writer;
    AVAssetWriterInput *_audio_track_input;
    AVAssetWriterInput *_video_track_input;
    AVAssetWriterInputPixelBufferAdaptor *_pixel_buffer_adaptor;
    int _width;
    int _height;
    int _videoFrameIndex;
    int _audioFrameIndex;
    dispatch_queue_t _writeVideoQueue;
    dispatch_queue_t _writeAudioQueue;
    NSMutableArray *_videoFrameQueue;
    NSMutableArray *_audioFrameQueue;
    bool _videoFinished;
    bool _audioFinished;
    bool _fileFinished;
}

- (id)initWithURL:(NSURL *)outputURL fileType:(NSString *)outputFileType {
    unlink([[outputURL path] UTF8String]);
    
    NSError *error = nil;
    _videoFrameQueue = [[NSMutableArray alloc] init];
    _audioFrameQueue = [[NSMutableArray alloc] init];
    _videoFinished = false;
    _audioFinished = false;
    _fileFinished = false;
    
    _videoFrameIndex = 0;
    _audioFrameIndex = 0;
    _width = 480;
    _height = 480;
    _writer = [AVAssetWriter assetWriterWithURL:outputURL fileType:outputFileType error:&error];
    [self createAudioTrack];
    [self createVideoTrack];
    [_writer startWriting];
    [_writer startSessionAtSourceTime:kCMTimeZero];
    _writeVideoQueue = dispatch_queue_create("com.feinno.writevideo", nil);
    _writeAudioQueue = dispatch_queue_create("com.feinno.writeaudio", nil);
    
    [_video_track_input requestMediaDataWhenReadyOnQueue:_writeVideoQueue
                                              usingBlock:^{
        int count = [_videoFrameQueue count];
        if(_video_track_input.readyForMoreMediaData && count) {
            VideoFrameData frameData = {0};
            [[_videoFrameQueue objectAtIndex:0] getValue:&frameData];
            
            if (frameData.frameData) {
                [_pixel_buffer_adaptor appendPixelBuffer:frameData.frameData
                                    withPresentationTime:frameData.frameTime];
                CVPixelBufferRelease(frameData.frameData);
                NSLog(@"write pixel data index: %d; count of frame data: %d",
                                    frameData.frameIndex, count);
                
            } else {
                [_video_track_input markAsFinished];
                 _videoFinished = true;
            }
            [_videoFrameQueue removeObjectAtIndex:0];
            
        } else {
            usleep(10000);
        }
        
        if(_videoFinished && _audioFinished) {
            [_writer finishWritingWithCompletionHandler:^(void){
                _fileFinished = true;
            }];
        }
    }];
    
    [_audio_track_input requestMediaDataWhenReadyOnQueue:_writeAudioQueue
                                              usingBlock:^{
        int count = [_audioFrameQueue count];
        if(_audio_track_input.readyForMoreMediaData && count) {
            AudioFrameData audioData = {0};
            [[_audioFrameQueue objectAtIndex:0] getValue:&audioData];
            
            if (audioData.audioData) {
                [_audio_track_input appendSampleBuffer:audioData.audioData];
                CFRelease(audioData.audioData);
                NSLog(@"write audio data index: %d; count of audio data: %d",
                      audioData.frameIndex, count);
                
            } else {
                [_audio_track_input markAsFinished];
                _audioFinished = true;
            }
            [_audioFrameQueue removeObjectAtIndex:0];
            
        } else {
            usleep(10000);
        }
        
        if(_videoFinished && _audioFinished) {
            [_writer finishWritingWithCompletionHandler:^(void){
                _fileFinished = true;
            }];
        }
    }];
    
    return self;
}

- (void)pushAudioSample:(CMSampleBufferRef)sample {
    _audioFinished = false;
    dispatch_sync(_writeAudioQueue, ^{
        AudioFrameData tmpData = {0};
        tmpData.audioData = sample;
        tmpData.frameIndex = _audioFrameIndex++;
        [_audioFrameQueue addObject:[NSValue value:&tmpData withObjCType:@encode(AudioFrameData)]];
    });
}

- (void)pushPixelBuffer:(CVPixelBufferRef)frame withPresentationTime:(CMTime)tm {
    CVPixelBufferLockBaseAddress(frame, 0);
    unsigned char *frameData = (unsigned char *)CVPixelBufferGetBaseAddress(frame);
    [self pushVideoData:frameData withPresentationTime:tm];
    CVPixelBufferUnlockBaseAddress(frame, 0);
    CVPixelBufferRelease(frame);
}

- (void)pushVideoData:(unsigned char *)videoData withPresentationTime:(CMTime)tm {
    _videoFinished = false;
    dispatch_sync(_writeVideoQueue,
      ^{
        CVPixelBufferRef tmpBuffer = nil;
        CVPixelBufferPoolCreatePixelBuffer(nil, _pixel_buffer_adaptor.pixelBufferPool, &tmpBuffer);
        CVPixelBufferLockBaseAddress(tmpBuffer, 0);
        
        char *tmpData = (char *)CVPixelBufferGetBaseAddress(tmpBuffer);
        //size_t tmpDataSize = CVPixelBufferGetDataSize(tmpBuffer);
        memcpy(tmpData, videoData, _width * _height * 4);
          
        CVPixelBufferUnlockBaseAddress(tmpBuffer, 0);
        
        VideoFrameData tmpFrameData = {0};
        tmpFrameData.frameTime = tm;
        tmpFrameData.frameIndex = _videoFrameIndex++;
        tmpFrameData.frameData = tmpBuffer;
        
        [_videoFrameQueue addObject:[NSValue value:&tmpFrameData withObjCType:@encode(VideoFrameData)]];
    });
}

- (void)pushAudioData:(unsigned char *)audioData withPresentationTime:(CMTime)tm {
    //TODO: convert audioData to CMSampleBufferRef
    //pushAudioSample
}

- (void)close {
    [self closeVideoTrack];
    [self closeAudioTrack];
    while (!_fileFinished) {
        usleep(10000);
    }
}

- (void)closeVideoTrack {
    dispatch_sync(_writeVideoQueue, ^{
        VideoFrameData tmpFrameData = {0};
        [_videoFrameQueue addObject:[NSValue value:&tmpFrameData withObjCType:@encode(VideoFrameData)]];
    });
}

- (void)closeAudioTrack {
    dispatch_sync(_writeAudioQueue, ^{
        AudioFrameData tmpAudioData = {0};
        [_audioFrameQueue addObject:[NSValue value:&tmpAudioData withObjCType:@encode(AudioFrameData)]];
    });
}

- (void)createAudioTrack {
    AudioChannelLayout acl;
    bzero(&acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *settings = @{
                               AVFormatIDKey :          @(kAudioFormatMPEG4AAC),
                               AVNumberOfChannelsKey :  @(2),
                               AVSampleRateKey :        @(44100),
                               AVEncoderBitRateKey :    @(64000),
                               AVChannelLayoutKey :     [NSData dataWithBytes:&acl length:sizeof(acl)]
                               };
    _audio_track_input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                            outputSettings:settings];
    [_writer addInput:_audio_track_input];
}

- (void)createVideoTrack {
    NSDictionary *settings = @{
                               AVVideoCodecKey :  AVVideoCodecH264,
                               AVVideoWidthKey :  @(_width),
                               AVVideoHeightKey : @(_height)
                               };
    _video_track_input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                            outputSettings:settings];
    [_writer addInput:_video_track_input];
    
    NSDictionary *buffer_attributes = @{
                        (id)kCVPixelBufferPixelFormatTypeKey :    @(kCVPixelFormatType_32BGRA),
                        (id)kCVPixelBufferWidthKey :              @(_width),
                        (id)kCVPixelBufferHeightKey :             @(_height),
                        (id)kCVPixelFormatOpenGLESCompatibility : @(NO)};
    _pixel_buffer_adaptor = [AVAssetWriterInputPixelBufferAdaptor
                             assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_video_track_input
                                                        sourcePixelBufferAttributes:buffer_attributes];
}

@end
