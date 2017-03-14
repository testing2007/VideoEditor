//
//  SSMoveImageAction.h
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-24.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSAction.h"

@interface SSMoveImageAction : SSAction

-(SSMoveImageAction*) initWithInfo: (UIView*)targetView
                  withCurTransform:(CGAffineTransform)_curTransform
                  withPrevTransform:(CGAffineTransform)_prevTransform;

@property(nonatomic) float fTxFromPrevToCur;
@property(nonatomic) float fTyFromPrevToCur;

@end
