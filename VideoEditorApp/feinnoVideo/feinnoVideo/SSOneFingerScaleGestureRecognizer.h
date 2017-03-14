//
//  SSOneFingerScaleGestureRecognizer.h
//  libFeinnoVideo
//
//  Created by wzq on 14-9-29.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSOneFingerScaleGestureRecognizer : UIGestureRecognizer
{
   CGPoint _ptScale;
    CGFloat _rotation;
}

@property (nonatomic, assign) CGPoint ptScale;
@property (nonatomic, assign) CGFloat rotation; //每次移动的偏移角度
// @property (nonatomic, assign) CGFloat deltaRotation;//累计旋转角度

@end
