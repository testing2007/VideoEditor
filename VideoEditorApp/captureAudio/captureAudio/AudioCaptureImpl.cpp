//
//  AudioCaptureImpl.cpp
//  libCaptureAudio
//
//  Created by wzq on 14-9-4.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#include "AudioCaptureImpl.h"
#include "AudioDeviceCapture.h"
#include "RecCallbackImpl.h"

AudioCaptureImpl::AudioCaptureImpl(const char* path):filePath(path)
{
}

void AudioCaptureImpl::start()
{
    pCapture = new AudioDeviceCapture(new RecCallbackImpl());
    pCapture->Init();
    pCapture->SetInputFileRecording(filePath.c_str());
    pCapture->StartRecording();
}

void AudioCaptureImpl::stop()
{
    pCapture->Terminate();
    // pCapture->ShutdownRecord();
}
