//
//  MenuButton.m
//  FVideo
//
//  Created by coCo on 14-8-8.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import "MenuButton.h"
#import <base/Common.h>

@implementation MenuButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

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
                   device:(BOOL)device
{
    self = [super initWithFrame:buttonFrame];
    if (self) {
        //
        self.selected = select;
        self.device = device;
        self.tag = tag;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = cornerRadius;
        if (backgroundImage == nil) {
                //button的backgroundcolor
                self.backgroundColor = [UIColor colorWithRed:41.0/255 green:41.0/255 blue:41.0/255 alpha:1];
                //button的image
                _imageView = [[UIImageView alloc] initWithFrame:buttonImageFrame];
                //NSLog(@"%f",_imageView.frame.origin.x);
                _imageView.image = image;
                [self addSubview:_imageView];
                //button的title
                _titleView = [[UILabel alloc] initWithFrame:buttonTitleFrame];
                _titleView.text = title;
                _titleView.font = [UIFont systemFontOfSize:titleFont];
                _titleView.textColor = [UIColor whiteColor];
                [self addSubview:_titleView];
                //添加点击事件
                _tapGes = [[UITapGestureRecognizer alloc] initWithTarget:target action:sel];
                [self addGestureRecognizer:_tapGes];
            }else{
                //button的backgroundColor
                //self.backgroundColor = [UIColor colorWithRed:15.0/255 green:15.0/255 blue:15.0/255 alpha:1];
                self.backgroundColor = [UIColor clearColor];
                //缩略图背景
                _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 52, 52)];
                _backgroundImageView.image = backgroundImage;
                //NSLog(@"%f,%f,%f,%f",self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
                [self addSubview:_backgroundImageView];
                //button的image
                _imageView = [[UIImageView alloc] initWithFrame:buttonImageFrame];
                _imageView.image = image;
                _imageView.layer.masksToBounds = YES;
                _imageView.layer.cornerRadius = 2.5;
                [_backgroundImageView addSubview:_imageView];
                //
                if (self.device == NO) {
                    _titleImage = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 50, 50)];
                    [_titleImage setImage:[UIImage imageNamed:@"缩略图蒙版.png"]];
                    _titleImage.userInteractionEnabled = YES;
                    _titleImage.layer.masksToBounds = YES;
                    _titleImage.layer.cornerRadius = 2.5;
                    [_backgroundImageView addSubview:_titleImage];
                    //bottom的title
                    _titleView = [[UILabel alloc] initWithFrame:buttonTitleFrame];
                    _titleView.text = title;
                    _titleView.font = [UIFont systemFontOfSize:titleFont];
                    _titleView.textAlignment = NSTextAlignmentCenter;
                    _titleView.textColor = [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
                    _titleView.backgroundColor = [UIColor clearColor];
                    _titleView.layer.masksToBounds = YES;
                    _titleView.layer.cornerRadius = 2.5;
                    [_titleImage addSubview:_titleView];
                }else{
                    _titleView = [[UILabel alloc] initWithFrame:buttonTitleFrame];
                    _titleView.text = title;
                    _titleView.font = [UIFont systemFontOfSize:titleFont];
                    _titleView.textAlignment = NSTextAlignmentCenter;
                    _titleView.textColor = [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
                    _titleView.backgroundColor = [UIColor clearColor];
                    _titleView.layer.masksToBounds = YES;
                    _titleView.layer.cornerRadius = 2.5;
                    [self addSubview:_titleView];
                }
                //添加点击事件
                _tapGes = [[UITapGestureRecognizer alloc] initWithTarget:target action:sel];
                [self addGestureRecognizer:_tapGes];
            }
        }
    return self;
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
