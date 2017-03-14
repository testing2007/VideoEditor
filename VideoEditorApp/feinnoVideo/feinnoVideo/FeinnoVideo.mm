//
//  FeinnoVideo.m
//  libFeinnoVideo
//
//  Created by wzq on 14-9-2.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "FeinnoVideo.h"
#import <Foundation/NSException.h>
#import "FVideoViewController.h"

@implementation FeinnoVideo
{
    __weak UINavigationController* parentViewContoller;
}

-(BOOL)initialize:(UIViewController*)parentVC
{
    NSAssert([parentVC isKindOfClass:[UINavigationController class]], @"the input parameter isn't match with the requirements");
    parentViewContoller = (UINavigationController*)parentVC;
    [parentViewContoller pushViewController:[[FVideoViewController alloc] init] animated:YES];
    
    return YES;
}

-(void)unitialize
{
    
}

-(void)loadMediaFile:(NSString*)path
{
    
}

@end
