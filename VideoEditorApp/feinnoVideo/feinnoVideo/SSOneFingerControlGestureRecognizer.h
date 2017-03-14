//
//  SSOneFingerControlGestureRecognizer.h
//  libFeinnoVideo
//
//  Created by wzq on 14-10-8.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSOneFingerControlGestureRecognizer : UIGestureRecognizer
{
    //x, y 移动偏移量
    CGPoint _ptMoveOffset;
    //旋转角度
    CGFloat _rotateAngle;
    //x, y 缩放比
    CGPoint _ptScale;
}

@property(nonatomic, assign) CGPoint ptMoveOffset;
@property(nonatomic, assign) CGFloat rotateAngle;
@property(nonatomic, assign) CGPoint ptScale;

@end
