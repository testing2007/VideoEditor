//
//  SynthesisParamterInstance.h
//  libFeinnoVideo
//
//  Created by wzq on 14-9-16.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef __libFeinnoVideo__SynthesisParamterInstance__
#define __libFeinnoVideo__SynthesisParamterInstance__

#include <iostream>
#include "base/SynthesisParameterInfo.h"

class SynthesisParamterInstance

{
public:
	static SynthesisParamterInstance& instance();
	~SynthesisParamterInstance();
    
	SynthesisParameterInfo allParamters();
	
    void setGPUImageView(GPUImageView* gpuImageView);    //渲染view
    void setSaveVideoPath(std::string _saveVideoPath);      //保存文件路径
	void setSrcVideoPath(std::string& strSrcVideoPath);
	void setThemeVideoPath(std::string& themeVideoPath); //主题视频地址
	void setFilterVideoPath(std::string& strFilterVideoPath);	 //滤镜视频地址
	void setMute(bool bMute);					 //是否静音
	void setRecordPath(std::string& strRecordPath);		 //录音地址
    void setRecordStartTime(int nRecordStartTime);			 //录音开始时间 ,以毫秒为单位
	void setRecordAudioDuration(int nRecordAudioDuration);		 //录音时长,以秒为单位
	void setBgMusicPath(std::string&  strBgMusicPath);	 //配乐地址
	void setBgMusicStartTime(int nBgMusicStartTime);		 //配乐开始时间
	void setBgMusicDuration(int nBgMusicDuration);			 //配乐时长
	void setDecorateImgPath(std::string& strDecorateImgPath);	 //装饰图片路径
	void setSubtitleStartTime(int nSubtitleStartTime);		 //字幕开始时间，以毫秒为单位
	void setSubtitileEndTime(int nSubitileEndTime);		 //字幕结束时间，以毫秒为单位
	void setSubtitileImgPath(std::string& strSubtitleImgPath);	 //字幕图片路径
    void setPhotoAlbumTempPath(std::string& _strPhotoAlbumTempPath);   //临时保存文件路径
    // void setSynthesisMessageID(SYN_MESSAGE_ID synMessageID); //设置合成消息id
	
protected:
	SynthesisParamterInstance(){}
    
private:
	SynthesisParameterInfo params;
};

#endif /* defined(__libFeinnoVideo__SynthesisParamterInstance__) */
