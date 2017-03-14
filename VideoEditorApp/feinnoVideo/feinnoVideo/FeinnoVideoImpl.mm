//
//  FeinnoVideoImpl.m
//  libFeinnoVideo
//
//  Created by wzq on 14-9-25.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "FeinnoVideoImpl.h"

//
//  FeinnoVideoImpl.m
//  libFeinnoVideo
//
//  Created by wzq on 14-9-25.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "FVideoViewController.h"

@implementation FeinnoVideoImpl

-(id) init
{
    self = [super init];
    if(self)
    {
        
    }
    return self;
}
/*
 @delegate: 回调对象
 @mediaPath: 原编辑视频
 @savepath: 编辑后保存路径
 @prevEditInfo: 上次编辑的xml数据结构信息字符串
 //*/
-(FVideoViewController*)initialize:(id)delegate withMediaPath:(NSString *)mediaPath withSavePath:(NSString*)savePath withPrevEditInfo:(NSString*)prevEditInfo
{
    FVideoViewController* fv = [[FVideoViewController alloc] init];
    [fv initialize:delegate withMediaPath:mediaPath withSavePath:savePath withPrevEditInfo:prevEditInfo];
    return fv;
}

@end
