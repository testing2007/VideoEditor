//
//  SSClothesBoxSizeBtn.h
//  SSShow
//
//  Created by weizhiqiangzz on 13-1-24.
//  Copyright (c) 2013年 weizhiqiangzz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSClothesBoxSizeBtn : UIButton
{
@public
    // int nId;     //button id，即tag
    int nProdId; //对应产品id
    int nSizeId; //从json分析出来的尺寸id
    NSString* name; //尺寸对应的名字,如：S, M等。
}
@end
