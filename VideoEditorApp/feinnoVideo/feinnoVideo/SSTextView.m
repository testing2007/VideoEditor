//
//  SSTextView.m
//  SSShow
//
//  Created by weizhiqiangzz on 13-1-29.
//  Copyright (c) 2013年 weizhiqiangzz. All rights reserved.
//

#import "SSTextView.h"
#import "SSStageView.h"
#import "Button/SSRotateBtn.h"
#import "SSWarningFrameView.h"

@interface SSTextView ()
{
    // SSEditView *m_editView;
}
@end
@implementation SSTextView
@synthesize prevTransform;
@synthesize prevScale;
@synthesize ptMoveBtnOffestRotatePoint;
@synthesize ptRotateBtnOffestRotatePoint;
@synthesize ptScaleBtnOffestRotatePoint;
@synthesize ptDelBtnOffestRotatePoint;

- (id)initWithFrame:(CGRect)rcFrame
{
    self = [super initWithFrame:rcFrame];
    if (self)
    {
        // Initialization code
        [self setUserInteractionEnabled:YES];
        // [self setOpaque:NO];
        
        // self.prevTransform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
        self.text = @"";
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
    }
    
    return self;
}

@end
