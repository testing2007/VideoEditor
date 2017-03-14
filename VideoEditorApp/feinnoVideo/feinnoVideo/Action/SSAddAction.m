//
//  SSAddAction.m
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-24.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSAddAction.h"

@implementation SSAddAction

-(SSAddAction*) initWithInfo: (UIView<ActionOperator>*)targetView
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
