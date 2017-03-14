//
//  FVideoViewController.h
//  FVideo
//
//  Created by coCo on 14-9-1.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import <UIKit/UIKit.h>

#include <synthesis/UISynthesisCallback.h>
@interface FVideoViewController : UIViewController<UIAlertViewDelegate, UISynthesisCallback>
{
    BOOL _bEnableSrcSound; //是否禁止原音播放
}
@property(nonatomic, assign) BOOL bEnableSrcSound;
/*
 @delegate: 回调对象
 @mediaPath: 原编辑视频
 @savepath: 编辑后保存路径
 @prevEditInfo: 上次编辑的xml数据结构信息字符串
//*/
-(void)initialize:(id)delegate withMediaPath:(NSString *)mediaPath withSavePath:(NSString*)savePath withPrevEditInfo:(NSString*)prevEditInfo;

-(void)removeProgressDialog;

@end
