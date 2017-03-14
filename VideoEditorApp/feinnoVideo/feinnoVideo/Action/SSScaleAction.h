//
//  SSScaleAction.h
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-26.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSAction.h"

@interface SSScaleAction : SSAction

-(SSScaleAction*) initWithInfo: (UIView<ActionOperator>*)targetView
                   withCurTransform:(CGAffineTransform)_curTransform
                  withPrevTransform:(CGAffineTransform)_prevTransform;

@property(nonatomic) float fScaleXFromPrevToCur;
@property(nonatomic) float fScaleYFromPrevToCur;

@end
