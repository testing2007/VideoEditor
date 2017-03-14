//
//  NavigationBar.h
//  FVideo
//
//  Created by coCo on 14-8-13.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationBar : UIView

@property (nonatomic ,retain) UILabel *titleLabel;

- (id)initWithFrame:(CGRect)frame
          titleText:(NSString *)titleText
   leftButtonTarget:(id)leftTarget
   leftButtonAction:(SEL)leftSel
    leftButtonImage:(UIImage *)leftImage
leftSelectedButtonImage:(UIImage *)selectedLeftImage
  rightButtonTarget:(id)rightTarget
  rightButtonAction:(SEL)rightSel
   rightButtonImage:(UIImage *)rightImage
rightSelectedButtonImage:(UIImage *)selectedRightImage
        rightBtnTag:(int)rightBtnTag;

@end
