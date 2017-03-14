//
//  SSWaringFrameView.m
//  SSShow
//
//  Created by tianming on 13-1-8.
//  Copyright (c) 2013年 weizhiqiangzz. All rights reserved.
//

#import "SSWarningFrameView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SSWarningFrameView
@synthesize eWarningFrameStateColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setOpaque:NO];
        // Initialization code
        eWarningFrameStateColor = WARNING_FRAME_OUT_CLEAR_COLOR;
    }
    
    return self;
}

//用于在初始化告警视图时绘制告警框
-(void)drawRect:(CGRect)rect
{
    CGContextRef c=UIGraphicsGetCurrentContext();
    CGColorRef col = [UIColor clearColor].CGColor;
    switch (eWarningFrameStateColor)
    {
        case WARNING_FRAME_NORMAL_COLOR_BLUE:
            col = [UIColor blueColor].CGColor;
            break;
        case WARNING_FRAME_UNNORMAL_COLOR_RED:
            col = [UIColor redColor].CGColor;
            break;
        case WARNING_FRAME_OUT_CLEAR_COLOR:
            col = [UIColor clearColor].CGColor;
            break;
    }
    CGContextSetStrokeColorWithColor(c, col);
    CGContextSetLineWidth(c, 2.0);
    // start at origin
    CGContextMoveToPoint (c, CGRectGetMinX(rect), CGRectGetMinY(rect));
    // add bottom edge
    CGContextAddLineToPoint (c, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    // add right edge
    CGContextAddLineToPoint (c, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint (c, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    // add left edge and close
    CGContextClosePath (c);
   
    CGContextStrokePath(c);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
