//
//  Menu.h
//  VideoShow
//
//  Created by coCo on 14-7-16.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Menu : NSObject

@property (nonatomic ,retain) NSArray *firMenuButtonArr;    //一级菜单button
@property (nonatomic ,retain) UIView *firMenuView;          //一级菜单视图
@property (nonatomic ,retain) UIView *bottomView;           //二级菜单底部视图
@property (nonatomic ,retain) UIView *topView;              //二级菜单顶部视图
@property (nonatomic ,retain) NSArray *bottomArr;           //二级菜单底部button
@property (nonatomic ,retain) NSArray *topArr;              //二级菜单顶部button
@property (nonatomic ,retain) NSString *bottomText;         //二级菜单底部label的text
@property (nonatomic ,retain) NSString *topText;            //二级菜单顶部label的text
@property (nonatomic ,retain) NSArray *bottomImageArr;      //二级菜单图片数组
@property (nonatomic )int bottomTag;                        //二级菜单底部视图的tag值   用作二级菜单button的tag
@property (nonatomic )int topTag;                           //二级菜单顶部视图的tag值   用作二级菜单button的tag
@property (nonatomic )int firMenuButtonTag;                 //一级菜单button的tag值

@end
