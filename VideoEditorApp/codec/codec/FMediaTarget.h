//
//  FMediaTarget.h
//  FVideo
//
//  Created by wangxiang on 14-9-11.
//  Copyright (c) 2014年 wangxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <CoreMedia/CoreMedia.h>

@interface FMediaTarget : NSObject

- (id)initWithURL:(NSURL *)outputURL fileType:(NSString *)outputFileType;
- (void)close;

- (void)pushAudioSample:(CMSampleBufferRef)sample;
- (void)pushPixelBuffer:(CVPixelBufferRef)frame withPresentationTime:(CMTime)tm;
- (void)pushVideoData:(unsigned char *)videoData withPresentationTime:(CMTime)tm;
- (void)pushAudioData:(unsigned char *)audioData withPresentationTime:(CMTime)tm;

@end
