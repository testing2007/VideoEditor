//
//  RecCallbackImpl.h
//  libCaptureAudio
//
//  Created by wzq on 14-9-4.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef __libCaptureAudio__RecCallbackImpl__
#define __libCaptureAudio__RecCallbackImpl__

#include <iostream>
#include "IRecCallback.h"
#include <convertCode/audio_instance_factory.h>
#include <base/critical_section_wrapper.h>
using namespace webrtc;

class RecCallbackImpl : public IRecCallback
{
public:
    RecCallbackImpl();
    virtual ~RecCallbackImpl();
    virtual void setCaptureFilePath(const char* path);
    virtual void setSampleRate(int sampleRate );
    virtual void setChannelLayout(FAudioChannelLayout nMonoOrStereo);
    virtual void setSampleFormat(FSampleFormat sampleFormat);
    
    virtual void start();
    virtual void captureData(uint8_t* data, uint32_t nSampleCount);
    virtual void stop();
private:
    int sampleRate;
    FAudioChannelLayout channelLayout;
    FSampleFormat sampleFormat;
    std::string filePath;
    
    AudioRecorderIntreface *pAudioRecorder;
    bool bStop;
    CriticalSectionWrapper& critSect;
};

#endif /* defined(__libCaptureAudio__RecCallbackImpl__) */
