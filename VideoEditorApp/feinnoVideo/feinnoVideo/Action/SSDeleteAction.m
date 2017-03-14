//
//  SSDeleteAction.m
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-26.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSDeleteAction.h"

@implementation SSDeleteAction
-(SSDeleteAction*) initWithInfo: (UIView<ActionOperator>*)targetView
                    withCurTransform:(CGAffineTransform)_curTransform
                   withPrevTransform:(CGAffineTransform)_prevTransform
{
    self = [super init];
    if(self)
    {
        self.nId = DELETE_ACTION;
        self.targetObject = targetView;
        self.curTransform = _curTransform;
        self.prevTransform = _prevTransform;
    }
    return self;
}
@end
