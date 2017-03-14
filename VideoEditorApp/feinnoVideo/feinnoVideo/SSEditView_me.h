//
//  SSEditView.h
//  SSShow
//
//  Created by weizhiqiangzz on 13-1-30.
//  Copyright (c) 2013年 weizhiqiangzz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionOperator.h"

@class SSRotateBtn;

@interface SSEditView : UIView

+(id)shareInstance;

-(void)initLayout:(UIView<ActionOperator>*)_associateView;
-(void)removeLayout;

//通过各个按钮的中心点坐标定位每个按钮的位置
-(void)locateControlBtnPositionByBtnCenterPoint:(CGPoint)cptMove
                               withRotateBtnPos:(CGPoint)cptRotate
                                withScaleBtnPos:(CGPoint)cptScale
                               withDeleteBtnPos:(CGPoint)cptDelete;

-(CGPoint) getPointReleateRotatePointCoordAfterRotate:(CGPoint)ptBeforeRotate withRotateAngle:(float)fAngle;
-(CGPoint) convertPtRelateRotatePointCoordToStageCoord:(CGPoint)ptRelateRotatePointCoord withPTRotateCenterRelateStageCoord:(CGPoint)ptCenterAssociateView;

-(void)caculateBtnCPointAfterMove:(CGPoint)ptOffset;
-(void)caculateBtnCPointAfterUndoMove:(CGPoint)ptOffset;
-(void)caculateBtnCPointAfterRedoMove:(CGPoint)ptOffset;
-(void)caculateBtnCPointAfterRotate:(CGFloat)fAngle;
-(void)caculateBtnCPointAfterUndoRotate:(CGFloat)fAngle;
-(void)caculateBtnCPointAfterRedoRotate:(CGFloat)fAngle;
-(BOOL)caculateBtnCPointAfterScale:(CGFloat)fxScale
                           withYScale:(CGFloat)fyScale;
-(void)caculateBtnCPointAfterUndoScale:(CGFloat)fxScale
                               withYScale:(CGFloat)fyScale;
-(void)caculateBtnCPointAfterRedoScale:(CGFloat)fxScale
                               withYScale:(CGFloat)fyScale;

// -(void)caculateBtnCPointAfterDelete;
-(void)caculateBtnCPointAfterUndoDelete;
-(void)caculateBtnCPointAfterRedoDelete;
-(void)caculateBtnCPointAfterUndoAdd;
-(void)caculateBtnCPointAfterRedoAdd;

-(void)locateEditBtn:(UIView<ActionOperator>*)targetView;

@property(nonatomic, retain) UIView<ActionOperator>* associateView;

@end
