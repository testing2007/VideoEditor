//
//  SSStageView.h
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-24.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "NotifyMsgToParent.h"
#import "ActionOperator.h"

@class SSUndoManager;
@class SSAction;
@class SSWarningFrameView;

@interface SSStageView : UIView//<NotifyMsgToParent>


- (id)init:(CGRect)frame withWarnRect:(CGRect)wrc;
- (void)uninit;

- (void)doIt:(SSAction*)action;
- (void)removeAllData;
- (BOOL)undo; //返回 YES 表示 undo 堆栈还不为空，可以继续支持 undo 操作，否则 undo 堆栈还为空，不再继续支持 undo 操作。
- (BOOL)redo; //返回 YES 表示 redo 堆栈还不为空，可以继续支持 redo 操作，否则 redo 堆栈还为空，不再继续支持 redo 操作。

//将服饰图片贴到ImageView上作为背景显示
- (void)attachBgImage:(NSData*)data;

@property(nonatomic, retain) UIImageView *bgImageView;
@property(nonatomic, retain) SSWarningFrameView *warningFrameView; //保存每个面的告警框区域

@property(nonatomic, retain) SSUndoManager *ssUndoManager;   //所有 撤销／重做 的操作只是针对舞台而言的

@property(nonatomic, retain) NSMutableArray *arrMaterialView;

- (UIImage*)transformToImage; //将自己由view转变成一个image.

-(UIView<ActionOperator>*)locateNextTopViewEditFocus; //定位下一个目标可以设定编辑按钮的view.如果不符合条件，返回nil；否则，返回目标对象。

@end
