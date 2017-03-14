//
//  FVRecource.h
//  libFeinnoVideo
//
//  Created by wzq on 14-9-25.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import <Foundation/Foundation.h>
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

/*
 <?xml version="1.0"?>
 <root_node>
    <theme_node>
     <filter_node>
     <bgmusic_node>
     <frame>
        <item type=4 id=0 name="无边框" image="icon.png" bigImage="frame.png"></item>
  <cartoon>
 </root_node>
 //*/
@interface ResourceManager : NSObject
{
    //key=type, value=NSArray, NSArray每个纪录对应一个资源信息描述，每个资源信息用 FVResource* 表示
    NSDictionary* dicResMap;
}

+(ResourceManager*) instance;

@end
