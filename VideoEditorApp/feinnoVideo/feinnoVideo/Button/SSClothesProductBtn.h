//
//  SSClothesProductBtn.h
//  SSShow
//
//  Created by weizhiqiangzz on 13-1-6.
//  Copyright (c) 2013年 weizhiqiangzz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SSClothesProductBtn : UIButton
{
@public
    // int nId;       //该按钮的Id, 从0开始标记，后续累加1, tag标记是500+nId
    int nProdId;   //服饰产品id
    int nColorId;  //颜色id //因为存在颜色存在随机性，所以随机决定的颜色id号需要保存
    BOOL bDownloaded; //该id 产品是否完成下载
}

@end
