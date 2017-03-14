//
//  FVAudioPlayer.h
//  libFeinnoVideo
//
//  Created by wzq on 14-9-19.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface FVAudioPlayer : NSObject 

-(void)start:(NSString*)path;
-(void)stop;
-(void) changeVolume :(float)volume;
@end
