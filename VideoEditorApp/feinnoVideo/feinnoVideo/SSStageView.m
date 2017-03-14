//
//  SSStageView.m
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-24.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSStageView.h"
#import "SSUndoManager.h"
#import "Action/SSAction.h"
#import "Action/SSAddAction.h"
#import "Action/SSMoveAction.h"
#import "Action/SSRotateAction.h"
#import "Action/SSScaleAction.h"
#import "Action/SSDeleteAction.h"
#import "SSImageView.h"
#import "SSWarningFrameView.h"
#import <QuartzCore/QuartzCore.h> 
#import "SSEditView.h"
#import "SSTextView.h"

@interface SSStageView()
{
    
}
@end

@implementation SSStageView
@synthesize ssUndoManager;
@synthesize bgImageView;
@synthesize warningFrameView;
@synthesize arrMaterialView;

- (id)init:(CGRect)frame withWarnRect:(CGRect)wrc
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        // Initialization code
        ssUndoManager = [[SSUndoManager alloc]init];
        
        bgImageView = [[UIImageView alloc]init];
        CGRect _rc = frame;
        _rc.origin.x = 0;
        _rc.origin.y = 0;
        bgImageView.frame = _rc;
        [self addSubview:bgImageView];
        
        arrMaterialView = [NSMutableArray arrayWithCapacity:1];
        
        warningFrameView = [[SSWarningFrameView alloc] initWithFrame:CGRectMake(wrc.origin.x,
                                                                            wrc.origin.y,
                                                                            wrc.size.width,
                                                                            wrc.size.height)];
        // [warningFrameView setHidden:NO];
        [self addSubview:warningFrameView];
        // [self.warningFrameView setNeedsDisplay];
    }
    return self;
}

- (void)uninit
{
    if(ssUndoManager!=nil)
    {
        [ssUndoManager removeAllData];
    }
    bgImageView = nil;
    warningFrameView = nil;
}

- (void)doIt:(SSAction*)action
{
    //清除redo里面相关的view
    for(SSAction* view in ssUndoManager.arrRedo)
    {
        if((view.targetObject != NULL) &&
           (   (([view.targetObject isKindOfClass:[SSImageView class]]) && view.nId==ADD_ACTION) ||
               (([view.targetObject isKindOfClass:[SSTextView class]]) && view.nId==ADD_ACTION)    )
          )
        {
            [view.targetObject removeFromSuperview];
        }
    }
    
    [ssUndoManager doIt:action];
    //[self.delegate Pr_setUndoRedoBtnStatusByNewAction];
    [self.warningFrameView setNeedsDisplay];
}

- (void)attachBgImage:(NSData*)data
{
    if(self.bgImageView!=nil)
    {
        [bgImageView setImage:[UIImage imageWithData:data]];
    }
}

- (void)removeAllData
{
    [ssUndoManager removeAllData];
    [self setNeedsDisplay];
}

- (BOOL)undo
{
    SSAction* curAction = nil;
    BOOL bReturn = [ssUndoManager undo:&curAction];
    assert(curAction!=nil);
    assert(curAction.nId!=UNKNOWN_ACTION);
    switch (curAction.nId)
    {
        case ADD_ACTION:
        {
            SSAddAction *addAction = (SSAddAction*)curAction;
            [addAction.targetObject setTransform:addAction.prevTransform];
            [[SSEditView shareInstance]caculateBtnCPointAfterUndoAdd];
         }
            break;
        case MOVE_ACTION:
        {
            SSMoveAction *moveAction = (SSMoveAction*)curAction;
            // [moveAction.targetObject setTransform:CGAffineTransformTranslate(moveAction.curTransform, -1*moveAction.fTxFromPrevToCur, -1*moveAction.fTyFromPrevToCur)];
            // NOTE:不能按预期的方式进行工作
//            NSLog(@"before undo center:(x=%f, y=%f)", moveAction.targetObject.center.x, moveAction.targetObject.center.y);
//            moveAction.targetObject.center = CGPointMake(moveAction.targetObject.center.x+(-1*moveAction.fTxFromPrevToCur),
//                                                              moveAction.targetObject.center.y+(-1*moveAction.fTyFromPrevToCur));
//            NSLog(@"after undo center:(x=%f, y=%f)", moveAction.targetObject.center.x, moveAction.targetObject.center.y);
            [[SSEditView shareInstance]caculateBtnCPointAfterUndoMove:CGPointMake(-1*moveAction.fTxFromPrevToCur, -1*moveAction.fTyFromPrevToCur)];
        }
            break;
        case ROTATE_ACTION:
        {
            SSRotateAction *rotateAction = (SSRotateAction*)curAction;
            [rotateAction.targetObject setTransform:CGAffineTransformRotate(rotateAction.curTransform, -1*rotateAction.fDiffAngleFromPrevToCur)];
            [[SSEditView shareInstance]caculateBtnCPointAfterUndoRotate:-1*rotateAction.fDiffAngleFromPrevToCur];
        }
            break;
        case SCALE_ACTON:
        {
            SSScaleAction *scaleAction = (SSScaleAction*)curAction;
            // CGFloat fSX = 1/scaleAction.curTransform.a;
            // CGFloat fSY = 1/scaleAction.curTransform.d;
            CGFloat fSX = scaleAction.prevTransform.a/scaleAction.curTransform.a;
            CGFloat fSY = scaleAction.prevTransform.d/scaleAction.curTransform.d;
            [scaleAction.targetObject setTransform:CGAffineTransformScale(scaleAction.curTransform, fSX, fSY)];
            [[SSEditView shareInstance]caculateBtnCPointAfterUndoScale:fSX withYScale:fSY];
        }
            break;
        case DELETE_ACTION:
        {
            SSDeleteAction *deleteAction = (SSDeleteAction*)curAction;
            [deleteAction.targetObject setTransform:deleteAction.curTransform];
            [[SSEditView shareInstance]caculateBtnCPointAfterUndoDelete];
        }
            break;
    }
    
//    if(curAction.nId!=UNKNOWN_ACTION || curAction.nId!=DELETE_ACTION)
//    {
//        [self bringSubviewToFront:curAction.targetObject];
//    }
//    
    return bReturn;
}

- (BOOL)redo
{
    SSAction* curAction = nil;
    BOOL bReturn = [ssUndoManager redo:&curAction];
    assert(curAction!=nil);
    assert(curAction.nId!=UNKNOWN_ACTION);
    switch (curAction.nId)
    {
        case ADD_ACTION:
        {
            SSAddAction *addAction = (SSAddAction*)curAction;
            [addAction.targetObject setTransform:addAction.curTransform];
            [[SSEditView shareInstance]caculateBtnCPointAfterRedoAdd];
            //[[SSEditView shareInstance]locateEditBtn:addAction.targetObject];
            // [[SSEditView shareInstance]caculateBtnCPointAfterRedoDelete];
        }
            break;
        case MOVE_ACTION:
        {
            SSMoveAction *moveAction = (SSMoveAction*)curAction;
//            [moveAction.targetObject setTransform:CGAffineTransformTranslate(moveAction.prevTransform, moveAction.fTxFromPrevToCur, moveAction.fTyFromPrevToCur)];
//            NSLog(@"before redo center:(x=%f, y=%f)", moveAction.targetObject.center.x, moveAction.targetObject.center.y);
//            moveAction.targetObject.center = CGPointMake(moveAction.targetObject.center.x+moveAction.fTxFromPrevToCur,
//                                                              moveAction.targetObject.center.y+moveAction.fTyFromPrevToCur);
//            NSLog(@"after redo center:(x=%f, y=%f)", moveAction.targetObject.center.x, moveAction.targetObject.center.y);
            [[SSEditView shareInstance]caculateBtnCPointAfterRedoMove:CGPointMake(moveAction.fTxFromPrevToCur, moveAction.fTyFromPrevToCur)];
        }
            break;
        case ROTATE_ACTION:
        {
            SSRotateAction *rotateAction = (SSRotateAction*)curAction;
            [rotateAction.targetObject setTransform:CGAffineTransformRotate(rotateAction.prevTransform, rotateAction.fDiffAngleFromPrevToCur)];
            [[SSEditView shareInstance]caculateBtnCPointAfterRedoRotate:rotateAction.fDiffAngleFromPrevToCur];
        }
            break;
        case SCALE_ACTON:
        {
            SSScaleAction *scaleAction = (SSScaleAction*)curAction;
            CGFloat fSX = scaleAction.curTransform.a/scaleAction.prevTransform.a;
            CGFloat fSY = scaleAction.curTransform.d/scaleAction.prevTransform.d;
            [scaleAction.targetObject setTransform:CGAffineTransformScale(scaleAction.prevTransform, fSX, fSY)];
            [[SSEditView shareInstance]caculateBtnCPointAfterRedoScale:fSX withYScale:fSY];
        }
            break;
        case DELETE_ACTION:
        {
            SSDeleteAction *deleteAction = (SSDeleteAction*)curAction;
            [deleteAction.targetObject setTransform:deleteAction.prevTransform];
            [[SSEditView shareInstance]caculateBtnCPointAfterRedoDelete];
        }
            break;
    }
    
//    if(curAction.nId!=UNKNOWN_ACTION || curAction.nId!=DELETE_ACTION)
//    {
//        [self bringSubviewToFront:curAction.targetObject];
//    }
    
    return bReturn;
}

- (UIImage*)transformToImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, self.layer.contentsScale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIView<ActionOperator>*)locateNextTopViewEditFocus
{
    int nViewCount = self.subviews.count;
    NSArray *arrView = self.subviews;
    UIView<ActionOperator>* targetView = nil;
    for (int nIndex=nViewCount-1; nIndex>=0; --nIndex)
    {
        if( ([arrView[nIndex] isKindOfClass:[SSImageView class]] || [arrView[nIndex] isKindOfClass:[SSTextView class]]) &&
            !CGAffineTransformEqualToTransform(((UIView*)arrView[nIndex]).transform, CGAffineTransformMake(0, 0, 0, 0, 0, 0)) )
        {
            targetView = arrView[nIndex];
            break;
        }
    }
    return targetView;
}

//*
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Fail when more than 1 finger detected.
    if ([touches count] > 1)
    {
        return ;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    UIView<ActionOperator>* targetView = nil;
    int nViewCount = self.subviews.count;
    NSArray *arrView = self.subviews;
    for (int nIndex=nViewCount-1; nIndex>=0; --nIndex)
    {
        if( ([arrView[nIndex] isKindOfClass:[SSImageView class]] || [arrView[nIndex] isKindOfClass:[SSTextView class]]) &&
           !CGAffineTransformEqualToTransform(((UIView*)arrView[nIndex]).transform, CGAffineTransformMake(0, 0, 0, 0, 0, 0)) )
        {
            CGPoint ptCandidateCoord = [self convertPoint:pt toView:arrView[nIndex]];
            if([arrView[nIndex] pointInside:ptCandidateCoord withEvent:nil])
            {
                targetView = arrView[nIndex];
                break;
            }
        }
    }
    if(targetView!=nil)
    {
        // [self bringSubviewToFront:targetView];
        [[SSEditView shareInstance] locateEditBtn:targetView];
    }
}
//*/
@end
