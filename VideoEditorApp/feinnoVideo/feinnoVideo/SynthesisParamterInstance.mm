//
//  SynthesisParamterInstance.cpp
//  libFeinnoVideo
//
//  Created by wzq on 14-9-16.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#include "SynthesisParamterInstance.h"
#include <GPUImage/GPUImageView.h>

SynthesisParamterInstance& SynthesisParamterInstance::instance()
{
    static SynthesisParamterInstance* pInstance = NULL;
    if(pInstance==NULL)
    {
        pInstance = new SynthesisParamterInstance();
    }
    return *pInstance;
}

SynthesisParamterInstance::~SynthesisParamterInstance()
{
}

SynthesisParameterInfo SynthesisParamterInstance::allParamters()
{
    return this->params;
}

void SynthesisParamterInstance::setGPUImageView(GPUImageView* gpuImageView)
{
    this->params._gpuImageView = gpuImageView;
}

void SynthesisParamterInstance::setSaveVideoPath(std::string saveVideoPath)
{
    this->params._saveVideoPath = saveVideoPath;
}

void SynthesisParamterInstance::setSrcVideoPath(std::string& strSrcVideoPath)
{
    this->params._strSrcVideoPath = strSrcVideoPath;
}

void SynthesisParamterInstance::setThemeVideoPath(std::string& strThemeVideoPath)
{
    this->params._strThemeVideoPath = strThemeVideoPath;
}

void SynthesisParamterInstance::setFilterVideoPath(std::string& strFilterVideoPath)
{
    this->params._strFilterVideoPath = strFilterVideoPath;
}

void SynthesisParamterInstance::setMute(bool bMute)
{
    this->params._bMute = bMute;
}

void SynthesisParamterInstance::setRecordPath(std::string& strRecordPath)
{
    this->params._strRecordPathi = strRecordPath;
}

void SynthesisParamterInstance::setRecordStartTime(int nRecordStartTime)
{
    this->params._nRecordStartTime = nRecordStartTime;
}

void SynthesisParamterInstance::setRecordAudioDuration(int nRecordAudioDuration)
{
    this->params._nRecordAudioDuration = nRecordAudioDuration;
}

void SynthesisParamterInstance::setBgMusicPath(std::string&  strBgMusicPath)
{
    this->params._strBgMusicPath = strBgMusicPath;
}

void SynthesisParamterInstance::setBgMusicStartTime(int nBgMusicStartTime)
{
    this->params._nBgMusicStartTime = nBgMusicStartTime;
}

void SynthesisParamterInstance::setBgMusicDuration(int nBgMusicDuration)
{
    this->params._nBgMusicDuration = nBgMusicDuration;
}

void SynthesisParamterInstance::setDecorateImgPath(std::string& strDecorateImgPath)
{
    this->params._strDecorateImgPath = strDecorateImgPath;
}

void SynthesisParamterInstance::setSubtitleStartTime(int nSubtitleStartTime)
{
    this->params._nSubtitleStartTime = nSubtitleStartTime;
}

void SynthesisParamterInstance::setSubtitileEndTime(int nSubitileEndTime)
{
    this->params._nSubitileEndTime = nSubitileEndTime;
}

void SynthesisParamterInstance::setSubtitileImgPath(std::string& strSubtitleImgPath)
{
    this->params._strSubtitleImgPath = strSubtitleImgPath;
}

void SynthesisParamterInstance::setPhotoAlbumTempPath(std::string& strPhotoAlbumTempPath)
{
    this->params._strPhotoAlbumTempPath = strPhotoAlbumTempPath;
}
//void SynthesisParamterInstance::setSynthesisMessageID(SYN_MESSAGE_ID synMessageID)
//{
//    this->params._synMessageID = synMessageID;
//}
