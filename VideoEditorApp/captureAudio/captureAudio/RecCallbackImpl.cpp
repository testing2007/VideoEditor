//
//  RecCallbackImpl.cpp
//  libCaptureAudio
//
//  Created by wzq on 14-9-4.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#include "RecCallbackImpl.h"
#include <base/file_wrapper.h>
#include <convertCode/audio_instance_factory.h>

RecCallbackImpl::RecCallbackImpl():bStop(false),
critSect(*CriticalSectionWrapper::CreateCriticalSection()),
pAudioRecorder(AudioInstanceFactory::GetAudioRecorderInstance("wav"))
{
    
}

RecCallbackImpl::~RecCallbackImpl()
{
    
}

 void RecCallbackImpl::setCaptureFilePath(const char* path)
{
    FileWrapper& recFile = *FileWrapper::Create();
    recFile.OpenFile(path, false);
    recFile.CloseFile();

    filePath = path;
}

void RecCallbackImpl::setSampleRate(int sampleRate)
{
    this->sampleRate = sampleRate;
}

void RecCallbackImpl::setChannelLayout(FAudioChannelLayout channelLayout)
{
    this->channelLayout = channelLayout;
}

 void RecCallbackImpl::setSampleFormat(FSampleFormat sampleFormat)
{
    this->sampleFormat = sampleFormat;
}

 void RecCallbackImpl::start()
{
    pAudioRecorder->SetInputAudioFormat(sampleRate, channelLayout, sampleFormat, channelLayout==kMono?1:2, 0);
    pAudioRecorder->InitAudioFile(kEncodeVoAacenc, filePath.c_str());
}

 void RecCallbackImpl::captureData(uint8_t* data, uint32_t nSampleCount)
{
    CriticalSectionScoped lock(&critSect);
    if(bStop)
    {
        return ;
    }
    
    int nRet = 0;
    nRet = pAudioRecorder->EncodeAudioFrame((unsigned char**)&data, nSampleCount);
    if(nRet != 0)
    {
        printf("fail to convert the data\n");
    }

}

 void RecCallbackImpl::stop()
{
    CriticalSectionScoped lock(&critSect);
    bStop = true;
    pAudioRecorder->CloseAudioFile();

}