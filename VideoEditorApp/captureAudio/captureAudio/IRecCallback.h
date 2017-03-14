//
//  IRecCallback.h
//  libCaptureAudio
//
//  Created by wzq on 14-9-4.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef libCaptureAudio_IRecCallback_h
#define libCaptureAudio_IRecCallback_h
#include <base/f_audio_types.h>

class IRecCallback
{
public:
    virtual ~IRecCallback(){}
    virtual void setCaptureFilePath(const char* path)=0;
    virtual void setSampleRate(int sampleRate)=0;
    virtual void setChannelLayout(FAudioChannelLayout nMonoOrStereo)=0;
    virtual void setSampleFormat(FSampleFormat sampleFormat)=0;
    
    virtual void start()=0;
    virtual void captureData(uint8_t* data, uint32_t nSampleCount)=0;
    virtual void stop()=0;
protected:
    IRecCallback(){}
};

#endif
