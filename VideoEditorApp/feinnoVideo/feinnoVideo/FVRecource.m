//
//  FVRecource.m
//  libFeinnoVideo
//
//  Created by wzq on 14-9-25.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "FVRecource.h"

@implementation FVResource

@end

/*
 typedef enum _RES_TYPE
 {
 RT_UNKNOWN = 0,
 RT_THEME,
 RT_FILTER,
 RT_BGMUSIC,
 RT_FRAME,
 RT_CARTOON
 }RES_TYPE;
 
 @interface FVResource : NSObject
 {
 RES_TYPE _type_name;
 int _type;
 int _id;
 NSString* _name;
 NSString* _iamge;
 }
 @end
 
 @interface FVFrame : FVResource
 {
 NSString* _bigimage;
 }
 @end
 
 @interface FVCartoon : FVResource
 {
 NSString* _bigimage;
 }
 @end
 //*/
@implementation ResourceManager

+(ResourceManager*) instance;
{
    static dispatch_once_t pred;
    static ResourceManager* instance = nil;
    dispatch_once(&pred, ^{instance = [[self alloc]init];});
    return instance;
}

-(void)parseResConfig
{
//    NSString* resPath = [NSBundle mainBundle]
}

@end