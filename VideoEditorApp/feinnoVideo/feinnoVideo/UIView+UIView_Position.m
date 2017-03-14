//
//  UIView+UIView_Position.m
//  FVideo
//
//  Created by coCo on 14-8-10.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import "UIView+UIView_Position.h"

@implementation UIView (UIView_Position)

-(float)top
{
    return self.frame.origin.y;
}
-(float)left
{
    return self.frame.origin.x;
}
-(float)right
{
    return self.frame.origin.x + self.frame.size.width;
}
-(float)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}


@end
