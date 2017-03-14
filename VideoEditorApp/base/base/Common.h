//
//  Common.h
//  libFeinnoVideo
//
//  Created by wzq on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "typedef.h"
#import "FeinnoVideoState.h"

typedef enum _VC_ID
{
    VC_UNKNOWN=0,
    VC_MAIN,
    VC_SUBTITLE,
    VC_ADD_SUBTITLE,
    VC_DECORATE,
    VC_RECORD,
    VC_EDIT_RECORD
}VC_ID;

//warning frame 不同状态对应的颜色标识
typedef enum _WARNING_FRAME_STATE_COLOR
{
    WARNING_FRAME_NORMAL_COLOR_BLUE, //当素材在警告框内时，颜色为蓝色
    WARNING_FRAME_UNNORMAL_COLOR_RED,//当素材在警告框外时，颜色为红色
    WARNING_FRAME_OUT_CLEAR_COLOR    //当鼠标移出舞台，清除原来的边框绘制
}WARNING_FRAME_STATE_COLOR;


@interface Common : NSObject

//获取文档目录
+(NSString*) getDocumentDirectory;
//获取解压合成资源目录
+(NSString*) getUnzipSynElementDirectory;
//获取合成资源目录
+(NSString*) getSynElementFolderPath:(SYN_ELEMENT)synEle withEleID:(int)synEleID;
//解压指定文件到指定目录
+(BOOL) unzip:(NSString*)dstPath :(NSString*)srcPath;
//获取视频第一帧图像
+(UIImage *)firstVideoFrameImage:(NSString*)videoPath;
//获取装饰截图
+(NSString *) getDecorateImagePath;
//字幕截图储存路径
+(NSString *) getSubtitleImagePath;
//录音储存路径
+(NSString *) getRecorderMusicDirectory;
//添加字幕开始时间
//+(float) getTitleStartTimeInMillSec;
//添加字幕结束时间
//+(float) getTitleStopTimeInMillSec;
//录音开始时间
//+(float) getRecordStartTimeInMillSec;
//录音时长
//+(float) getRecordLengthInMillSec;
//获取更改大小后的图片(320*320)
+(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size;
+(NSString*)getRecordSavePath;
//获取所有状态的字典
+ (NSDictionary *)getEditPropertiesInfo;
//获取指定文件目录，指定扩展名文件列表
+(NSArray*) getFileInfoUnderDirByFileExtensionName:(NSString*)dirPath withExtensionName:(NSString*)extensionName;
//获取指定文件目录，指定扩展名的背景音乐
+(NSString*) getBgMusicFilePath:(NSString*)dirPath withExtensionName:(NSString*)extensionName;
//
+(FeinnoVideoState *) getEditDataInfo :(NSDictionary *)videoStateDictionary;
//将view转变成指定大小图片
+(UIImage*)convertViewToImageBySize:(UIView*)targetView withFitSize:(CGSize)fitSize;
//将png图片写入到指定的路径
+(void) writeImageIntoPath:(UIImage*)pngImage withTargetPath:(NSString*)path;
// 获取屏幕尺寸高度
+(BOOL) getDeviceSize;
// 创建视频保存临时文件路径
+(NSString *) createSysVideoPath :(NSString *)videoName;
// 获取保存临时文件路径
+(NSString *) getSysVideoPath :(NSString *)videoName;
// 动画效果
+(void)MoveView:(UIView *)view To:(CGRect)frame During:(float)time;

@end
