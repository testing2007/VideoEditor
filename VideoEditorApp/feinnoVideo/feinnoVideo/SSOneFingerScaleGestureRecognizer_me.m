//
//  SSOneFingerScaleGestureRecognizer.m
//  libFeinnoVideo
//
//  Created by wzq on 14-9-29.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "SSOneFingerScaleGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Button/SSScaleBtn.h"

@interface SSOneFingerScaleGestureRecognizer()
{
    CGPoint _lastTouchPosition;
}
@end

@implementation SSOneFingerScaleGestureRecognizer

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
    UIView *view = ((SSScaleBtn *)[self view]).scaleView;/*.superview*///获取关联的view
    
    if ([self state] == UIGestureRecognizerStateBegan){
        _lastTouchPosition = [touch locationInView:view];
    }
    else if ([self state] == UIGestureRecognizerStateBegan || [self state] == UIGestureRecognizerStateChanged){
        CGPoint currentTouchPoint = [touch locationInView:view];
        
        // CGPoint previousTouchPoint = [touch previousLocationInView:view];
        CGPoint center = CGPointMake(CGRectGetMidX([view bounds]), CGRectGetMidY([view bounds]));
        CGPoint deltaMove = [self CGPointDistance:currentTouchPoint :_lastTouchPosition];
        float distance = sqrt(deltaMove.x*deltaMove.x + deltaMove.y*deltaMove.y);
        
        CGPoint deltaMove2 = [self CGPointDistance:_lastTouchPosition :center];
        float distance2 = sqrt(deltaMove2.x*deltaMove2.x + deltaMove2.y*deltaMove2.y);
        
        CGFloat scale = (distance/distance2);
        CGFloat hScale = ((deltaMove.x)/distance * scale);
        CGFloat vScale = ((deltaMove.y)/distance * scale);
//        self.scale = ((hScale+vScale)/2);

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
