//
//  MySlider.m
//  asdf
//
//  Created by coCo on 14-8-24.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import "MySlider.h"

@implementation MySlider{
    

}

-(id)initWithImageArray:(NSArray *)imageArray time:(float)totaltimes frame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:15.0/255 green:15.0/255 blue:15.0/255 alpha:0.6];
        self.userInteractionEnabled = YES;
        self.frame = frame;
        self.imgArray = imageArray;
        self.time = totaltimes;
        _imageView = [[UIView alloc] initWithFrame:CGRectMake(12,self.frame.size.height -26 -20,self.frame.size.width -24 ,20)];
        _imageView.userInteractionEnabled = YES;
        _imageView.backgroundColor = [UIColor clearColor];
        float width = _imageView.frame.size.width / self.imgArray.count;
            for (int i = 0; i < self.imgArray.count; i++) {
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(width*i, 0, width, _imageView.frame.size.height)];
                imgView.image = [UIImage imageNamed:[self.imgArray objectAtIndex:i]];
                [_imageView addSubview:imgView];
            }
        [self addSubview:_imageView];
        
        _pointView = [[UIImageView alloc] initWithFrame:CGRectMake(-1, 0, 2, _imageView.frame.size.height)];
        NSLog(@"%f",_pointView.frame.origin.x);
        _pointView.image = [UIImage imageNamed:@"滑块.png"];
        _pointView.backgroundColor = [UIColor redColor];
        [_imageView addSubview:_pointView];
        
        self.userInteractionEnabled = YES;
    }
    return  self;
}


@end
