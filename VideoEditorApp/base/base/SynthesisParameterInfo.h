//
//  SynthesisParameterInfo.h
//  libFeinnoVideo
//
//  Created by wzq on 14-9-16.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef __libFeinnoVideo__SynthesisParameterInfo__
#define __libFeinnoVideo__SynthesisParameterInfo__

// #include <interface/synthesis/UISynthesisCallback.h>
#include <iostream>
//#include <string>
#include <base/ObjcClass.h>
OBJC_CLASS(GPUImageView);

typedef enum _SYN_MESSAGE_ID
{
    SYN_MSG_UNKNOWN=0,
    SYN_MSG_PREVIEW,
    SYN_MSG_SAVE
}SYN_MESSAGE_ID;

struct SynthesisParameterInfo
{
//public:
//    SynthesisParameterInfo();
//    virtual ~SynthesisParameterInfo();
//    SynthesisParameterInfo(SynthesisParameterInfo& src);
//    SynthesisParameterInfo& operator=(SynthesisParameterInfo& src);
    
    GPUImageView* _gpuImageView;    //渲染view
    std::string _strSrcVideoPath;    //原视频地址
    std::string _saveVideoPath;      //保存文件路径
    std::string _strThemeVideoPath;  //主题视频地址
    std::string _strFilterVideoPath; //滤镜视频地址
	bool _bMute;					     //是否静音
	std::string _strRecordPathi;	  //录音地址
	int _nRecordStartTime;		  //录音开始时间 ,以毫秒为单位
	int _nRecordAudioDuration;	  //录音时长,以秒为单位
	std::string _strBgMusicPath;	  //配乐地址
	int _nBgMusicStartTime;		  //配乐开始时间
	int _nBgMusicDuration;		  //配乐时长
	std::string _strDecorateImgPath; //装饰图片路径
	int _nSubtitleStartTime;	  //字幕开始时间，以毫秒为单位
	int _nSubitileEndTime;	  //字幕结束时间，以毫秒为单位
	std::string _strSubtitleImgPath; //字幕图片路径
    SYN_MESSAGE_ID _synMessageID; //合成消息id
    std::string _strPhotoAlbumTempPath; //临时保存文件路径
};

#endif /* defined(__libFeinnoVideo__SynthesisParameterInfo__) */
