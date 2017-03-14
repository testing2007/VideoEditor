//
//  SSClothesBoxColorBtn.h
//  SSShow
//
//  Created by weizhiqiangzz on 13-1-24.
//  Copyright (c) 2013年 weizhiqiangzz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSClothesBoxColorBtn : UIButton
{
@public
    // int nId;     //button id，即tag
    int nProdId; //对应产品id
    int nColorId; //从json分析出来的颜色id
    UIColor* color; //颜色
    NSString* name; //颜色对应的名字,如：黄色，绿色等。
}
@end
