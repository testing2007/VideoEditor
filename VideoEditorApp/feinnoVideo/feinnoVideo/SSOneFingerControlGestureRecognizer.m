//
//  SSOneFingerControlGestureRecognizer.m
//  libFeinnoVideo
//
//  Created by wzq on 14-10-8.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "SSOneFingerControlGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Button/SSControlBtn.h"

//单指移动，旋转，缩放手势控制
@interface SSOneFingerControlGestureRecognizer()
{
    CGPoint _lastTouchPosition;
}
@end

@implementation SSOneFingerControlGestureRecognizer

//*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Fail when more than 1 finger detected.
    if ([[event touchesForGestureRecognizer:self] count] > 1)
    {
        [self setState:UIGestureRecognizerStateFailed];
        return ;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self state] == UIGestureRecognizerStatePossible)
    {
        [self setState:UIGestureRecognizerStateBegan];
    }
    else
    {
        [self setState:UIGestureRecognizerStateChanged];
    }
    // We can look at any touch object since we know we
    // have only 1. If there were more than 1 then
    // touchesBegan:withEvent: would have failed the recognizer.
    UITouch *touch = [touches anyObject];
    UIView *view = ((SSControlBtn *)[self view]).controlView;/*.superview*///获取关联的view
    
    if ([self state] == UIGestureRecognizerStateBegan){
        _lastTouchPosition = [touch locationInView:view];
    }
    else if ([self state] == UIGestureRecognizerStateBegan || [self state] == UIGestureRecognizerStateChanged){
        CGPoint currentTouchPoint = [touch locationInView:view];
        
        // CGPoint previousTouchPoint = [touch previousLocationInView:view];
        CGPoint center = CGPointMake(CGRectGetMidX([view bounds]), CGRectGetMidY([view bounds]));
        
        CGPoint ptCenterOffset = [self CGPointDistance:_lastTouchPosition :center];
        float prevCenterDistance = sqrt(ptCenterOffset.x*ptCenterOffset.x + ptCenterOffset.y*ptCenterOffset.y);

        //计算偏移量
        _ptMoveOffset = [self CGPointDistance:currentTouchPoint :_lastTouchPosition];
        float curMoveDistance = sqrt(_ptMoveOffset.x*_ptMoveOffset.x + _ptMoveOffset.y*_ptMoveOffset.y);
        
        //计算缩放比
        CGFloat scale = (curMoveDistance/prevCenterDistance);
        _ptScale.x = ((_ptMoveOffset.x)/curMoveDistance * scale);
        _ptScale.y = ((_ptMoveOffset.y)/curMoveDistance * scale);
        // self.scale = ((hScale+vScale)/2);

        //计算旋转角度
        _rotateAngle = atan2f(currentTouchPoint.y - center.y, currentTouchPoint.x - center.x) - atan2f(_lastTouchPosition.y - center.y, _lastTouchPosition.x - center.x);
        
        /*
        deltaRotation+=angleInRadians;
        if(abs(deltaRotation)>(2*M_PI))
        {
            double fDeltaRotation = abs(deltaRotation);
            int nNum2PI = (int)((double)fDeltaRotation / (double)(2*M_PI));
            float fValidValue = abs(deltaRotation) - nNum2PI*2*M_PI;
            deltaRotation = deltaRotation>0 ? fValidValue : -fValidValue;
        }
        [self setRotation:angleInRadians];
         //*/
        _lastTouchPosition = currentTouchPoint;
    }
}

-(CGPoint) CGPointDistance:(CGPoint)point1 :(CGPoint)point2
{
    return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

/*
 选自Document
 As it handles touch events, UIKit uses the hitTest:withEvent: and pointInside:withEvent: methods of UIView to determine whether a touch event occurred inside a given view’s bounds. Although you rarely need to override these methods, you could do so to implement custom touch behaviors for your view. For example, you could override these methods to prevent subviews from handling touch events.
 //*/

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Perform final check to make sure a tap was not misinterpreted.
    if ([self state] == UIGestureRecognizerStateChanged)
    {
        [self setState:UIGestureRecognizerStateEnded];
    }
    else
    {
        [self setState:UIGestureRecognizerStateFailed];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setState:UIGestureRecognizerStateFailed];
}
//*/

@end

