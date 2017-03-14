//
//  playerView.h
//  VideoShow
//
//  Created by coCo on 14-7-14.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <GPUImage/GPUImageView.h>
//#import "ActionOperator.h"

@interface PlayerView : UIView

-(PlayerView*)initAudioPlayer:(UIView*)parentView withMediatPath:(NSString*)mediaPath withInteractionEnable:(BOOL)bEnable withEventFeedback:(id)eventFeedback;

@property (nonatomic ,strong) AVPlayer *player;

-(void) isHidePlayBtn:(BOOL)bHide;

-(void) startPlay:(BOOL)bEnableVolume;
-(void) stopPlay;


@end
