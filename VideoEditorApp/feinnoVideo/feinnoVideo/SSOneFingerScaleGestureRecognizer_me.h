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
   CGFloat _scale;
}

@property (nonatomic, assign) CGFloat scale;

@end
