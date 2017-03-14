//
//  PluginInterfaceInfo.h
//  libFeinnoVideo
//
//  Created by wzq on 14-9-14.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFeinnoVideoCallback.h"

@interface PluginInterfaceInfo : NSObject
{
    __weak id<IFeinnoVideoCallback> _delegate;
    NSString* _srcVideoPath;
    NSString* _savePath;
    NSString* _prevEditInfo;
}

@property(nonatomic, weak, readonly) id<IFeinnoVideoCallback> delegate;
@property(nonatomic, retain, readonly) NSString* srcVideoPath;
@property(nonatomic, retain, readonly) NSString* savePath;
@property(nonatomic, retain, readonly) NSString* prevEditInfo;

+(PluginInterfaceInfo*)instance;
-(void)input:(id)delegate withMediaPath:(NSString *)mediaPath withSavePath:(NSString*)savePath withPrevEditInfo:(NSString*)prevEditInfo;
-(void) output;
// -(void) updateEditInfo:(NSString*)key withValue:(NSString*)value;

@end
