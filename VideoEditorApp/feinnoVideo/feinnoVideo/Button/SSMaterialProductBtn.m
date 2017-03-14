//
//  SSMaterialProductBtn.m
//  SSShow
//
//  Created by weizhiqiangzz on 13-1-21.
//  Copyright (c) 2013年 weizhiqiangzz. All rights reserved.
//

#import "SSMaterialProductBtn.h"
// #import "SSCommon.h"
#import "SSScrollView.h"

@interface SSMaterialProductBtn ()
{
    CGRect m_originRC;
}
@end

@implementation SSMaterialProductBtn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        m_originRC=  frame;
    }
    return self;
}

//*
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    SSScrollView* pv = (SSScrollView*)self.superview;
    CGRect rc = m_originRC;
    rc.origin.x = rc.origin.x-((pv.szItem.width*BTN_SCALE_RATE_FROM_MATERIAL_PRODUCT_SCROLLVIEW)/2.0);
    rc.origin.y = rc.origin.y-((pv.szItem.height*BTN_SCALE_RATE_FROM_MATERIAL_PRODUCT_SCROLLVIEW)/2.0);
    rc.size.width = rc.size.width+(pv.szItem.width*BTN_SCALE_RATE_FROM_MATERIAL_PRODUCT_SCROLLVIEW);
    rc.size.height = rc.size.height+(pv.szItem.height*BTN_SCALE_RATE_FROM_MATERIAL_PRODUCT_SCROLLVIEW);
    [self setFrame:rc];
    NSLog(@"touchesBegan");
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesMoved");
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setFrame:m_originRC];
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    // [self sendAction:@selector(pressClothesBtn:) to:self.superview forEvent:UIControlEventTouchUpInside];
    
    NSLog(@"touchesEnded");
}
//*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
