//
//  SSRotateAction.h
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-26.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSAction.h"

@interface SSRotateAction : SSAction

-(SSRotateAction*) initWithInfo:(UIView<ActionOperator>*)targetView
                    withCurTransform:(CGAffineTransform)_curTransform
                    withPrevTransform:(CGAffineTransform)_prevTransform
          withDiffAngleFromPrevToCur:(CGFloat)_fDiffAngleFromPrevToCur;

@property(nonatomic) CGFloat fDiffAngleFromPrevToCur;

@end
