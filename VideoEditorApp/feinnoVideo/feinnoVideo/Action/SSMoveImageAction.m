//
//  SSMoveImageAction.m
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-24.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSMoveImageAction.h"

@implementation SSMoveImageAction
@synthesize fTxFromPrevToCur;
@synthesize fTyFromPrevToCur;

-(SSMoveImageAction*) initWithInfo: (UIView*)targetView
                  withCurTransform:(CGAffineTransform)_curTransform
                  withPrevTransform:(CGAffineTransform)_prevTransform
{
    self = [super init];
    if(self)
    {
        self.nId = MOVE_ACTION;
        self.targetObject = targetView;
        self.curTransform = _curTransform;
        self.prevTransform = _prevTransform;
        
        self.fTxFromPrevToCur = _curTransform.tx - _prevTransform.tx;
        self.fTyFromPrevToCur = _curTransform.ty - _prevTransform.ty;
    }
    return self;
}

@end
