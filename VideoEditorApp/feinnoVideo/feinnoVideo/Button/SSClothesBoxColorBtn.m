//
//  SSClothesBoxColorBtn.m
//  SSShow
//
//  Created by weizhiqiangzz on 13-1-24.
//  Copyright (c) 2013年 weizhiqiangzz. All rights reserved.
//

#import "SSClothesBoxColorBtn.h"

@implementation SSClothesBoxColorBtn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // nId = -1;
        nProdId = -1;
        nColorId = -1;
        color = [[UIColor alloc]init];
        name = [[NSString alloc]init];
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
