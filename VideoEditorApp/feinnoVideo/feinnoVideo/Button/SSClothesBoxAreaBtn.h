//
//  SSClothesBoxAreaBtn.h
//  SSShow
//
//  Created by weizhiqiangzz on 13-1-24.
//  Copyright (c) 2013年 weizhiqiangzz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSClothesBoxAreaBtn : UIButton
{
@public
    // int nId;     //button id，即tag
    int nProdId; //对应产品id
    int nAreaId; //从json分析出来的面id
    //### NSString* name; //面对应的名字,如：正面，反面等。
}
@end
