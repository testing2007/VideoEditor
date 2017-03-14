//
//  TextStatus.h
//  FVideo
//
//  Created by coCo on 14-8-14.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextStatus : NSObject

@property (nonatomic ) BOOL selectStatus;           //
@property (nonatomic ) int selectBubbleTag;         //气泡button的Tag
@property (nonatomic ) int selectFontTag;           //字体button的Tag
@property (nonatomic ) int boldfaced;              //字体是否设置为粗体
@property (nonatomic ) int shadow;                 //阴影是否设置
@property (nonatomic ) float sliderX;
@property (nonatomic ) float lastColorwidth;
//@property (nonatomic ) NSValue *bubbleRect;
@property (nonatomic ) float bubbleX;
@property (nonatomic ) float bubbleY;
@property (nonatomic ) float bubbleW;
@property (nonatomic ) float bubbleH;
//@property (nonatomic ) NSValue *textRect;
@property (nonatomic ) float textX;
@property (nonatomic ) float textY;
@property (nonatomic ) float textW;
@property (nonatomic ) float textH;
@property (nonatomic ,retain) NSString *titleText;
@property (nonatomic ) float rotate;
@end
