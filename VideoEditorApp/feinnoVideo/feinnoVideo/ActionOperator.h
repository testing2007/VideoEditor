//
//  ActionOperator.h
//  SSShow
//
//  Created by weizhiqiangzz on 13-3-4.
//  Copyright (c) 2013年 weizhiqiangzz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol ActionOperator <NSObject>

@optional
@property(nonatomic, assign) CGAffineTransform prevTransform; //方便撤销／重做
@property(nonatomic, assign) CGPoint ptMoveBtnOffestRotatePoint; ///移动按钮距离旋转点坐标，该点坐标是相对于中心的旋转点
@property(nonatomic, assign) CGPoint ptRotateBtnOffestRotatePoint; ///移动按钮距离旋转点坐标，该点坐标是相对于中心的旋转点
@property(nonatomic, assign) CGPoint ptScaleBtnOffestRotatePoint; ///缩放按钮距离旋转点坐标，该点坐标是相对于中心的旋转点
@property(nonatomic, assign) CGPoint ptDelBtnOffestRotatePoint; ///删除按钮距离旋转点坐标，该点坐标是相对于中心的旋转点

@property(nonatomic, assign) CGPoint ptControlBtnOffsetPoint;// 控制按钮距离旋转点坐标，该点坐标是相对于中心的旋转点

@property(nonatomic, assign) float prevScale; //上一次缩放比

@end







