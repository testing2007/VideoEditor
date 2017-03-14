//
//  playerView.m
//  VideoShow
//
//  Created by coCo on 14-7-14.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import "playerView.h"
#import <AVFoundation/AVFoundation.h>
#import "FVideoViewController.h"

@interface PlayerView()
{
    AVPlayerItem *_playerItem;
    UIButton* _playBtn;
    
    UIView* _audioParentView;
    __weak FVideoViewController* eventCallback;
    NSString* _srcMediaPath;
}

@property (nonatomic ,retain) AVPlayerItem *playerItem;
@property (nonatomic, retain) UIButton* playBtn;
@property (nonatomic, retain) UIView* audioParentView;
@property (nonatomic, retain) NSString* srcMediaPath;

@end

@implementation PlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

-(PlayerView*)initAudioPlayer:(UIView*)parentView withMediatPath:(NSString*)mediaPath withInteractionEnable:(BOOL)bEnable withEventFeedback:(id)eventFeedback
{
    self = [super initWithFrame:CGRectMake(0, 0, 0, 0)];
    if(self!=nil)
    {
//        NSURL* url = [NSURL fileURLWithPath:mediaPath];
//        self.playerItem = [AVPlayerItem playerItemWithURL:[url copy]];
        self.userInteractionEnabled = bEnable;
//        self.player = [AVPlayer playerWithPlayerItem:_playerItem];
//        self.player.volume = 1;
        self.srcMediaPath = mediaPath;
    }
    if(parentView != NULL)
    {
        eventCallback = eventFeedback;
        self.audioParentView = parentView;
        self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playBtn.frame=CGRectMake(0, 0, 50, 50);
        [parentView addSubview:self.playBtn];
        CGPoint btnOrig = CGPointMake((parentView.frame.size.width-_playBtn.frame.size.width)/2, (parentView.frame.size.height-_playBtn.frame.size.height)/2);
        _playBtn.frame = CGRectMake(btnOrig.x, btnOrig.y, _playBtn.frame.size.width, _playBtn.frame.size.height);
        [_playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        _playBtn.layer.masksToBounds = YES;
        _playBtn.layer.cornerRadius = 25;
        [_playBtn addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn addTarget:eventCallback action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

-(void) startPlay
{
    [self startPlay:eventCallback.bEnableSrcSound];
}

//播放视频
-(void) startPlay:(BOOL)bEnableVolume
{
    //todo: 不知道为什么每次需要重新用媒体路径初始化一次，否则，第二次播放的时候，就没有声音
    NSLog(@"视频播放中。。。");
    self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:_srcMediaPath]];
    self.player.volume = bEnableVolume ? 1.0 : 0;
    [self.player play];
    _playBtn.hidden = YES;
    if(self.userInteractionEnabled)
    {
        UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopPlay)];
        [recognizer addTarget:eventCallback action:@selector(stopPlay)];
        recognizer.numberOfTouchesRequired = 1;
        [_audioParentView addGestureRecognizer:recognizer];
        //recognizer = nil;//zhiqiang++ 释放内存
    }
}

//暂停视频
-(void) stopPlay
{
    NSLog(@"视频暂停");
    
    [self.player pause];
    
    for (UISwipeGestureRecognizer *recognizer in [_audioParentView gestureRecognizers]) {
        [_audioParentView removeGestureRecognizer:recognizer];
    }
    _playBtn.hidden = NO;
}

-(void) isHidePlayBtn:(BOOL)bHide
{
    _playBtn.hidden = bHide;
}

@end
