//
//  SSScaleAction.m
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-26.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSScaleAction.h"

@implementation SSScaleAction
@synthesize fScaleXFromPrevToCur;
@synthesize fScaleYFromPrevToCur;

-(SSScaleAction*) initWithInfo: (UIView<ActionOperator>*)targetView
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
