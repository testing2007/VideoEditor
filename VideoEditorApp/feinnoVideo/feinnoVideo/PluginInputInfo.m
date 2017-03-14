//
//  PluginInterfaceInfo.m
//  libFeinnoVideo
//
//  Created by wzq on 14-9-14.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "PluginInterfaceInfo.h"
#import "base/Common.h"

@interface PluginInterfaceInfo()
{
    // NSMutableDictionary* _curEditInfo;
}
@property(nonatomic, weak, readwrite) id<IFeinnoVideoCallback> delegate;
@property(nonatomic, retain, readwrite) NSString* srcVideoPath;
@property(nonatomic, retain, readwrite) NSString* savePath;
@property(nonatomic, retain, readwrite) NSString* prevEditInfo;

// @property(nonatomic, retain, readwrite) NSMutableDictionary* curEditInfo;

@end

@implementation PluginInterfaceInfo

+(PluginInterfaceInfo*) instance
{
    static dispatch_once_t pred;
    static PluginInterfaceInfo* instance = nil;
    dispatch_once(&pred, ^{instance = [[self alloc]init];});
    return instance;
}

-(void)input:(id)delegate withMediaPath:(NSString *)mediaPath withSavePath:(NSString*)savePath withPrevEditInfo:(NSString*)prevEditInfo
{
    self.delegate = delegate;
    self.srcVideoPath = mediaPath;
    self.savePath = savePath;
    self.prevEditInfo = prevEditInfo;
    
//    self.curEditInfo = [self.prevEditInfo copy];
}

-(void) output
{
    if(_delegate!=nil)
    {
        //TODO
        
        [_delegate finishEdit:self.savePath withEditParameter:(NSString*)[Common getEditPropertiesInfo]];
        //[_delegate finishEdit:self.savePath withEditParameter:[Common getEditPropertiesInfo]];
    }
}

/*
-(void) updateEditInfo:(NSString*)key withValue:(NSString*)value
{
    assert(NSOrderedSame==[key compare:@"synEleType" options:NSCaseInsensitiveSearch] ||
         NSOrderedSame==[key compare:@"synEleID" options:NSCaseInsensitiveSearch]);
    
    [self.curEditInfo setValue:value forKey:key];
}
//*/

@end
