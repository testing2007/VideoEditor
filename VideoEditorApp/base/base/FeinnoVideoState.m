//
//  FeinnoVideoState.m
//  libFeinnoVideo
//
//  Created by coCo on 14-9-16.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "FeinnoVideoState.h"

static FeinnoVideoState *videoState = nil;
@implementation FeinnoVideoState

BOOL isFromSelf = NO;

+(id)getFeinnoVideoInstance
{
    if (videoState == nil) {
        isFromSelf = YES;
        videoState = [[FeinnoVideoState alloc] init];
        isFromSelf = NO;
        }
    return videoState;
}
+(id)alloc
{
    if (isFromSelf)
    {
        return [super alloc];
    }else{
        return nil;
    }
}
-(void) dealloc
{
    
}
@end
