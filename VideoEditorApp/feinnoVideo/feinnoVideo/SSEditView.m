//
//  SSEditView.m
//  SSShow
//
//  Created by weizhiqiangzz on 13-1-30.
//  Copyright (c) 2013年 weizhiqiangzz. All rights reserved.
//

#import "SSEditView.h"
#import "SSMoveBtn.h"
#import "SSRotateBtn.h"
#import "SSScaleBtn.h"
#import "SSDeleteBtn.h"
#import "SSOneFingerRotationGestureRecognizer.h"
#import "SSOneFingerScaleGestureRecognizer.h"
#import "SSStageView.h"
#import <QuartzCore/QuartzCore.h> //for debugging
#import "Action/SSAddAction.h"
#import "Action/SSRotateAction.h"
#import "Action/SSMoveAction.h"
#import "Action/SSScaleAction.h"
#import "Action/SSDeleteAction.h"

const int EDIT_BTN_WIDTH = 30;
const int EDIT_BTN_HIGHT = 30;

@interface SSEditView ()
{
    //移动按钮
    SSMoveBtn *m_moveBtn;
    //旋转按钮
    SSRotateBtn *m_rotateBtn;
    //缩放按钮
    SSScaleBtn *m_scaleBtn;
    //删除按钮
    //SSDeleteBtn *m_delBtn;
}
@end

static SSEditView* instance=nil; //单件实例

@implementation SSEditView
@synthesize associateView;

+(id)shareInstance
{
    if(nil == instance)
    {
        instance = [[super allocWithZone:nil]init];
    }
    return instance;
}

+(id)allocWithZone:(NSZone *)zone
{
    return [SSEditView shareInstance];
}

-(id)copy
{
    return self;
}

-(id)copyWithZone:(NSZone*)zone
{
    return self;
}
/*
-(id)retain
{
    return self;
}
-(id)autorelease
{
    return self;
}

-(NSUInteger)retainCount
{
    return NSUIntegerMax;
}

-(oneway void)release
{
    // do nothing
}
//*/
// -(id)init:(UIView<ActionOperator>*)_associateView

-(void)initLayout:(UIView<ActionOperator>*)_associateView
{
    assert(_associateView!=nil);
    [self setFrame:_associateView.frame];
    NSLog(@"the ass view is %@", _associateView);
    //先清除上一次编辑控制信息
    [self removeLayout];
    
    // Initialization code
    self.associateView = _associateView;
 
    //设置边框颜色
    self.associateView.layer.borderWidth = 1;
    self.associateView.layer.borderColor = [UIColor redColor].CGColor;
  
    //移动
    CGPoint ptCenterMoveBtn;
    ptCenterMoveBtn = self.associateView.frame.origin;
    CGRect rcMoveBtn = CGRectMake(ptCenterMoveBtn.x-EDIT_BTN_WIDTH/2,
                                  ptCenterMoveBtn.y-EDIT_BTN_HIGHT/2,
                                  EDIT_BTN_WIDTH,
                                  EDIT_BTN_HIGHT);
    m_moveBtn = [[SSMoveBtn alloc]initWithFrame:rcMoveBtn];
    [m_moveBtn setBackgroundColor:[UIColor blueColor]];
    [m_moveBtn setTitle:@"M" forState:UIControlStateNormal];
    [self addPanGestureToView:self.associateView];
    [self addPanGestureToView:m_moveBtn];
    assert([self.associateView.superview isKindOfClass:[SSStageView class]]);
    // [self.associateView.superview addSubview:m_moveBtn];
    
    //旋转
//    CGPoint ptCenterRotateBtn;
//    ptCenterRotateBtn.x = self.associateView.frame.origin.x+self.associateView.frame.size.width;
//    ptCenterRotateBtn.y = self.associateView.frame.origin.y;
//    CGRect rcRotateBtn = CGRectMake(ptCenterRotateBtn.x-EDIT_BTN_WIDTH/2,
//                                    ptCenterRotateBtn.y-EDIT_BTN_HIGHT/2,
//                                    EDIT_BTN_WIDTH,
//                                    EDIT_BTN_HIGHT);
//    m_rotateBtn = [[SSRotateBtn alloc]initWithFrame:rcRotateBtn];
//    m_rotateBtn.rotateView = self.associateView;
//    [m_rotateBtn setBackgroundColor:[UIColor blueColor]];
//    [m_rotateBtn setTitle:@"R" forState:UIControlStateNormal];
//    [self addRotationGestureToView:m_rotateBtn];
//    assert([self.associateView.superview  isKindOfClass:[SSStageView class]]);
//    [self.associateView.superview addSubview:m_rotateBtn];
    
    //缩放
    CGPoint ptCenterScaleBtn;
    ptCenterScaleBtn.x = self.associateView.frame.origin.x+self.associateView.frame.size.width;
    ptCenterScaleBtn.y = self.associateView.frame.origin.y+self.associateView.frame.size.height;
    CGRect rcScaleBtn = CGRectMake(ptCenterScaleBtn.x-EDIT_BTN_WIDTH/2,
                                   ptCenterScaleBtn.y-EDIT_BTN_HIGHT/2,
                                   EDIT_BTN_WIDTH,
                                   EDIT_BTN_HIGHT);
    m_scaleBtn = [[SSScaleBtn alloc]initWithFrame:rcScaleBtn];
    m_scaleBtn.scaleView = self.associateView;
    [m_scaleBtn setBackgroundColor:[UIColor blueColor]];
    [m_scaleBtn setTitle:@"S" forState:UIControlStateNormal];
    [self addScaleGestureToView:m_scaleBtn];
    //[self addPinchGestureToView:self.associateView];
    //[self addRotationGestureToView:m_scaleBtn];
    // [self addPinchGestureToView:m_scaleBtn];
    assert([self.associateView.superview  isKindOfClass:[SSStageView class]]);
    [self.associateView.superview addSubview:m_scaleBtn];

    //删除
//    CGPoint ptCenterDelBtn;
//    ptCenterDelBtn.x = self.associateView.frame.origin.x;
//    ptCenterDelBtn.y = self.associateView.frame.origin.y+self.associateView.frame.size.height;
//    CGRect rcDelBtn = CGRectMake(ptCenterDelBtn.x-EDIT_BTN_WIDTH/2,
//                                 ptCenterDelBtn.y-EDIT_BTN_HIGHT/2,
//                                 EDIT_BTN_WIDTH,
//                                 EDIT_BTN_HIGHT);
//    m_delBtn = [[SSDeleteBtn alloc]initWithFrame:rcDelBtn];
//    [m_delBtn setBackgroundColor:[UIColor blueColor]];
//    [m_delBtn setTitle:@"D" forState:UIControlStateNormal];
//    [m_delBtn addTarget:self action:@selector(pressDelAssociateView:) forControlEvents:UIControlEventTouchUpInside];
//    assert([self.associateView.superview  isKindOfClass:[SSStageView class]]);
//    [self.associateView.superview addSubview:m_delBtn];

    //增加添加行为
    [self handleAddAction:self.associateView.transform withPrevTransform:self.associateView.prevTransform];
}

-(void)removeLayout
{
    //清除原来边框的颜色
    if (self.associateView!=nil)
    {
        self.associateView.layer.borderWidth = 1;
        self.associateView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    if(m_moveBtn!=nil)
    {
        [m_moveBtn setHidden:YES];
    }
//    if(m_rotateBtn!=nil)
//    {
//        [m_rotateBtn setHidden:YES];
//    }
    if(m_scaleBtn!=nil)
    {
        [m_scaleBtn setHidden:YES];
    }
//    if(m_delBtn!=nil)
//    {
//        [m_delBtn setHidden:YES];
//    }
}

- (void)addRotationGestureToView:(UIView *)view
{
    SSOneFingerRotationGestureRecognizer *rotation = [[SSOneFingerRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotating:)];
    //## [view addGestureRecognizer:rotation];
}

- (void)addScaleGestureToView:(UIView *)view
{
    SSOneFingerScaleGestureRecognizer *scale = [[SSOneFingerScaleGestureRecognizer alloc] initWithTarget:self action:@selector(handleScale:)];
    [view addGestureRecognizer:scale];
}

- (void)addPanGestureToView:(UIView *)view
{
    UIPanGestureRecognizer *panRcognize=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [view addGestureRecognizer:panRcognize];
}

- (void)addPinchGestureToView:(UIView *)view
{
    UIPinchGestureRecognizer *pinchRcognize=[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [view addGestureRecognizer:pinchRcognize];
}

-(void)pressDelAssociateView:(id)sender
{
    [self removeLayout];
    
    CGAffineTransform curAssViewTransform = self.associateView.transform;
    CGAffineTransform prevTransform = CGAffineTransformMake(0, 0, 0, 0, 0, 0);
    [self.associateView setTransform:prevTransform];
    [self handleDeleteAction:curAssViewTransform withPrevTransform:prevTransform];
    associateView.prevTransform = self.associateView.transform;
    
    //定位下一个目标对象
    [self locateEditBtn:[(SSStageView*)self.associateView.superview locateNextTopViewEditFocus]];
}

-(void)locateEditBtn:(UIView<ActionOperator>*)targetView
{
    if(nil==targetView || self.associateView==targetView)
    {
        return ;//do nothing
    }
      
    [self removeLayout];
    
    self.associateView = targetView;
    //m_rotateBtn.rotateView = self.associateView;
    [self setFrame:self.associateView.frame];
    
    [self resetLayout];
    CGPoint cptMove, cptRotate, cptScale, cptDelete;
    cptMove = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptMoveBtnOffestRotatePoint
                             withPTRotateCenterRelateStageCoord:self.associateView.center];
    cptRotate = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptRotateBtnOffestRotatePoint
                               withPTRotateCenterRelateStageCoord:self.associateView.center];
    cptScale = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptScaleBtnOffestRotatePoint
                              withPTRotateCenterRelateStageCoord:self.associateView.center];
    cptDelete = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptDelBtnOffestRotatePoint
                               withPTRotateCenterRelateStageCoord:self.associateView.center];
    [self locateControlBtnPositionByBtnCenterPoint:cptMove
                                  withRotateBtnPos:cptRotate
                                   withScaleBtnPos:cptScale
                                  withDeleteBtnPos:cptDelete];
}

-(void)resetLayout
{
    [m_moveBtn setHidden:NO];
    //[m_rotateBtn setHidden:NO];
    [m_scaleBtn setHidden:NO];
    //[m_delBtn setHidden:NO];
}

//处理移动
- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    UIGestureRecognizerState state = recognizer.state;
    static CGPoint ptDeltaOffset; //完成移动操作操作的累计偏移量
    if(UIGestureRecognizerStateCancelled == state)
    {
        recognizer.view.transform = associateView.prevTransform;
        return ;
    }
    
    if(UIGestureRecognizerStateBegan == state)
    {
        associateView.prevTransform = recognizer.view.transform;
    }
    CGAffineTransform tranform = recognizer.view.transform;
    CGPoint ptOffset = [recognizer translationInView:self.associateView.superview]; //self.associateView旋转后，再次移动就不对了。translationInView 参数要是关联动作的父窗口
    ptDeltaOffset.x += ptOffset.x;
    ptDeltaOffset.y += ptOffset.y;

    [recognizer setTranslation:CGPointMake(0, 0) inView:self.associateView.superview];
    [self caculateBtnCPointAfterMove:ptOffset];
 
    if(UIGestureRecognizerStateEnded == state)
    {
        NSLog(@"recognizer.view.center:(x=%f, y=%f)", recognizer.view.center.x, recognizer.view.center.y);
        CGAffineTransform curTransform = recognizer.view.transform;
        curTransform.tx = ptDeltaOffset.x;
        curTransform.ty = ptDeltaOffset.y;
        ptDeltaOffset.x = 0;
        ptDeltaOffset.y = 0;
        [self handleMoveAction:curTransform withPrevTransform:associateView.prevTransform];
        associateView.prevTransform = recognizer.view.transform;
    }
    else
    {
        recognizer.view.transform = tranform;
    }
}

-(void)locateControlBtnPositionByBtnCenterPoint:(CGPoint)cptMove
                               withRotateBtnPos:(CGPoint)cptRotate
                                withScaleBtnPos:(CGPoint)cptScale
                               withDeleteBtnPos:(CGPoint)cptDelete
{
    [m_moveBtn setFrame:[self getControlBtnPos:cptMove]];
    [m_rotateBtn setFrame:[self getControlBtnPos:cptRotate]];
    [m_scaleBtn setFrame:[self getControlBtnPos:cptScale]];
    // [m_delBtn setFrame:[self getControlBtnPos:cptDelete]];
}

-(void)locateControlBtnPositionByBtnCenterPoint:(CGPoint)cptEdit
{
    [m_scaleBtn setFrame:[self getControlBtnPos:cptEdit]];
}

//处理旋转
- (void)handleRotating:(SSOneFingerRotationGestureRecognizer *)recognizer
{
    UIView *assView = ((SSRotateBtn *)recognizer.view).rotateView/*.superview*/;
    UIGestureRecognizerState state = recognizer.state;
    if(UIGestureRecognizerStateCancelled == state)
    {
        assView.transform = associateView.prevTransform;
        return ;
    }
    if(UIGestureRecognizerStateBegan == state)
    {
        associateView.prevTransform = assView.transform;
    }
    [assView setTransform:CGAffineTransformRotate([assView transform], [recognizer rotation])];
    
    [self caculateBtnCPointAfterRotate:[recognizer rotation]];
    if(UIGestureRecognizerStateEnded == state)
    {
        CGAffineTransform curAssViewTransform = assView.transform;
//        [self handleRotationAction:curAssViewTransform withPrevTransform:associateView.prevTransform withDiffAngleFromPrevToCur:recognizer.deltaRotation];
        associateView.prevTransform = curAssViewTransform;
    }
//    recognizer.rotation = 0;
}

- (void)handleScale:(SSOneFingerScaleGestureRecognizer *)recognizer
{
    // recognizer setScale:<#(CGFloat)#>
    //*
    UIView *view = ((SSScaleBtn *)recognizer.view).scaleView;
    UIGestureRecognizerState state = recognizer.state;
    if(UIGestureRecognizerStateCancelled == state)
    {
        view.transform = associateView.prevTransform;
        return ;
    }
    if(UIGestureRecognizerStateBegan == state)
    {
        associateView.prevTransform = view.transform;
    }
    NSLog(@"the transform is (a=%f, b=%f, c=%f, d=%f, tx=%f, ty=%f)", view.transform.a, view
          .transform.b, view.transform.c, view.transform.d, view.transform.tx, view.transform.ty);
//    [view setTransform:CGAffineTransformRotate([view transform], [recognizer rotation1])];
//    NSLog(@"angle=%f", [recognizer rotation1]);
//    [self caculateBtnCPointAfterRotate:[recognizer rotation1]];
//    if(UIGestureRecognizerStateEnded == state)
//    {
//        CGAffineTransform curAssViewTransform = view.transform;
//        //        [self handleRotationAction:curAssViewTransform withPrevTransform:associateView.prevTransform withDiffAngleFromPrevToCur:recognizer.deltaRotation];
//        associateView.prevTransform = curAssViewTransform;
//    }
    
    CGPoint ptScale = [recognizer ptScale];
//    if ( (ptScale.y>-0.001&&ptScale.y<0.001) && (ptScale.x>-0.001&&ptScale.x<0.001) )
//        return ;
    // CGAffineTransform tranform = view.transform;
    NSLog(@"handleScale START view transform scale x=%f, y=%f", ptScale.x, ptScale.y);
//    CGPoint cptScale, cptDelete;
//    cptScale = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptScaleBtnOffestRotatePoint withPTRotateCenterRelateStageCoord:self.associateView.center];
//    cptDelete = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptDelBtnOffestRotatePoint withPTRotateCenterRelateStageCoord:self.associateView.center];
//    
//    if( ((cptScale.x-cptDelete.x<(2*EDIT_BTN_WIDTH))&&(cptScale.y-cptDelete.y<(2*EDIT_BTN_HIGHT))) && ((ptScale.x<0.0001||(ptScale.y<0.0001))) )
//    {
//        //距离很近，不能再缩放了。
//        return ;
//    }
    // [view setTransform:CGAffineTransformRotate(view.transform, [recognizer rotation])];
//    [view setTransform:CGAffineTransformScale(view.transform, 1+ptScale.x, 1+ptScale.y)];
//    // [self caculateBtnCPointAfterEdit:ptScale withRotationAngle:[recognizer rotation]];
//    CGPoint ptScaleTemp = CGPointMake(ptScale.x+1, ptScale.y+1);
//    [self caculateBtnCPointAfterEdit:ptScaleTemp withRotationAngle:[recognizer rotation]];
   [self caculateBtnCPointAfterEdit:CGPointMake(1.0f, 1.0f) withRotationAngle:[recognizer rotation]];
}

-(void) caculateBtnCPointAfterEdit:(CGPoint)ptScale withRotationAngle:(CGFloat)fAngle
{
//    if ((ptScale.x>-0.001&&ptScale.x<0.001) && (ptScale.y>-0.001&&ptScale.y<0.001) && (fAngle>-0.001&&fAngle<0.001))
//        return ;

    //计算相对于旋转view的旋转点得到旋转后的偏移量，这个计算出来的结果值是相对于旋转点为原点得到的坐标。
    CGPoint cptEdit;
    self.associateView.ptScaleBtnOffestRotatePoint
    = [self getPointReleateRotatePointCoordAfterRotate:self.associateView.ptScaleBtnOffestRotatePoint
                              withRotateAngle:fAngle];
    
    //缩放
    CGPoint pt;
    pt.x = self.associateView.ptScaleBtnOffestRotatePoint.x*ptScale.x;
    pt.y = self.associateView.ptScaleBtnOffestRotatePoint.y*ptScale.y;
    self.associateView.ptScaleBtnOffestRotatePoint = pt;
    //把旋转后相对于旋转view的中心点为原点的坐标转换成相对于舞台的坐标点
    cptEdit = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptScaleBtnOffestRotatePoint
                              withPTRotateCenterRelateStageCoord:self.associateView.center];
    
    [self locateControlBtnPositionByBtnCenterPoint:cptEdit];
}

//处理缩放
- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    // NSLog(@"handlePinch---");
    UIView *view = recognizer.view;
    UIGestureRecognizerState state = recognizer.state;
    if(UIGestureRecognizerStateCancelled == state)
    {
        view.transform = associateView.prevTransform;
        return ;
    }
    
    if(UIGestureRecognizerStateBegan == state)
    {
       associateView.prevTransform = view.transform;
    }    
    
    CGFloat factor;
    if (recognizer.scale > 1)
    {
        //---zooming in---
        factor = associateView.prevScale + (recognizer.scale - 1);
    }
    else
    {
        //---zooming out--- 
        factor = associateView.prevScale * recognizer.scale;
    }
    CGAffineTransform tranform = view.transform;
    tranform = CGAffineTransformScale(tranform, recognizer.scale, recognizer.scale);
    
    [self caculateBtnCPointAfterScale:factor withYScale:factor];
     if(UIGestureRecognizerStateEnded == state)
    {
        CGAffineTransform curTransform = recognizer.view.transform;
        [self handleScaleAction:curTransform withPrevTransform:self.associateView.prevTransform];
//        NSLog(@"curTransform:(a=%f, b=%f, c=%f, d=%f, tx=%f, ty=%f", curTransform.a, curTransform.b, curTransform.c, curTransform.d, curTransform.tx, curTransform.ty);
//        NSLog(@"prevTransform:(a=%f, b=%f, c=%f, d=%f, tx=%f, ty=%f", self.associateView.prevTransform.a, self.associateView.prevTransform.b, self.associateView.prevTransform.c,self.associateView.prevTransform.d, self.associateView.prevTransform.tx, self.associateView.prevTransform.ty);
      
        if (recognizer.scale > 1)
        {
            associateView.prevScale += (recognizer.scale - 1);
        }
        else
        {
            associateView.prevScale *= recognizer.scale;
        }
        associateView.prevTransform = view.transform;
    }
    else
    {
        view.transform = tranform;
    }
    
    [recognizer setScale:1];
}

-(CGPoint) getPointReleateRotatePointCoordAfterRotate:(CGPoint)ptBeforeRotate withRotateAngle:(float)fAngle
{
    CGPoint pt;
    pt.x = ptBeforeRotate.x*cosf(fAngle)+ptBeforeRotate.y*-sinf(fAngle);
    pt.y = ptBeforeRotate.x*sinf(fAngle)+ptBeforeRotate.y*cosf(fAngle);
    return pt;
}

-(CGPoint) convertPtRelateRotatePointCoordToStageCoord:(CGPoint)ptRelateRotatePointCoord withPTRotateCenterRelateStageCoord:(CGPoint)ptCenterAssociateView
{
    CGPoint pt;
    pt.x = ptCenterAssociateView.x+ptRelateRotatePointCoord.x;
    pt.y = ptCenterAssociateView.y+ptRelateRotatePointCoord.y;
    return pt;
}
                                       
-(CGRect) getControlBtnPos:(CGPoint)ptCenter
{
    return CGRectMake(ptCenter.x-EDIT_BTN_WIDTH/2,
                      ptCenter.y-EDIT_BTN_HIGHT/2,
                      EDIT_BTN_WIDTH,
                      EDIT_BTN_HIGHT);
}

-(void)handleAddAction:(CGAffineTransform)curTransform
        withPrevTransform:(CGAffineTransform)preTransform
{
    SSAddAction *addAction = [[SSAddAction alloc]initWithInfo:self.associateView
                                             withCurTransform:curTransform
                                            withPrevTransform:preTransform];
    [(SSStageView*)self.associateView.superview doIt:addAction];
}

-(void)handleMoveAction:(CGAffineTransform)curTransform
         withPrevTransform:(CGAffineTransform)preTransform
{
    SSMoveAction *moveAction = [[SSMoveAction alloc]initWithInfo:self.associateView
                                                withCurTransform:curTransform
                                               withPrevTransform:preTransform];
    [(SSStageView*)self.associateView.superview doIt:moveAction];
}

-(void)handleRotationAction:(CGAffineTransform)curTransform
             withPrevTransform:(CGAffineTransform)preTransform
    withDiffAngleFromPrevToCur:(CGFloat)fDiffAngleFromPrevToCur
{
    SSRotateAction *rotateAction = [[SSRotateAction alloc]initWithInfo:self.associateView
                                                      withCurTransform:curTransform
                                                     withPrevTransform:preTransform
                                            withDiffAngleFromPrevToCur:fDiffAngleFromPrevToCur];
    [(SSStageView*)self.associateView.superview doIt:rotateAction];
}

-(void)handleScaleAction:(CGAffineTransform)curTransform withPrevTransform:(CGAffineTransform)preTransform
{
    SSScaleAction *scaleAction = [[SSScaleAction alloc]initWithInfo:self.associateView
                                                   withCurTransform:curTransform
                                                  withPrevTransform:preTransform];
    [(SSStageView*)self.associateView.superview doIt:scaleAction];
}

-(void)handleDeleteAction:(CGAffineTransform)curTransform withPrevTransform:(CGAffineTransform)preTransform
{
    SSDeleteAction *deleteAction = [[SSDeleteAction alloc]initWithInfo:self.associateView
                                                      withCurTransform:curTransform
                                                     withPrevTransform:preTransform];
    [(SSStageView*)self.associateView.superview doIt:deleteAction];
}

-(void)caculateBtnCPointAfterMove:(CGPoint)ptOffset
{
    self.associateView.center = CGPointMake(self.associateView.center.x + ptOffset.x, self.associateView.center.y + ptOffset.y);
    
    CGPoint cptMove, cptRotate, cptScale, cptDelete;
    cptMove = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptMoveBtnOffestRotatePoint
                             withPTRotateCenterRelateStageCoord:self.associateView.center];
    cptRotate = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptRotateBtnOffestRotatePoint
                               withPTRotateCenterRelateStageCoord:self.associateView.center];
    cptScale = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptScaleBtnOffestRotatePoint
                              withPTRotateCenterRelateStageCoord:self.associateView.center];
    cptDelete = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptDelBtnOffestRotatePoint
                               withPTRotateCenterRelateStageCoord:self.associateView.center];
    
    [self locateControlBtnPositionByBtnCenterPoint:cptMove
                                      withRotateBtnPos:cptRotate
                                       withScaleBtnPos:cptScale
                                      withDeleteBtnPos:cptDelete];
}

-(void)caculateBtnCPointAfterUndoMove:(CGPoint)ptOffset
{
 [self caculateBtnCPointAfterMove:ptOffset];
}

-(void)caculateBtnCPointAfterRedoMove:(CGPoint)ptOffset
{
 [self caculateBtnCPointAfterMove:ptOffset];
}

-(void)caculateBtnCPointAfterRotate:(CGFloat)fAngle
{
    //移动按钮
    //计算相对于旋转view的旋转点得到旋转后的偏移量，这个计算出来的结果值是相对于旋转点为原点得到的坐标。
    CGPoint cptMove, cptRotate, cptScale, cptDelete;
    self.associateView.ptMoveBtnOffestRotatePoint = [self getPointReleateRotatePointCoordAfterRotate:self.associateView.ptMoveBtnOffestRotatePoint
                                                                                     withRotateAngle:fAngle];
    //把旋转后相对于旋转view的中心点为原点的坐标转换成相对于舞台的坐标点
    cptMove = [[SSEditView shareInstance] convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptMoveBtnOffestRotatePoint
                                                   withPTRotateCenterRelateStageCoord:self.associateView.center];
    
    
    self.associateView.ptRotateBtnOffestRotatePoint = [[SSEditView shareInstance] getPointReleateRotatePointCoordAfterRotate:self.associateView.ptRotateBtnOffestRotatePoint
                                                                                                             withRotateAngle:fAngle];
    cptRotate = [[SSEditView shareInstance] convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptRotateBtnOffestRotatePoint
                                                                                           withPTRotateCenterRelateStageCoord:self.associateView.center];
    
    self.associateView.ptScaleBtnOffestRotatePoint = [[SSEditView shareInstance] getPointReleateRotatePointCoordAfterRotate:self.associateView.ptScaleBtnOffestRotatePoint
                                                                                                            withRotateAngle:fAngle];
    cptScale = [[SSEditView shareInstance] convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptScaleBtnOffestRotatePoint
                                                    withPTRotateCenterRelateStageCoord:self.associateView.center];
    
    self.associateView.ptDelBtnOffestRotatePoint = [[SSEditView shareInstance] getPointReleateRotatePointCoordAfterRotate:self.associateView.ptDelBtnOffestRotatePoint
                                                                                                          withRotateAngle:fAngle];
    cptDelete = [[SSEditView shareInstance] convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptDelBtnOffestRotatePoint
                                                     withPTRotateCenterRelateStageCoord:self.associateView.center];
    
    [self locateControlBtnPositionByBtnCenterPoint:cptMove
                                      withRotateBtnPos:cptRotate
                                       withScaleBtnPos:cptScale
                                      withDeleteBtnPos:cptDelete];
}
-(void)caculateBtnCPointAfterUndoRotate:(CGFloat)fAngle
{
    [self caculateBtnCPointAfterRotate:fAngle];
}

-(void)caculateBtnCPointAfterRedoRotate:(CGFloat)fAngle
{
    [self caculateBtnCPointAfterRotate:fAngle];
}

-(void)caculateBtnCPointAfterScale:(CGFloat)fxScale
                           withYScale:(CGFloat)fyScale
{
    if ((fxScale>-0.001&&fxScale<0.001) && (fyScale>-0.001&&fyScale<0.001))
        return ;
    
    //移动
    CGPoint pt;
    CGPoint cptMove, cptRotate, cptScale, cptDelete;
    pt.x = self.associateView.ptMoveBtnOffestRotatePoint.x*fxScale;
    pt.y = self.associateView.ptMoveBtnOffestRotatePoint.y*fyScale;
    self.associateView.ptMoveBtnOffestRotatePoint = pt;
    cptMove = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptMoveBtnOffestRotatePoint
                                withPTRotateCenterRelateStageCoord:self.associateView.center];
    //旋转
    pt.x = self.associateView.ptRotateBtnOffestRotatePoint.x*fxScale;
    pt.y = self.associateView.ptRotateBtnOffestRotatePoint.y*fyScale;
    self.associateView.ptRotateBtnOffestRotatePoint = pt;
    cptRotate = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptRotateBtnOffestRotatePoint
                               withPTRotateCenterRelateStageCoord:self.associateView.center];
    //缩放
    pt.x = self.associateView.ptScaleBtnOffestRotatePoint.x*fxScale;
    pt.y = self.associateView.ptScaleBtnOffestRotatePoint.y*fyScale;
    self.associateView.ptScaleBtnOffestRotatePoint = pt;
    cptScale = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptScaleBtnOffestRotatePoint
                              withPTRotateCenterRelateStageCoord:self.associateView.center];
    //删除
    pt.x = self.associateView.ptDelBtnOffestRotatePoint.x*fxScale;
    pt.y = self.associateView.ptDelBtnOffestRotatePoint.y*fyScale;
    self.associateView.ptDelBtnOffestRotatePoint = pt;
    cptDelete = [self convertPtRelateRotatePointCoordToStageCoord:self.associateView.ptDelBtnOffestRotatePoint
                               withPTRotateCenterRelateStageCoord:self.associateView.center];
    
    [self locateControlBtnPositionByBtnCenterPoint:cptMove
                                      withRotateBtnPos:cptRotate
                                       withScaleBtnPos:cptScale
                                      withDeleteBtnPos:cptDelete];
}

-(void)caculateBtnCPointAfterUndoScale:(CGFloat)fxScale
                               withYScale:(CGFloat)fyScale;
{
    [self caculateBtnCPointAfterScale:fxScale
                           withYScale:fyScale];
}
-(void)caculateBtnCPointAfterRedoScale:(CGFloat)fxScale
                            withYScale:(CGFloat)fyScale;
{
    [self caculateBtnCPointAfterScale:fxScale
                            withYScale:fyScale];
}
/*
-(void)caculateBtnCPointAfterDelete
{
    [[SSEditView shareInstance] removeLayout];
}
//*/
-(void)caculateBtnCPointAfterUndoDelete
{
    [[SSEditView shareInstance] resetLayout];
}
-(void)caculateBtnCPointAfterRedoDelete
{
    [[SSEditView shareInstance] removeLayout];
}

-(void)caculateBtnCPointAfterUndoAdd
{
    [self caculateBtnCPointAfterRedoDelete];
    //定位下一个目标对象
    [self locateEditBtn:[(SSStageView*)self.associateView.superview locateNextTopViewEditFocus]];
}

-(void)caculateBtnCPointAfterRedoAdd
{
    [self caculateBtnCPointAfterUndoDelete];
    //定位下一个目标对象
    [self locateEditBtn:[(SSStageView*)self.associateView.superview locateNextTopViewEditFocus]];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGRect rcRotateBtn = CGRectMake(ptLURotateBtn.x,
                                    ptLURotateBtn.y,
                                    ptLURotateBtn.x+EDIT_BTN_WIDTH,
                                    ptLURotateBtn.y+EDIT_BTN_HIGHT);
    [m_rotateBtn setFrame:rcRotateBtn];
    //[self addSubview:m_rotateBtn];
}
//*/

@end
