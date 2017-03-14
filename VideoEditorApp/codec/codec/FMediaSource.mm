//
//  FMediaSource.m
//  FVideo
//
//  Created by wangxiang on 14-9-2.
//  Copyright (c) 2014年 wangxiang. All rights reserved.
//

#import "FMediaSource.h"
#import <AVFoundation/AVAssetReaderOutput.h>
#import <AVFoundation/AVMediaFormat.h>

@implementation FMediaSource {
    AVAsset *_asset;
    AVAssetReader *_reader;
    AVAssetReaderTrackOutput *_video_track_output;
    AVAssetReaderTrackOutput *_audio_track_output;
    CMTime _currentVideoTime;
    CMTime _currentAudioTime;
    bool _isRGB;
    bool _hasVideo;
    bool _statePause;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CMTime)currentTime {
    if(_hasVideo)
        return _currentVideoTime;
    
    return _currentAudioTime;
}

- (void)pauseReading {
    NSLog(@"media source pause reading");
    _statePause = true;
    [self close];
}

- (void)startReading {
    NSLog(@"media source start reading");
    NSError *error = nil;
    _reader = [AVAssetReader assetReaderWithAsset:_asset error:&error];
    [self openAudio];
    [self openVideo:_isRGB];
    
    _reader.timeRange = CMTimeRangeMake([self currentTime], kCMTimePositiveInfinity);
    [_reader startReading];
}

- (id)initWithURL:(NSURL *)url setBGRA32Pixel:(BOOL)isRGB {
    if(!(self = [super init])) {
        return nil;
    }
    _isRGB = isRGB;
    _sourceVideoURL = url;
    _hasVideo = false;
    _statePause = false;
    _asset = [[AVURLAsset alloc] initWithURL:_sourceVideoURL options:nil];
    
    CMTime duration = [_asset duration];
    _durationMiliSecond = (int) (duration.value * 1000 / duration.timescale);
    
    _currentVideoTime = kCMTimeZero;
    _currentAudioTime = kCMTimeZero;
    [self startReading];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseReading) name:@"FMEDIA_PAUSE" object:nil];
    return self;
}

- (void)openAudio {
    NSArray *audio_tracks = [_asset tracksWithMediaType:AVMediaTypeAudio];
    if ([audio_tracks count]) {
        _audio_track_output =
            [AVAssetReaderTrackOutput
                assetReaderTrackOutputWithTrack:audio_tracks[0]
                                 outputSettings:@{AVFormatIDKey: @(kAudioFormatLinearPCM)}];
        _audio_track_output.alwaysCopiesSampleData = NO;
    }
    if(_audio_track_output) [_reader addOutput:_audio_track_output];
}

//[NSNotificationCenter defaultCenter] addObserver:self selector:ASAS name:"ASASASAASAS" object:nil
- (void)openVideo:(BOOL)isRGB {
    NSArray *video_tracks = [_asset tracksWithMediaType:AVMediaTypeVideo];
    if ([video_tracks count]) {
        _hasVideo = true;
        AVAssetTrack *track = video_tracks[0];
        _width = track.naturalSize.width;
        _height = track.naturalSize.height;
        int pixelFormat = 0;
        if (isRGB) {
            pixelFormat = kCVPixelFormatType_32BGRA;
            
        } else {
            pixelFormat = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
        }
        NSDictionary *setting = @{ (id)kCVPixelBufferPixelFormatTypeKey : @(pixelFormat) };
        _video_track_output =
            [AVAssetReaderTrackOutput
                assetReaderTrackOutputWithTrack:video_tracks[0]
                                 outputSettings:setting];
        _video_track_output.alwaysCopiesSampleData = NO;
    }
    
    if(_video_track_output) [_reader addOutput:_video_track_output];
}

- (CMSampleBufferRef)nextAudioSample {
    if (_statePause) {
        [self startReading];
        _statePause = false;
    }
    if (!_audio_track_output) {
        return nil;
    }
    
    CMSampleBufferRef sample = [_video_track_output copyNextSampleBuffer];
    _currentAudioTime = CMSampleBufferGetPresentationTimeStamp(sample);
    return [_audio_track_output copyNextSampleBuffer];
}

- (CMSampleBufferRef)nextVideoSample {
    if (_statePause) {
        [self startReading];
        _statePause = false;
    }
    
    if (!_video_track_output) {
        return nil;
    }
    
    CMSampleBufferRef sample = [_video_track_output copyNextSampleBuffer];
    _currentVideoTime = CMSampleBufferGetPresentationTimeStamp(sample);
    return sample;
}

- (void)close {
    [_reader cancelReading];
    _reader = nil;
    _video_track_output = nil;
    _audio_track_output = nil;
}

@end
