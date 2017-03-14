//
//  FMediaSource.h
//  FVideo
//
//  Created by wangxiang on 14-9-2.
//  Copyright (c) 2014年 wangxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetReader.h>
#import <AVFoundation/AVFoundation.h>

@interface FMediaSource : NSObject

@property(readonly) NSURL *sourceVideoURL;
@property(readonly) int durationMiliSecond;
@property(readonly) int width;
@property(readonly) int height;

- (id)initWithURL:(NSURL *)url setBGRA32Pixel:(BOOL)isRGB;
- (CMSampleBufferRef)nextVideoSample;
- (CMSampleBufferRef)nextAudioSample;
- (void)close;

@end
