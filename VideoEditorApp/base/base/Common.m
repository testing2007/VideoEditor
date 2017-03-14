//
//  Common.m
//  libFeinnoVideo
//
//  Created by wzq on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "Common.h"
#import "ZipArchive/ZipArchive.h"
#import "CatchImage.h"
#import "FeinnoVideoState.h"
#import <objc/runtime.h>


@implementation Common

//获取documents目录
+(NSString*) getDocumentDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
}

+(NSString*) getUnzipSynElementDirectory
{
    //return [NSString stringWithFormat:@"%@/assets", [Common getDocumentDirectory]];
    return [NSString stringWithFormat:@"%@/assets", [Common getDocumentDirectory]];
}

+(NSString *) getDecorateImagePath
{
    return [NSString stringWithFormat:@"%@/saveFore.png",[Common getDocumentDirectory]];
}

+(NSString *) getSubtitleImagePath
{
    return [NSString stringWithFormat:@"%@/saveTitle.png",[Common getDocumentDirectory]];
}
//录音储存路径
+(NSString *) getRecorderMusicDirectory
{
    return [NSString stringWithFormat:@"%@/record.wav",[Common getDocumentDirectory]];
}

+(NSString*)  getSynElementFolderPath:(SYN_ELEMENT)synEle withEleID:(int)synEleID
{
    NSString* synEleName = @"";
    switch (synEle)
    {
        case SYN_FILTER:
            synEleName = @"filter";
            break;
        case SYN_THEME:
            synEleName = @"theme";
            break;
        case SYN_BGMUSIC:
            synEleName = @"bgmusic";
            break;
        case SYN_CARTOON:
            synEleName = @"cartoon";
            break;
        case SYN_FRAME:
            synEleName = @"frame";
            break;
        default:
            assert(false);
    }    
    return [NSString stringWithFormat:@"%@/assets/%@/%d", [Common getDocumentDirectory], synEleName, synEleID];
}

+(BOOL) unzip:(NSString*)dstPath :(NSString*)srcPath
{
    //实现解压操作
    //assert(srcPath!=nil && dstPath!=nil);
    ZipArchive* zip = [[ZipArchive alloc] init];
    if( [zip UnzipOpenFile:srcPath] )
    {
        BOOL ret = [zip UnzipFileTo:dstPath overWrite:YES];
        if( NO==ret )
        {
            return NO;
        }
        [zip UnzipCloseFile];
    }
    else
    {
        NSLog(@"ERROR unzip-->UnzipOpenFile can't success to unzip the file=%@", srcPath);
        return NO;
    }
    return YES;
}
//添加字幕开始时间
//+(float) getTitleStartTimeInMillSec
//{
//    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
//    float start = [state.subtitleStartTime floatValue] *1000;
//    return start;
//}
//添加字幕结束时间
//+(float) getTitleStopTimeInMillSec
//{
//    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
//    float stop = [state.subtitleStopTime floatValue] *1000;
//    return stop;
//}
/*
//录音开始时间
+(float) getRecordStartTimeInMillSec
{
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    float start = [state.recordStartTime floatValue] *1000;
    return start;
}
//录音时长
+(float) getRecordLengthInMillSec
{
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    float length = [state.recordLength floatValue] *1000;
    return length;
}*/
//获取视频的某一一帧图片
+(UIImage *)firstVideoFrameImage:(NSString*)videoPath
{
    NSURL* url = [NSURL fileURLWithPath:videoPath];
    return [CatchImage thumbnailImageForVideo:url atTime:1];
}
//改变图片的大小(320*320)
+(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}
+(NSString*)getRecordSavePath
{
    return [[self getDocumentDirectory] stringByAppendingString:@"/record.wav"];
}
+ (NSDictionary *)getEditPropertiesInfo
{
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([state class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f = property_getName(property);
        NSLog(@"%s",char_f);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        //NSLog(@"%@",propertyName);
        id propertyValue = [state valueForKey:(NSString *)propertyName];
        //NSLog(@"%@",propertyValue);
        if (propertyValue == nil){
            [props setObject:@"" forKey:propertyName];
        }else{
            [props setObject:propertyValue forKey:propertyName];
        }
    }
    return props;
}
//初始化前调用上次编辑的内容
+(FeinnoVideoState *) getEditDataInfo :(NSDictionary *)videoStateDictionary
{
    //    NSArray *arr = [NSArray arrayWithObjects:@"subTag",@"filterTag",@"bgMusicTag",@"borderTag",@"cartoonTag",@"cartoonX",@"cartoonY",@"cartoonW",@"cartoonH",@"cartRotate",@"subtitleStartTime",@"subtitleStopTime",@"titleBubbleTag",@"titleFontTag",@"titleShade",@"titleBold",@"titleColorSliderX",@"titleColorSliderY",@"titleBubbleX",@"titleBubbleY",@"titleBubbleW",@"titleBubbleH",@"titleTextX",@"titleTextY",@"titleTextW",@"titleTextH",@"titleText",@"titleRotate", nil];
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    state.subTag = [videoStateDictionary objectForKey:@"subTag"];
    state.filterTag = [videoStateDictionary objectForKey:@"filterTag"];
    state.bgmusicTag = [videoStateDictionary objectForKey:@"bgMusicTag"];
    state.borderTag = [videoStateDictionary objectForKey:@"borderTag"];
    state.cartoonTag = [videoStateDictionary objectForKey:@"cartoonTag"];
    state.cartoonX = [[videoStateDictionary objectForKey:@"cartoonX"] floatValue];
    state.cartoonY = [[videoStateDictionary objectForKey:@"cartoonY"] floatValue];
    state.cartoonW = [[videoStateDictionary objectForKey:@"cartoonW"] floatValue];
    state.cartoonH = [[videoStateDictionary objectForKey:@"cartoonH"] floatValue];
    state.cartRotate = [[videoStateDictionary  objectForKey:@"cartRotate"] floatValue];
    state.decorateTag = [videoStateDictionary objectForKey:@"decorateTag"];
    state.fVideoTag = [videoStateDictionary objectForKey:@"fVideoTag"];
    //    state.subtitleStartTime = [videoStateDictionary objectForKey:@"subtitleStartTime"];
    //    state.subtitleStopTime = [videoStateDictionary objectForKey:@"subtitleStopTime"];
    //    state.titleBubbleTag = [videoStateDictionary objectForKey:@"titleBubbleTag"];
    //    state.titleFontTag = [videoStateDictionary objectForKey:@"titleFontTag"];
    //    state.titleShade = [videoStateDictionary objectForKey:@"titleShade"];
    //    state.titleTextX = [[videoStateDictionary objectForKey:@"titleTextX"] floatValue];
    //    state.titleTextY = [[videoStateDictionary objectForKey:@"titleTextY"] floatValue];
    //    state.titleTextW = [[videoStateDictionary objectForKey:@"titleTextW"] floatValue];
    //    state.titleTextH = [[videoStateDictionary objectForKey:@"titleTextH"] floatValue];
    //    state.titleText = [videoStateDictionary objectForKey:@"titleText"];
    //    state.titleRotate = [[videoStateDictionary objectForKey:@"titleRotate"] floatValue];
    NSString *newString;
    NSDictionary *dic = videoStateDictionary;
    NSArray *allkey = [dic allKeys];
    NSLog(@"%@",allkey);
    for (int i = 0; i <allkey.count; i++) {
        NSString *curString;
        curString = [NSString stringWithFormat:@"%@,",[dic objectForKey:[allkey objectAtIndex:i]]];
        newString = [newString stringByAppendingString:curString];
    }
    return state;
}
+(NSString*) getBgMusicFilePath:(NSString*)dirPath withExtensionName:(NSString*)extensionName
{
    NSString* fileName = nil;
    NSArray* fileArray = [Common getFileInfoUnderDirByFileExtensionName:dirPath withExtensionName:@"mp3"];
    if(1==[fileArray count])
    {
        fileName = [[NSString alloc]initWithString:[[[fileArray lastObject]stringByDeletingPathExtension] lastPathComponent]];
    }
    else
    {
        fileName = @"";
    }
    return fileName;
}

+(NSArray*) getFileInfoUnderDirByFileExtensionName:(NSString*)dirPath withExtensionName:(NSString*)extensionName
{
    NSMutableArray* fileArray = [[NSMutableArray alloc]init];
    //dirPath = @"/var/mobile/Applications/B39A4663-0478-4AB6-AE37-D4A1F9FA7652/Documents/assets/bgMusic/4/";
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:dirPath];
    
    NSString *file;
    while (file = [dirEnum nextObject]) {
        if ([[file pathExtension] isEqualToString: extensionName]) {
            [fileArray addObject:file];
        }
    }
    return fileArray;
}

+(UIImage*)convertViewToImageBySize:(UIView*)targetView withFitSize:(CGSize)fitSize
{
    UIGraphicsBeginImageContextWithOptions(targetView.frame.size, NO,[UIScreen mainScreen].scale);
    [targetView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *actureImage = UIGraphicsGetImageFromCurrentImageContext();
    // [actureImage drawInRect:CGRectMake(0, 0, fitSize.width, fitSize.height)];
    //UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage* scaledImage = [Common OriginImage:actureImage scaleToSize:fitSize];
    return scaledImage;
}

+(void) writeImageIntoPath:(UIImage*)pngImage withTargetPath:(NSString*)path
{
    NSData *imageData = UIImagePNGRepresentation(pngImage);
    [imageData writeToFile:path atomically:YES];
}
// 获取屏幕尺寸高度
+(BOOL) getDeviceSize;
{
    CGRect rect = [UIScreen mainScreen].bounds;
    float hight = rect.size.height;
    if (hight >480) {
        return YES;
    }else{
        return NO;
    }
}
// 动画效果
+(void)MoveView:(UIView *)view To:(CGRect)frame During:(float)time
{
    [UIView beginAnimations:nil context:nil];
    // 动画时间曲线 EaseInOut效果
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    // 动画时间
    [UIView setAnimationDuration:time];
    view.frame = frame;
    // 动画结束（或者用提交也不错）
    [UIView commitAnimations];
}
// 视频保存临时文件路径
+(NSString *) createSysVideoPath :(NSString *)videoName
{
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:videoName];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *result = [path stringByAppendingPathComponent:videoName];
    return result;
}
// 获取保存临时文件路径
+(NSString *) getSysVideoPath :(NSString *)videoName
{
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@.mp4",[Common getDocumentDirectory],videoName,videoName];
    NSLog(@"%@",path);
    return path;
}
@end
