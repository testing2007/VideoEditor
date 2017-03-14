//
//  SSAddAction.h
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-24.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSAction.h"
//#import <CoreGraphics/CGAffineTransform.h>
@interface SSAddAction : SSAction

-(SSAddAction*) initWithInfo:(UIView<ActionOperator>*)targetView
                 withCurTransform:(CGAffineTransform)_curTransform
                 withPrevTransform:(CGAffineTransform)_prevTransform;


@end
