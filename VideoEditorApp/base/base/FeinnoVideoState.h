//
//  FeinnoVideoState.h
//  libFeinnoVideo
//
//  Created by coCo on 14-9-16.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeinnoVideoState : NSObject

//@property (nonatomic ,retain) NSString *nID;
@property (nonatomic) int subTag;
@property (nonatomic) int filterTag;
@property (nonatomic) int bgmusicTag;
@property (nonatomic) int borderTag;
@property (nonatomic) int cartoonTag;
//@property (nonatomic ) NSValue *cartoonRect;
@property (nonatomic ) float cartoonX;
@property (nonatomic ) float cartoonY;
@property (nonatomic ) float cartoonW;
@property (nonatomic ) float cartoonH;
@property (nonatomic ) float cartRotate;
//@property (nonatomic ,retain) NSString *subtitleStartTime;
//@property (nonatomic ,retain) NSString *subtitleStopTime;
//@property (nonatomic ) NSValue *leftThumbRect;
//@property (nonatomic ) NSValue *rightThumbRect;
//@property (nonatomic ) NSValue *sliderBGViewRect;
//@property (nonatomic ) NSValue *popViewRect;
//@property (nonatomic ,retain) NSString *recordStartTime;
//@property (nonatomic ,retain) NSString *recordLength;
//@property (nonatomic ,retain) NSString *titleBubbleTag;
//@property (nonatomic ,retain) NSString *titleFontTag;
//@property (nonatomic ,retain) NSString *titleShade;
//@property (nonatomic ,retain) NSString *titleBold;
//@property (nonatomic ) NSValue *titleColorSliderRect;
//@property (nonatomic ) float titleColorSliderX;
//@property (nonatomic ) float titleColorSliderY;
//@property (nonatomic ) NSValue *titleBubbleRect;
//@property (nonatomic ) float titleBubbleX;
//@property (nonatomic ) float titleBubbleY;
//@property (nonatomic ) float titleBubbleW;
//@property (nonatomic ) float titleBubbleH;
//@property (nonatomic ) NSValue *titleTextRect;
//@property (nonatomic ) float titleTextX;
//@property (nonatomic ) float titleTextY;
//@property (nonatomic ) float titleTextW;
//@property (nonatomic ) float titleTextH;
//@property (nonatomic ,retain) NSString *titleText;
//@property (nonatomic ) float titleRotate;
@property (nonatomic ) int decorateTag;     //装饰页面中一级菜单当前选中的一级菜单的Tag
@property (nonatomic ) int fVideoTag;       //主页 中一级菜单当前选中的一级菜单Tag
//@property (nonatomic ) int bubbleTag;
//@property (nonatomic ) int fontTag;
//@property (nonatomic ) int shade;
//@property (nonatomic ) int bold;
//@property (nonatomic ) Rect sliderRect;
//@property (nonatomic ) Rect titleRect;
//@property (nonatomic ) Rect titleSizeRect;
//@property (nonatomic ,retain) NSString *title;
//@property (nonatomic ) float sliderValue;
//@property (nonatomic ) Rect deleteBtn;
//@property (nonatomic ,retain) NSString *firImagePath;

+(id) getFeinnoVideoInstance;

@end
