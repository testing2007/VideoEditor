//
//  SSAddImageAction.m
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-24.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSAddImageAction.h"

@implementation SSAddImageAction

-(SSAddImageAction*) initWithInfo: (UIView*)targetView
                 withCurTransform:(CGAffineTransform)_curTransform
                 withPrevTransform:(CGAffineTransform)_prevTransform
{
    self = [super init];
    if(self)
    {
        self.nId = ADD_ACTION;
        self.targetObject = targetView;
        self.curTransform = _curTransform;
        self.prevTransform = _prevTransform;
    }
    return self;
}

@end
