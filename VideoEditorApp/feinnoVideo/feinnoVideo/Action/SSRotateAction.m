//
//  SSRotateAction.m
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-26.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSRotateAction.h"

@implementation SSRotateAction
@synthesize fDiffAngleFromPrevToCur;
-(SSRotateAction*) initWithInfo: (UIView<ActionOperator>*)targetView
                    withCurTransform:(CGAffineTransform)_curTransform
                    withPrevTransform:(CGAffineTransform)_prevTransform
          withDiffAngleFromPrevToCur:(CGFloat)_fDiffAngleFromPrevToCur
{
    self = [super init];
    if(self)
    {
        self.nId = ROTATE_ACTION;
        self.targetObject = targetView;
        self.curTransform = _curTransform;
        self.prevTransform = _prevTransform;
        self.fDiffAngleFromPrevToCur = _fDiffAngleFromPrevToCur;
    }
    return self;
}

@end
