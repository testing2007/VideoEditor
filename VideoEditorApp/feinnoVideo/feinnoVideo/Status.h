//
//  Status.h
//  VideoShow
//
//  Created by coCo on 14-8-4.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Status : NSObject

@property (nonatomic ) BOOL selectStatus;           //
@property (nonatomic ) int selectBubbleTag;         //气泡button的Tag
@property (nonatomic ) int selectFontTag;           //字体button的Tag
@property (nonatomic ) BOOL boldfaced;              //字体是否设置为粗体
@property (nonatomic ) BOOL shadow;                 //阴影是否设置

@end
