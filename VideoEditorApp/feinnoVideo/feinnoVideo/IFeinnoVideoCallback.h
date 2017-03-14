//
//  IFeinnoVideo.h
//  libFeinnoVideo
//
//  Created by wzq on 14-9-2.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IFeinnoVideoCallback <NSObject>

-(void) finishEdit:(NSString*)savePath withEditParameter:(NSString*)editParameter;

@end
