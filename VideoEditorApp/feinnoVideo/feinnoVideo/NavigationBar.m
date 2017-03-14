//
//  NavigationBar.m
//  FVideo
//
//  Created by coCo on 14-8-13.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import "NavigationBar.h"

@implementation NavigationBar{
    UILabel *_titleLabel;
    UIButton *_leftButton;
    UIButton *_rightButton;
    // __weak id _rightTarget; //zhiqiang++
}

- (id)     initWithFrame:(CGRect)frame
               titleText:(NSString *)titleText
        leftButtonTarget:(id)leftTarget
        leftButtonAction:(SEL)leftSel
         leftButtonImage:(UIImage *)leftImage
 leftSelectedButtonImage:(UIImage *)selectedLeftImage
       rightButtonTarget:(id)rightTarget
       rightButtonAction:(SEL)rightSel
        rightButtonImage:(UIImage *)rightImage
rightSelectedButtonImage:(UIImage *)selectedRightImage
             rightBtnTag:(int)rightBtnTag
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:41.0/255 green:41.0/255 blue:41.0/255 alpha:1];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 -40, self.frame.size.height/2 -10, 80, 20)];
        _titleLabel.text = titleText;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:18];
        [self addSubview:_titleLabel];
        if (leftTarget != nil) {
            _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _leftButton.frame = CGRectMake(8, self.frame.size.height/2 -15, 30, 30);
            [_leftButton setBackgroundImage:leftImage forState:UIControlStateNormal];
            [_leftButton setBackgroundImage:selectedLeftImage forState:UIControlStateHighlighted];
            [_leftButton addTarget:leftTarget action:leftSel forControlEvents:UIControlEventTouchUpInside];
            // [_leftButton setBackgroundColor:[UIColor whiteColor]];
            [self addSubview:_leftButton];
        }
        //*//##zhiqiang--
        if (rightTarget != nil) {
            if (rightImage != nil) {
                _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _rightButton.frame = CGRectMake(self.frame.size.width -15 -40, self.frame.size.height/2 -15, 40, 30);
                _rightButton.tag = rightBtnTag;
                [_rightButton setBackgroundImage:rightImage forState:UIControlStateNormal];
                [_rightButton setBackgroundImage:selectedRightImage forState:UIControlStateHighlighted];
            }else
            {
                /*
                _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _rightButton.frame = CGRectMake(5, self.frame.size.height/2 -15, 40, 300);
                [_rightButton setBackgroundColor:[UIColor whiteColor]];
                [_rightButton setTitle:@"返回" forState:UIControlStateNormal];
                [_rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                 //*/
                //*
                _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _rightButton.frame = CGRectMake(self.frame.size.width -21 -30, self.frame.size.height/2 -15, 40, 30);
                [_rightButton setTitle:@"确定" forState:UIControlStateNormal];
                [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [_rightButton setTitleColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1.0]
                                   forState:UIControlStateHighlighted];
                _rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
                _rightButton.titleLabel.textAlignment = NSTextAlignmentCenter;
                //##[_rightButton setBackgroundColor:[UIColor redColor]];
                //NSLog(@"%f",_rightButton.right);
                 //*/
            }
            _rightButton.selected = NO;
            [_rightButton addTarget:rightTarget action:rightSel forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_rightButton];
         }
         //*/
        
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
