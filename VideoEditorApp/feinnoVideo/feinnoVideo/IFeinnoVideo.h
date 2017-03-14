//
//  IFeinnoVideo.h
//  FeinnoVideoApp
//
//  Created by wzq on 14-9-25.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol IFeinnoVideo <NSObject>

/*
 @delegate: 回调对象
 @mediaPath: 原编辑视频
 @savepath: 编辑后保存路径
 @prevEditInfo: 上次编辑的xml数据结构信息字符串
 //*/
-(UIViewController*)initialize:(id)delegate withMediaPath:(NSString *)mediaPath withSavePath:(NSString*)savePath withPrevEditInfo:(NSString*)prevEditInfo;

@end
