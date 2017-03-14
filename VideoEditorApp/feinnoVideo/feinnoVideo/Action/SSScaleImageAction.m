//
//  SSScaleImageAction.m
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-26.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSScaleImageAction.h"

@implementation SSScaleImageAction
@synthesize fScaleXFromPrevToCur;
@synthesize fScaleYFromPrevToCur;

-(SSScaleImageAction*) initWithInfo: (UIView*)targetView
                   withCurTransform:(CGAffineTransform)_curTransform
                  withPrevTransform:(CGAffineTransform)_prevTransform
{
    self = [super init];
    if(self)
    {
        self.nId = SCALE_ACTON;
        self.targetObject = targetView;
        self.curTransform = _curTransform;
        self.prevTransform = _prevTransform;
        
        self.fScaleXFromPrevToCur = _curTransform.a - _prevTransform.a;
        self.fScaleYFromPrevToCur = _curTransform.d - _prevTransform.d;
    }
    return self;
}

@end
