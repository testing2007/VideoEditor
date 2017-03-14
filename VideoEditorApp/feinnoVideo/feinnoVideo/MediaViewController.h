//
//  MediaViewController.h
//  FVideo
//
//  Created by coCo on 14-8-26.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerView.h"
#import "MySlider.h"
//#import "VideoRangeSlider/SAVideoRangeSlider.h"
#import "VideoRangeSlider/SAVideoRangeSlider.h"
#import "SSStageView.h"

@interface MediaViewController : UIViewController<MySliderDelegate,SAVideoRangeSliderDelegate>
{
    NSString* _srcVideoPath;
    PlayerView* _playerView;
    SSStageView* _stageView;
}
@property(nonatomic, retain) NSString* srcVideoPath;
@property (nonatomic ,retain) PlayerView *playerView;
@property (nonatomic ,retain) UIButton *recorderProgress;
@property (nonatomic ,retain) UIButton *playBtn;
@property (nonatomic ,retain) MySlider *sliderView;
@property (nonatomic ) float currentSecond;
@property (nonatomic ) float sliderValue;   //录音起始位置
@property (nonatomic ,retain) UIProgressView *playerProView;
@property (nonatomic ) BOOL played;
@property (nonatomic, retain) SSStageView* stageView;
//播放
-(void)playBtnTouched;
//暂停
-(void) buttonStop;
-(void) loadVideo:(NSString*)videoPath;
//设置是否播放原音
-(void) soundBtnHidden: (BOOL)isshow;
//选择是否显示pregess
-(void) mediaTimeShow :(BOOL)isShow;
//设置播放器消失
-(void) checkPlayerViewHidden :(BOOL)isShow;
//是否显示选择进度的进度条
-(void) isshowMySaVideo :(BOOL) isShow;
//设置滑动进度条消失
-(void) isshowSlider :(BOOL) isShow;
//设置进度条浮层消失
-(void) isshowSliderView :(BOOL) isShow;
//是否显示录音进度条
-(void) isshowRecorderView:(BOOL) isShow;
//播放按钮消失
-(void) playerButtonHidden:(BOOL)isShowPlayerBtn;
// 透明进度条上的时间Label
-(void) playerSliderLabelHidden: (BOOL) isShowSliderLabel;

//-(void) selectTheme:(int)nSelID;
-(void) selectFilter:(int)nSelID;

-(void) record:(float**)oldVolumeValue isMute:(BOOL)bMute;

@end
