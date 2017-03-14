//
//  MenuButton.h
//  FVideo
//
//  Created by coCo on 14-8-8.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuButton : UIView

@property (nonatomic ,retain) UIImageView *imageView;
@property (nonatomic ,retain) UILabel *titleView;
@property (nonatomic ,retain) UITapGestureRecognizer *tapGes;
@property (nonatomic ,retain) UIImageView *backgroundImageView;
@property (nonatomic ) int titleFont;
@property (nonatomic ) int cornerRadius;
@property (nonatomic ) BOOL selected;
@property (nonatomic ) int tag;
@property (nonatomic ,retain) UIImageView *titleImage;
@property (nonatomic ) BOOL device;

-(id) initWithButtonFrame:(CGRect)buttonFrame
         buttonImageFrame:(CGRect)buttonImageFrame
         buttonTitleFrame:(CGRect)buttonTitleFrame
              buttonImage:(UIImage *)image
              buttonTitle:(NSString *)title
                titleFont:(int)titleFont
                buttonTag:(int)tag
           buttonSelected:(BOOL)select
    buttonBackgroundImage:(UIImage *)backgroundImage
        clickButtonTarget:(id)target
        clickButtonTarget:(SEL)sel
       buttonCornerRadius:(int)cornerRadius
                   device:(BOOL)device;
@end
