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
//@synthesize rotation = rotation_;
//@synthesize deltaRotation;

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
//    CGPoint center = CGPointMake(CGRectGetMidX([view bounds]), CGRectGetMidY([view bounds]));
//    CGPoint currentTouchPoint = [touch locationInView:view];
//    CGPoint previousTouchPoint = [touch previousLocationInView:view];
//    
//    CGFloat angleInRadians = atan2f(currentTouchPoint.y - center.y, currentTouchPoint.x - center.x) - atan2f(previousTouchPoint.y - center.y, previousTouchPoint.x - center.x);
//    
//    deltaRotation+=angleInRadians;
//    if(abs(deltaRotation)>(2*M_PI))
//    {
//        double fDeltaRotation = abs(deltaRotation);
//        int nNum2PI = (int)((double)fDeltaRotation / (double)(2*M_PI));
//        float fValidValue = abs(deltaRotation) - nNum2PI*2*M_PI;
//        deltaRotation = deltaRotation>0 ? fValidValue : -fValidValue;
//    }

//    if ([self state] == UIGestureRecognizerStateBegan){
//        _lastTouchPosition = [touch locationInView:view];
//    }
//    else if ([self state] == UIGestureRecognizerStateBegan || [self state] == UIGestureRecognizerStateChanged){
    if([self state] == UIGestureRecognizerStateBegan)
    {
        NSLog(@"touchesMoved the transform is (a=%f, b=%f, c=%f, d=%f, tx=%f, ty=%f)", view.transform.a, view
              .transform.b, view.transform.c, view.transform.d, view.transform.tx, view.transform.ty);
    }
        CGPoint currentTouchPoint = [touch locationInView:view];
        CGPoint previousTouchPoint = [touch previousLocationInView:view];
    NSLog(@"cur x=%f, y=%f, prev x=%f, y=%f", currentTouchPoint.x, currentTouchPoint.y, previousTouchPoint.x, previousTouchPoint.y);
        CGPoint center = CGPointMake(CGRectGetMidX([view bounds]), CGRectGetMidY([view bounds]));
        _rotation = atan2f(currentTouchPoint.y - center.y, currentTouchPoint.x - center.x) - atan2f(previousTouchPoint.y - center.y, previousTouchPoint.x - center.x);
        NSLog(@"rotation angle = %f", _rotation);
    NSLog(@"view frame:(orig(x=%f, y=%f), size(w=%f, h=%f)", view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        [view setTransform:CGAffineTransformRotate([view transform], _rotation)];
    NSLog(@"view frame:(orig(x=%f, y=%f), size(w=%f, h=%f)", view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
        // [view setTransform:CGAffineTransformScale(view.transform, 1, 1)];

//    _ptScale = CGPointDistance(currentTouchPoint, previousTouchPoint);
//    NSLog(@"the ptScale=(x=%f, y=%f", _ptScale.x, _ptScale.y);
//    [view setFrame:CGRectMake(view.bounds.origin.x-_ptScale.x, view.bounds.origin.y-_ptScale.y, view.bounds.size.width+2*_ptScale.x, view.bounds.size.height+2*_ptScale.y)];
    /*
    CGPoint deltaMove = CGPointDistance(currentTouchPoint, previousTouchPoint);
    float distance = sqrt(deltaMove.x*deltaMove.x + deltaMove.y*deltaMove.y);
    
    CGPoint deltaMove2 = CGPointDistance(previousTouchPoint, center);
    float distance2 = sqrt(deltaMove2.x*deltaMove2.x + deltaMove2.y*deltaMove2.y);
    
    CGFloat scale = (distance/distance2);
    _ptScale.x = ((deltaMove.x)/distance * scale);
    _ptScale.y = ((deltaMove.y)/distance * scale);
    NSLog(@"cur:(x=%f, y=%f), prev:(x=%f, y=%f),  scale:(x=%f, y=%f), center:(x=%f, y=%f), Cur->Prev:dif:(x=%f, y=%f), Prev->Center:dif:(x=%f, y=%f)",
          currentTouchPoint.x,
          currentTouchPoint.y,
          previousTouchPoint.x,
          previousTouchPoint.y,
          _ptScale.x,
          _ptScale.y,
          center.x,
          center.y,
          deltaMove.x,
          deltaMove.y,
          deltaMove2.x,
          deltaMove2.y
          );
    NSLog(@"exp(cur=prev*scale, x:%f=%f*(1+%f), y:%f=%f*(1+%f)", currentTouchPoint.x, previousTouchPoint.x, _ptScale.x, currentTouchPoint.y, previousTouchPoint.y, _ptScale.y);
    //*
        CGPoint newRotatePoint;
        newRotatePoint.x = previousTouchPoint.x*cosf(_rotation)-previousTouchPoint.y*sinf(_rotation);
        newRotatePoint.y = previousTouchPoint.x*sinf(_rotation)+previousTouchPoint.y*cosf(_rotation);
        
        CGPoint deltaMove = CGPointDistance(currentTouchPoint, previousTouchPoint);
        float distance = sqrt(deltaMove.x*deltaMove.x + deltaMove.y*deltaMove.y);
        
        CGPoint deltaMove2 = CGPointDistance(previousTouchPoint, center);
        float distance2 = sqrt(deltaMove2.x*deltaMove2.x + deltaMove2.y*deltaMove2.y);
        
        CGFloat scale = (distance/distance2);
        _ptScale.x = ((deltaMove.x)/distance * scale);
        _ptScale.y = ((deltaMove.y)/distance * scale);
     //*/
    
    // [view setTransform:CGAffineTransformScale(view.transform, 1+_ptScale.x, 1+_ptScale.y)];
    //*/
        // self.scale = ((hScale+vScale)/2);

//        _lastTouchPosition = currentTouchPoint;
//    }
    // [self setRotation:angleInRadians];
}

CGPoint CGPointDistance(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x - point2.x, point1.y - point2.y);
};

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
