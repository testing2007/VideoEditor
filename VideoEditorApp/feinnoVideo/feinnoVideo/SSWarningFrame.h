//
//  SSWarningFrame.h
//  testDownload
//
//  Created by weizhiqiangzz on 12-12-23.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface SSWarningFrame : NSObject

@property(nonatomic) int nId; //id 最小值为1,每次加1
@property(nonatomic) CGRect rc;//(x, y, width, height)
//NSDictionary<nId, SSWarningFrame>
@end
