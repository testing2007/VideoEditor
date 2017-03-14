//
//  SSMaterialProductBtn.h
//  SSShow
//
//  Created by weizhiqiangzz on 13-1-21.
//  Copyright (c) 2013年 weizhiqiangzz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSMaterialProductBtn : UIButton
{
@public
    // int nId;          //该按钮的Id, 从0开始标记，后续累加1, tag标记是700+nId
    int nCategoryId;  //该素材所属的分类id
    int nProdId;      //素材产品id
    BOOL bDownloaded; //该id 产品是否完成下载
}
@end
