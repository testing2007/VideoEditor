//
//  MySlider.h
//  asdf
//
//  Created by coCo on 14-8-24.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MySliderDelegate
@optional

-(void)sliderDidMove:(CGRect)currentFrame;
@end
@interface MySlider : UIView

@property (nonatomic) NSArray *imgArray;
@property (nonatomic ,retain) NSString *value;
@property (nonatomic) float time;
@property (nonatomic) NSString *curTime;
@property (nonatomic ,retain) UISlider *slider;
@property (nonatomic ,retain) UIView *imageView;
@property (nonatomic ,retain) UIButton *button;;
@property (nonatomic ,retain) UIImageView *pointView;
@property (nonatomic ,retain) UIView *panView;
@property (nonatomic ,assign) id <MySliderDelegate> delegate;

-(id)initWithImageArray:(NSArray *)imageArray time:(float)time frame:(CGRect)frame;

@end



