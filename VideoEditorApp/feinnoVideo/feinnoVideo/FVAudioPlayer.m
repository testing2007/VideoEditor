//
//  FVAudioPlayer.m
//  libFeinnoVideo
//
//  Created by wzq on 14-9-19.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "FVAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface FVAudioPlayer()
{
    AVAudioPlayer* _audioPlayer;
}
@property(nonatomic, strong) AVAudioPlayer* audioPlayer;

@end

@implementation FVAudioPlayer

-(void)start:(NSString *)path
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"there are not file existence in the path %@", path);
        return ;
    }
    NSURL *url = [NSURL fileURLWithPath:path];
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    _audioPlayer.volume = 1.0;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
}

-(void)stop
{
    _audioPlayer.volume = 0;//先把音量给关了，要不stop不能马上停止住
    [_audioPlayer stop];
}

-(void) changeVolume :(float)volume
{
    _audioPlayer.volume = volume;
}

@end
