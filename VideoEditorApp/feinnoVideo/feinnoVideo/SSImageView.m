//
//  SSImageView.m
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-20.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSImageView.h"
#import "SSOneFingerRotationGestureRecognizer.h"
#import "SSStageView.h"
#import "SSWarningFrameView.h"
#import "SSWarningFrame.h"
//#import "Protocol/NotifyMsgToParent.h"
#import "Action/SSAddAction.h"
#import "Action/SSRotateAction.h"
#import "Action/SSMoveAction.h"
#import "Action/SSScaleAction.h"
#import "Action/SSDeleteAction.h"
#import "Button/SSRotateBtn.h"
#import "SSEditView.h"

@interface SSImageView ()
{
    // SSEditView *m_editView;
}
@end
@implementation SSImageView
@synthesize prevTransform;
@synthesize prevScale;
@synthesize ptMoveBtnOffestRotatePoint;
@synthesize ptRotateBtnOffestRotatePoint;
@synthesize ptScaleBtnOffestRotatePoint; 
@synthesize ptDelBtnOffestRotatePoint;
@synthesize ptControlBtnOffsetPoint;

- (id)initWithFrame:(CGRect)rcFrame
{
    self = [super initWithFrame:rcFrame];
    if (self)
    {
        // Initialization code
        [self setUserInteractionEnabled:YES];
        // [self setOpaque:NO];
        
        // self.prevTransform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        self.prevTransform = CGAffineTransformMake(0, 0, 0, 0, 0, 0);
        self.prevScale = 1;

        //移动
        self.ptMoveBtnOffestRotatePoint = CGPointMake(-rcFrame.size.width/2, -rcFrame.size.height/2);
        //旋转
        self.ptRotateBtnOffestRotatePoint = CGPointMake(rcFrame.size.width/2, -rcFrame.size.height/2);
        //缩放
        self.ptScaleBtnOffestRotatePoint = CGPointMake(rcFrame.size.width/2, rcFrame.size.height/2);        
        //删除
        self.ptDelBtnOffestRotatePoint = CGPointMake(-rcFrame.size.width/2, rcFrame.size.height/2);
        //控制
        //self.ptControlBtnOffsetPoint = CGPointMake(rcFrame.size.width/2, rcFrame.size.height/2);
    }
    
    return self;
}

@end
