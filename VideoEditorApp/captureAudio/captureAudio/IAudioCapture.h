//
//  IAudioCapture.h
//  libCaptureAudio
//
//  Created by wzq on 14-9-4.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef libCaptureAudio_IAudioCapture_h
#define libCaptureAudio_IAudioCapture_h

class IAudioCapture
{
public:
    IAudioCapture(){};
    virtual ~IAudioCapture(){};
    virtual void start() = 0;
    virtual void stop() = 0;
};

#endif
