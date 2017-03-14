//
//  ZDStickerView.m
//
//  Created by Seonghyun Kim on 5/29/13.
//  Copyright (c) 2013 scipi. All rights reserved.
//

#import "PanImageView/ZDStickerView.h"
#import <QuartzCore/QuartzCore.h>

#define kSPUserResizableViewGlobalInset 5.0
#define kSPUserResizableViewDefaultMinWidth 48.0
#define kSPUserResizableViewInteractiveBorderSize 10.0
#define kZDStickerViewControlSize 65.0
#define kZDStickerViewControlRectSize 36.0


@interface ZDStickerView ()

@property (nonatomic) BOOL preventsLayoutWhileResizing;

@property (nonatomic) float deltaAngle;
@property (nonatomic) CGPoint prevPoint;
@property (nonatomic) CGAffineTransform startTransform;

@property (nonatomic) CGPoint touchStart;

@end

@implementation ZDStickerView
@synthesize contentView, touchStart;

@synthesize prevPoint;
@synthesize deltaAngle, startTransform; //rotation
@synthesize resizingControl, deleteControl;
@synthesize preventsPositionOutsideSuperview;
@synthesize preventsResizing;
@synthesize preventsDeleting;
@synthesize minWidth, minHeight;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//-(void)singleTap:(UIPanGestureRecognizer *)recognizer
//{
//    if (NO == self.preventsDeleting) {
//        UIView * close = (UIView *)[recognizer view];
//        [close.superview removeFromSuperview];
//    }
//    
//    if([_delegate respondsToSelector:@selector(stickerViewDidClose:)]) {
//        [_delegate stickerViewDidClose:self];
//    }
//}
-(void) checkKeyBoard:(UIPinchGestureRecognizer *)pinGesture
{
    if ([pinGesture state] == UIGestureRecognizerStateBegan) {
        [_labelDelegate pinLabel];
        [self setNeedsDisplay];
    }
}
-(void)resizeTranslate:(UIPanGestureRecognizer *)recognizer
{
    [self.labelDelegate textFieldHidden];
    if ([recognizer state]== UIGestureRecognizerStateBegan)
    {
        prevPoint = [recognizer locationInView:self];
        NSLog(@"%f,%f",prevPoint.x,prevPoint.y);
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateChanged)
    {
        if (self.bounds.size.width < minWidth || self.bounds.size.width < minHeight)
        {
            self.bounds = CGRectMake(self.bounds.origin.x,
                                     self.bounds.origin.y,
                                     minWidth,
                                     minHeight);
            resizingControl.frame =CGRectMake(self.bounds.origin.x,
                                       self.bounds.origin.y,
                                              kZDStickerViewControlRectSize,
                                              kZDStickerViewControlRectSize);
//            _label.frame = CGRectMake(self.bounds.size.width -kZDStickerViewControlSize, self.bounds.size.height-kZDStickerViewControlSize, kZDStickerViewControlSize, kZDStickerViewControlSize);
            deleteControl.frame = CGRectMake(0, 0,
                                             kZDStickerViewControlSize, kZDStickerViewControlSize);
            prevPoint = [recognizer locationInView:self];
             
        } else {
            CGPoint point = [recognizer locationInView:self];
            float wChange = 0.0, hChange = 0.0;
            
            wChange = (point.x - prevPoint.x);
            hChange = (point.y - prevPoint.y);
            
            if (ABS(wChange) > 20.0f || ABS(hChange) > 20.0f) {
                prevPoint = [recognizer locationInView:self];
                return;
            }
            
            if (YES == self.preventsLayoutWhileResizing) {
                if (wChange < 0.0f && hChange < 0.0f) {
                    float change = MIN(wChange, hChange);
                    wChange = change;
                    hChange = change;
                }
                if (wChange < 0.0f) {
                    hChange = wChange;
                } else if (hChange < 0.0f) {
                    wChange = hChange;
                } else {
                    float change = MAX(wChange, hChange);
                    wChange = change;
                    hChange = change;
                }
            }
            
            self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y,
                                     self.bounds.size.width + (wChange),
                                     self.bounds.size.height + (hChange));
            _label.frame = CGRectMake(_label.frame.origin.x, _label.frame.origin.y, _label.frame.size.width +(wChange), _label.frame.size.height +(hChange));
            resizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                              self.bounds.size.height-kZDStickerViewControlSize,
                                              kZDStickerViewControlRectSize, kZDStickerViewControlRectSize);
            deleteControl.frame = CGRectMake(0, 0,
                                             kZDStickerViewControlSize, kZDStickerViewControlSize);
            prevPoint = [recognizer locationInView:self];
        }
        
        /* Rotation */
        float ang = atan2([recognizer locationInView:self.superview].y - self.center.y,
                          [recognizer locationInView:self.superview].x - self.center.x);
        self.angleDiff = deltaAngle - ang;
        NSLog(@"angleDiff:%f",self.angleDiff);
        if (NO == preventsResizing) {
            self.transform = CGAffineTransformMakeRotation(-self.angleDiff);
        }
        borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
        [borderView setNeedsDisplay];
        
        [self setNeedsDisplay];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        prevPoint = [recognizer locationInView:self];
        [self setNeedsDisplay];
    }
//    NSLog(@"x:%f,y:%f,width:%f,height:%f",resizingControl.frame.origin.x,resizingControl.frame.origin.y,resizingControl.frame.size.width,resizingControl.frame.size.height);
}

- (void)setupDefaultAttributes {
    borderView = [[SPGripViewBorderView alloc] initWithFrame:CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset)];
    [borderView setHidden:YES];
    [self addSubview:borderView];
    
    if (kSPUserResizableViewDefaultMinWidth > self.bounds.size.width*0.5) {
        self.minWidth = kSPUserResizableViewDefaultMinWidth;
        self.minHeight = self.bounds.size.height * (kSPUserResizableViewDefaultMinWidth/self.bounds.size.width);
    } else {
        self.minWidth = self.bounds.size.width*0.5;
        self.minHeight = self.bounds.size.height*0.5;
    }
    self.preventsPositionOutsideSuperview = YES;
    self.preventsLayoutWhileResizing = YES;
    self.preventsResizing = NO;
    self.preventsDeleting = NO;
    
//    deleteControl = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,
//                                                                 kZDStickerViewControlSize, kZDStickerViewControlSize)];
//    deleteControl.backgroundColor = [UIColor clearColor];
//    deleteControl.image = [UIImage imageNamed:@"ZDBtn3.png" ];
//    deleteControl.userInteractionEnabled = YES;
//    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc]
//                                          initWithTarget:self
//                                          action:@selector(singleTap:)];
//    [deleteControl addGestureRecognizer:singleTap];
//    [self addSubview:deleteControl];
    
    resizingControl = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width -kZDStickerViewControlSize,
                                                                   self.frame.size.height-kZDStickerViewControlSize,
                                                                   kZDStickerViewControlRectSize, kZDStickerViewControlRectSize)];
     //NSLog(@"1111111x:%f,y:%f,width:%f,height:%f",resizingControl.frame.origin.x,resizingControl.frame.origin.y,resizingControl.frame.size.width,resizingControl.frame.size.height);
    resizingControl.backgroundColor = [UIColor clearColor];
    resizingControl.userInteractionEnabled = YES;
    resizingControl.image = [UIImage imageNamed:@"旋转_normal.png" ];
    UIPanGestureRecognizer* panResizeGesture = [[UIPanGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(resizeTranslate:)];
    [resizingControl addGestureRecognizer:panResizeGesture];
    NSLog(@"%f,%f,%f,%f",self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
    _label = [[UILabel alloc] initWithFrame:CGRectMake(30 , 30, 100, kZDStickerViewControlSize)];
    _label.backgroundColor = [UIColor clearColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.userInteractionEnabled = YES;
//    _label.numberOfLines = 0;
//    CGSize reSize = CGSizeMake(150, 60);
//    NSDictionary *reDic = [NSDictionary dictionaryWithObjectsAndKeys:_label.font,NSFontAttributeName, nil];
//    CGSize reStrSize = [_label.text boundingRectWithSize:reSize options:NSStringDrawingUsesLineFragmentOrigin attributes:reDic context:nil].size;
//    _label.frame = CGRectMake(_label.frame.size.width, _label.frame.size.height, reStrSize.width, reStrSize.height);
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkKeyBoard:)];
//    [_label addGestureRecognizer:tapGesture];
    [self addSubview:_label];
    
    [self addSubview:resizingControl];
    deltaAngle = atan2(self.frame.origin.y+self.frame.size.height - self.center.y,
                       self.frame.origin.x+self.frame.size.width - self.center.x);
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return  YES;
}


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupDefaultAttributes];
    }
    return self;
}

- (void)setContentView:(UIView *)newContentView {
    [contentView removeFromSuperview];
    contentView = newContentView;
    contentView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:contentView];
    
    [self bringSubviewToFront:_label];
    [self bringSubviewToFront:borderView];
    [self bringSubviewToFront:resizingControl];
    [self bringSubviewToFront:deleteControl];
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
    contentView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2, kSPUserResizableViewGlobalInset + kSPUserResizableViewInteractiveBorderSize/2);
    
    borderView.frame = CGRectInset(self.bounds, kSPUserResizableViewGlobalInset, kSPUserResizableViewGlobalInset);
    resizingControl.frame =CGRectMake(self.bounds.size.width-kZDStickerViewControlSize,
                                      self.bounds.size.height-kZDStickerViewControlSize,
                                      kZDStickerViewControlRectSize,
                                      kZDStickerViewControlRectSize);
    _label.frame = CGRectMake(30 , 30, 100, kZDStickerViewControlSize);
    deleteControl.frame = CGRectMake(0, 0,
                                     kZDStickerViewControlSize, kZDStickerViewControlSize);
    [borderView setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    touchStart = [touch locationInView:self.superview];
////    NSLog(@"touchStart,x:%f,y:%f",touchStart.x,touchStart.y);
////    NSLog(@"self,x:%f,y:%f",self.frame.origin.x,self.frame.origin.y);
////    NSLog(@"label,x1:%f,x2:%f,y1:%f,y2:%f",_label.frame.origin.x,_label.frame.size.width,_label.frame.origin.y,_label.frame.size.height);
    NSLog(@"x1:%f",touchStart.x -_label.frame.origin.x -self.frame.origin.x);
    NSLog(@"x2:%f",touchStart.x -_label.frame.origin.x -self.frame.origin.x -_label.frame.size.width);
    NSLog(@"y1:%f",touchStart.y -_label.frame.origin.y -self.frame.origin.y);
    NSLog(@"y2:%f",touchStart.y -_label.frame.origin.y -self.frame.origin.y  -_label.frame.size.height);
    if (touchStart.x -_label.frame.origin.x -self.frame.origin.x >=0 && touchStart.x -_label.frame.origin.x -self.frame.origin.x -_label.frame.size.width <=0 && touchStart.y -_label.frame.origin.y -self.frame.origin.y >=0 && touchStart.y -_label.frame.origin.y -self.frame.origin.y  -_label.frame.size.height <=0)
    {
        [_labelDelegate pinLabel];
    }
 if([_delegate respondsToSelector:@selector(stickerViewDidBeginEditing:)]) {
        [_delegate stickerViewDidBeginEditing:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(stickerViewDidEndEditing:)]) {
        [_delegate stickerViewDidEndEditing:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.
    if([_delegate respondsToSelector:@selector(stickerViewDidCancelEditing:)]) {
        [_delegate stickerViewDidCancelEditing:self];
    }
}

- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x,
                                    self.center.y + touchPoint.y - touchStart.y);
    if (self.preventsPositionOutsideSuperview) {
        // Ensure the translation won't cause the view to move offscreen.
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX) {
            newCenter.x = self.superview.bounds.size.width - midPointX;
        }
        if (newCenter.x < midPointX) {
            newCenter.x = midPointX;
        }
        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY) {
            newCenter.y = self.superview.bounds.size.height - midPointY;
        }
        if (newCenter.y < midPointY) {
            newCenter.y = midPointY;
        }
    }
    self.center = newCenter;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.labelDelegate textFieldHidden];
    CGPoint touch = [[touches anyObject] locationInView:self.superview];
    [self translateUsingTouchLocation:touch];
    touchStart = touch;
    
     NSLog(@"x:%f,y:%f,width:%f,height:%f",self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
}

- (void)hideDelHandle
{
    deleteControl.hidden = NO;
}

- (void)showDelHandle
{
    deleteControl.hidden = NO;
}

- (void)hideEditingHandles
{
    resizingControl.hidden = YES;
    deleteControl.hidden = YES;
    [borderView setHidden:YES];
}

- (void)showEditingHandles
{
    resizingControl.hidden = NO;
    deleteControl.hidden = NO;
    [borderView setHidden:NO];
}

@end
