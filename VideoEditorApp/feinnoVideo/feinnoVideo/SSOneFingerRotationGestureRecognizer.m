//
//  SSOneFingerRotationGestureRecognizer.m
//
//  Created by Kirby Turner on 4/22/11.
//  Copyright 2011 White Peak Software Inc. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
#import "SSOneFingerRotationGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "Button/SSRotateBtn.h"

@implementation SSOneFingerRotationGestureRecognizer

@synthesize rotation = rotation_;
@synthesize deltaRotation;
//*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   // Fail when more than 1 finger detected.
   if ([[event touchesForGestureRecognizer:self] count] > 1)
   {
      [self setState:UIGestureRecognizerStateFailed];
       return ;
    }

    deltaRotation = 0;    
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

   // To rotate with one finger, we simulate a second finger.
   // The second figure is on the opposite side of the virtual
   // circle that represents the rotation gesture.
   UIView *view = ((SSRotateBtn *)[self view]).rotateView;/*.superview*///获取关联的view
   CGPoint center = CGPointMake(CGRectGetMidX([view bounds]), CGRectGetMidY([view bounds]));
   CGPoint currentTouchPoint = [touch locationInView:view];
   CGPoint previousTouchPoint = [touch previousLocationInView:view];
   
    CGFloat angleInRadians = atan2f(currentTouchPoint.y - center.y, currentTouchPoint.x - center.x) - atan2f(previousTouchPoint.y - center.y, previousTouchPoint.x - center.x);
    
    deltaRotation+=angleInRadians;    
    if(abs(deltaRotation)>(2*M_PI))
    {
        double fDeltaRotation = abs(deltaRotation);
        int nNum2PI = (int)((double)fDeltaRotation / (double)(2*M_PI));
        float fValidValue = abs(deltaRotation) - nNum2PI*2*M_PI;
        deltaRotation = deltaRotation>0 ? fValidValue : -fValidValue;
    }
    
    [self setRotation:angleInRadians];
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
