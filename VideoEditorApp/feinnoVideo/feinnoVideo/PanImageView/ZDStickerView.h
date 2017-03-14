//
//  ZDStickerView.h
//
//  Created by Seonghyun Kim on 5/29/13.
//  Copyright (c) 2013 scipi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPGripViewBorderView.h"

@protocol ZDStickerViewDelegate;
@protocol labelDelegate;

@interface ZDStickerView : UIView
{
    SPGripViewBorderView *borderView;
}

@property (nonatomic ,retain) UILabel *label;
@property (assign, nonatomic) UIView *contentView;
@property (nonatomic) BOOL preventsPositionOutsideSuperview; //default = YES
@property (nonatomic) BOOL preventsResizing; //default = NO
@property (nonatomic) BOOL preventsDeleting; //default = NO
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;
@property (strong, nonatomic) UIImageView *resizingControl;
@property (strong, nonatomic) UIImageView *deleteControl;
@property (nonatomic) float angleDiff;

@property (nonatomic ,assign) id <labelDelegate> labelDelegate;
@property (strong, nonatomic) id <ZDStickerViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame :(SEL)sel :(id)target;
- (void)hideDelHandle;
- (void)showDelHandle;
- (void)hideEditingHandles;
- (void)showEditingHandles;

@end

@protocol ZDStickerViewDelegate <NSObject>
@required
@optional
- (void)stickerViewDidBeginEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidEndEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidCancelEditing:(ZDStickerView *)sticker;
- (void)stickerViewDidClose:(ZDStickerView *)sticker;
@end

@protocol labelDelegate <NSObject>

@optional
-(void) pinLabel;
-(void) textFieldHidden;

@end
