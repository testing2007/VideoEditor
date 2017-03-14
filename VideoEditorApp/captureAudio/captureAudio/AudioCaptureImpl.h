//
//  AudioCaptureImpl.h
//  libCaptureAudio
//
//  Created by wzq on 14-9-4.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef __libCaptureAudio__AudioCaptureImpl__
#define __libCaptureAudio__AudioCaptureImpl__

#include <iostream>
#include <string>
#include "IAudioCapture.h"

class AudioDeviceCapture;
class AudioCaptureImpl : public IAudioCapture
{
public:
    explicit AudioCaptureImpl(const char* path);
    virtual void start();
    virtual void stop();
    
private:
    AudioDeviceCapture* pCapture;
    std::string filePath;
};

#endif /* defined(__libCaptureAudio__AudioCaptureImpl__) */
