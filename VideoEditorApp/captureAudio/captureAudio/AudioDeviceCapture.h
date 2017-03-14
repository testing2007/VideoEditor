//
//  AudioDeviceCapture.h
//  CapturePCMProj
//
//  Created by wzq on 14-8-8.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef __CapturePCMProj__AudioDeviceCapture__
#define __CapturePCMProj__AudioDeviceCapture__

#include <iostream>
#include <AudioUnit/AudioUnit.h>
#include <base/file_wrapper.h>
#include <base/critical_section_wrapper.h>

//#include "RecWavFileCallback.h"

const uint32_t N_REC_SAMPLES_PER_SEC = 44000;
const uint32_t N_REC_CHANNELS = 1;
const uint32_t ENGINE_REC_BUF_SIZE_IN_SAMPLES = (N_REC_SAMPLES_PER_SEC / 100);
const uint16_t N_REC_BUFFERS = 20;
const int kAdmMaxFileNameSize = 512;
const uint32_t kMaxBufferSizeBytes = 3840; // 10ms in stereo @ 96kHz

//前置声明一个在namespace定义的类
namespace webrtc {
    class ThreadWrapper;
}

using namespace webrtc;
class IRecCallback;

class AudioDeviceCapture
{
public:
    explicit AudioDeviceCapture(IRecCallback* recCallback=NULL);
    ~AudioDeviceCapture();
    
    int32_t Init();
    int32_t StartRecording();
    int32_t ShutdownRecord();
    int32_t Terminate();
    
    void SetRecordingSampleRate(uint32_t fsHz);
    void SetRecordingChannels(uint8_t channels);
    // void SetCaptureCallback();
    
    int32_t SetInputFileRecording(const char fileName[kAdmMaxFileNameSize]);
    

private:
    int32_t InitCaptureThread();
    int32_t InitDevice();

    static bool RunCapture(void* ptrThis);
    bool CaptureWorkerThread();
    
    int32_t SetRecordedBuffer(const void* audioBuffer, uint32_t nSamples);
    
    static OSStatus RecordProcess(void *inRefCon,
                                               AudioUnitRenderActionFlags *ioActionFlags,
                                               const AudioTimeStamp *inTimeStamp,
                                               UInt32 inBusNumber,
                                               UInt32 inNumberFrames,
                                               AudioBufferList *ioData);
    
    OSStatus RecordProcessImpl(AudioUnitRenderActionFlags *ioActionFlags,
                                                const AudioTimeStamp *inTimeStamp,
                                                uint32_t inBusNumber,
                                                uint32_t inNumberFrames);
    
private:
    CriticalSectionWrapper& _critSect;
    ThreadWrapper* _captureWorkerThread;
    uint32_t _captureWorkerThreadId;
    
    AudioUnit _auVoiceProcessing;

private:
    FileWrapper&   _recFile;
    IRecCallback* _pRecCallback;

private:
    bool _initialized;
    bool _isShutDown;
    bool _recording;
    
    uint32_t  _adbSampFreq;
    int _recChannels;
    uint8_t _recBytesPerSample;
    
    int16_t _recordingBuffer[N_REC_BUFFERS][ENGINE_REC_BUF_SIZE_IN_SAMPLES];
    uint32_t _recordingLength[N_REC_BUFFERS];
    uint32_t _recordingSeqNumber[N_REC_BUFFERS];
    uint32_t _recordingCurrentSeq;
    
    //  16-bit,48kHz mono,10ms => nSamples=480 => _recSize=2*480=960 bytes
    //  16-bit,48kHz stereo,10ms => nSamples=480 => _recSize=4*480=1920 bytes
    //  10ms in stereo @ 96kHz
    int8_t   _recBuffer[kMaxBufferSizeBytes];
};

#endif /* defined(__CapturePCMProj__AudioDeviceCapture__) */
