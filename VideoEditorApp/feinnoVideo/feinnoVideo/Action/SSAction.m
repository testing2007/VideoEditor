//
//  SSAction.m
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-24.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSAction.h"

@implementation SSAction
@synthesize nId;
@synthesize targetObject;
@synthesize curTransform;
@synthesize prevTransform;

-(SSAction*) init
{
    self = [super init];
    if(self)
    {
        nId = UNKNOWN_ACTION; //行为标识
        targetObject = nil; //操作目标
        curTransform = CGAffineTransformMake(0, 0, 0, 0, 0, 0);
        prevTransform = CGAffineTransformMake(0, 0, 0, 0, 0, 0);
    }
    return self;
}
@end
