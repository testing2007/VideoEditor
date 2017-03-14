//
//  AudioDeviceCapture.cpp
//  CapturePCMProj
//
//  Created by wzq on 14-8-8.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#include "AudioDeviceCapture.h"
#include <base/thread_wrapper.h>
#include <AudioToolbox/AudioSession.h>
#include "RecCallbackImpl.h"
#include <base/f_audio_types.h>

AudioDeviceCapture::AudioDeviceCapture(IRecCallback* recCallback/*=NULL*/):_critSect(*CriticalSectionWrapper::CreateCriticalSection()),
_recFile(*FileWrapper::Create()),
_captureWorkerThread(NULL),
_captureWorkerThreadId(0),
_auVoiceProcessing(NULL),
_initialized(false),
_isShutDown(false),
_recording(false),
_adbSampFreq(0),
_recChannels(0),
_recBytesPerSample(0),
_recordingCurrentSeq(0),
_pRecCallback(recCallback)
{
    memset(_recordingBuffer, 0, sizeof(_recordingBuffer));
    memset(_recordingLength, 0, sizeof(_recordingLength));
    memset(_recordingSeqNumber, 0, sizeof(_recordingSeqNumber));
    memset(_recBuffer, 0, kMaxBufferSizeBytes);
    
    //默认设置
    this->SetRecordingSampleRate(16000);
    this->SetRecordingChannels(N_REC_CHANNELS);
}

AudioDeviceCapture::~AudioDeviceCapture()
{
    Terminate();
    delete &_critSect;
    if (_pRecCallback!=NULL)
    {
        delete _pRecCallback;
        _pRecCallback = NULL;
    }
}

int32_t AudioDeviceCapture::Init()
{
    this->InitCaptureThread();
    this->InitDevice();
    return 0;
}

int32_t AudioDeviceCapture::InitCaptureThread()
{
    CriticalSectionScoped lock(&_critSect);
    
    if (_initialized) {
        return 0;
    }
   
    _isShutDown = false;
    
    // Create and start capture thread
    if (_captureWorkerThread == NULL) {
        _captureWorkerThread = webrtc::ThreadWrapper::CreateThread(RunCapture, this, kRealtimePriority,
                                      "CaptureWorkerThread");
        
        if (_captureWorkerThread == NULL) {
            return -1;
        }
        
        unsigned int threadID(0);
        bool res = _captureWorkerThread->Start(threadID);
        _captureWorkerThreadId = static_cast<uint32_t>(threadID);
    }
    
    _initialized = true;
    
    return 0;
}

int32_t AudioDeviceCapture::Terminate()
{
    if (!_initialized) {
        return 0;
    }
    
    // Stop capture thread
    if (_captureWorkerThread != NULL) {
        bool res = _captureWorkerThread->Stop();
        delete _captureWorkerThread;
        _captureWorkerThread = NULL;
    }
    
    // Shut down Audio Unit
    ShutdownRecord();
    
    _isShutDown = true;
    _initialized = false;
    

    return 0;
}

//*
int32_t AudioDeviceCapture::InitDevice()
{
    int32_t result = -1;
    
    // Check if already initialized
    if (NULL != _auVoiceProcessing) {
        // We already have initialized before and created any of the audio unit,
        // check that all exist
        return 0;
    }
    
    // Create Voice Processing Audio Unit
    AudioComponentDescription desc;
    AudioComponent comp;
    
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    
    comp = AudioComponentFindNext(NULL, &desc);
    if (NULL == comp) {
        //"  Could not find audio component for Audio Unit");
        return -1;
    }
    
    result = AudioComponentInstanceNew(comp, &_auVoiceProcessing);
    if (0 != result) {
        // "  Could not create Audio Unit instance (result=%d)", result);
        return -1;
    }
    
    // Set preferred hardware sample rate to 16 kHz
     Float64 sampleRate(16000.0);
     result = AudioSessionSetProperty(
                                     kAudioSessionProperty_PreferredHardwareSampleRate,
                                     sizeof(sampleRate), &sampleRate);
    if (0 != result) {
        //"Could not set preferred sample rate (result=%d)", result);
    }

    uint32_t voiceChat = kAudioSessionMode_VoiceChat;
    AudioSessionSetProperty(kAudioSessionProperty_Mode,
                            sizeof(voiceChat), &voiceChat);
    
    //////////////////////
    // Setup Voice Processing Audio Unit
    
    // Note: For Signal Processing AU element 0 is output bus, element 1 is
    //       input bus for global scope element is irrelevant (always use
    //       element 0)
    
    // Enable IO on both elements
    
    // todo: Below we just log and continue upon error. We might want
    //       to close AU and return error for some cases.
    // todo: Log info about setup.
    
    UInt32 enableIO = 1;
    result = AudioUnitSetProperty(_auVoiceProcessing,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  1,  // input bus
                                  &enableIO,
                                  sizeof(enableIO));
    if (0 != result) {
        //"  Could not enable IO on input (result=%d)", result);
    }
    
    result = AudioUnitSetProperty(_auVoiceProcessing,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  0,   // output bus
                                  &enableIO,
                                  sizeof(enableIO));
    if (0 != result) {
        //   "  Could not enable IO on output (result=%d)", result);
    }
    
    // Disable AU buffer allocation for the recorder, we allocate our own
    UInt32 flag = 0;
    result = AudioUnitSetProperty(
                                  _auVoiceProcessing, kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,  1, &flag, sizeof(flag));
    if (0 != result) {
        //  "  Could not disable AU buffer allocation (result=%d)", result);
        // Should work anyway
    }
    
    // Set recording callback
    AURenderCallbackStruct auCbS;
    memset(&auCbS, 0, sizeof(auCbS));
    auCbS.inputProc = RecordProcess;
    auCbS.inputProcRefCon = this;
    result = AudioUnitSetProperty(_auVoiceProcessing,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global, 1,
                                  &auCbS, sizeof(auCbS));
    if (0 != result) {
        //  "  Could not set record callback for Audio Unit (result=%d)", result);
    }
    
    // Set playout callback
    memset(&auCbS, 0, sizeof(auCbS));
    // auCbS.inputProc = PlayoutProcess;
    auCbS.inputProcRefCon = this;
    result = AudioUnitSetProperty(_auVoiceProcessing,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global, 0,
                                  &auCbS, sizeof(auCbS));
    if (0 != result) {
        // "  Could not set play callback for Audio Unit (result=%d)", result);
    }
    
    // Get stream format for out/0
    AudioStreamBasicDescription playoutDesc;
    UInt32 size = sizeof(playoutDesc);
    result = AudioUnitGetProperty(_auVoiceProcessing,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output, 0, &playoutDesc,
                                  &size);
    if (0 != result) {
        // "  Could not get stream format Audio Unit out/0 (result=%d)", result);
    }
    //  "  Audio Unit playout opened in sampling rate %f",
    //                 playoutDesc.mSampleRate);
    
    playoutDesc.mSampleRate = sampleRate;
    
    // Store the sampling frequency to use towards the Audio Device Buffer
    // todo: Add 48 kHz (increase buffer sizes). Other fs?
    if ((playoutDesc.mSampleRate > 44090.0)
        && (playoutDesc.mSampleRate < 44110.0)) {
        _adbSampFreq = 44000;
    } else if ((playoutDesc.mSampleRate > 15990.0)
               && (playoutDesc.mSampleRate < 16010.0)) {
        _adbSampFreq = 16000;
    } else if ((playoutDesc.mSampleRate > 7990.0)
               && (playoutDesc.mSampleRate < 8010.0)) {
        _adbSampFreq = 8000;
    } else {
        _adbSampFreq = 0;
        // "  Audio Unit out/0 opened in unknown sampling rate (%f)", playoutDesc.mSampleRate);
        // todo: We should bail out here.
    }
    
    this->SetRecordingSampleRate(_adbSampFreq);
    
    // Get stream format for in/1
    AudioStreamBasicDescription recordingDesc;
    size = sizeof(recordingDesc);
    result = AudioUnitGetProperty(_auVoiceProcessing,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input, 1, &recordingDesc,
                                  &size);
    if (0 != result) {
        //  Could not get stream format Audio Unit in/1 (result=%d)", result);
    }
    //" Audio Unit recording opened in sampling rate %f", recordingDesc.mSampleRate);
    
    recordingDesc.mSampleRate = sampleRate;
    
    // Set stream format for out/1 (use same sampling frequency as for in/1)
    recordingDesc.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger
    | kLinearPCMFormatFlagIsPacked
    | kLinearPCMFormatFlagIsNonInterleaved;
    
    recordingDesc.mBytesPerPacket = 2;
    recordingDesc.mFramesPerPacket = 1;
    recordingDesc.mBytesPerFrame = 2;
    recordingDesc.mChannelsPerFrame = 1;
    recordingDesc.mBitsPerChannel = 16;
    if(_pRecCallback!=NULL)
    {
        _pRecCallback->setSampleFormat(kSampleFmtS16);
    }
    result = AudioUnitSetProperty(_auVoiceProcessing,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output, 1, &recordingDesc,
                                  size);
    if (0 != result) {
        // Could not set stream format Audio Unit out/1 (result=%d)", result);
    }
    
    // Initialize here already to be able to get/set stream properties.
    result = AudioUnitInitialize(_auVoiceProcessing);
    if (0 != result) {
        //"  Could not init Audio Unit (result=%d)", result);
    }
    
    // 如果硬件采样率与 audio device buffer 采样率 不一致会怎么样？
    // Get hardware sample rate for logging (see if we get what we asked for)
    Float64 hardwareSampleRate = 0.0;
    size = sizeof(hardwareSampleRate);
    result = AudioSessionGetProperty(
                                     kAudioSessionProperty_CurrentHardwareSampleRate, &size,
                                     &hardwareSampleRate);
    if (0 != result) {
        //        WEBRTC_TRACE(kTraceDebug, kTraceAudioDevice, _id,
        //            "  Could not get current HW sample rate (result=%d)", result);
    }

    return 0;
}


int32_t AudioDeviceCapture::StartRecording() {
    CriticalSectionScoped lock(&_critSect);
    
      if (_recording) {
        //        WEBRTC_TRACE(kTraceInfo, kTraceAudioDevice, _id,
        //                     "  Recording already started");
        return 0;
    }
    
    // Reset recording buffer
    memset(_recordingBuffer, 0, sizeof(_recordingBuffer));
    memset(_recordingLength, 0, sizeof(_recordingLength));
    memset(_recordingSeqNumber, 0, sizeof(_recordingSeqNumber));
    _recordingCurrentSeq = 0;
//    _recordingBufferTotalSize = 0;
//    _recordingDelay = 0;
//    _recordingDelayHWAndOS = 0;
    // Make sure first call to update delay function will update delay
//    _recordingDelayMeasurementCounter = 9999;
//    _recWarning = 0;
//    _recError = 0;
    
//    if (!_playing) {
        // Start Audio Unit
        //        WEBRTC_TRACE(kTraceDebug, kTraceAudioDevice, _id,
        //                     "  Starting Audio Unit");
        OSStatus result = AudioOutputUnitStart(_auVoiceProcessing);
        if (0 != result) {
            //            WEBRTC_TRACE(kTraceCritical, kTraceAudioDevice, _id,
            //                         "  Error starting Audio Unit (result=%d)", result);
            return -1;
//        }
    }
    
    _recording = true;
    
    if(_pRecCallback!=NULL)
    {
        _pRecCallback->start();
    }

    return 0;
}

int32_t AudioDeviceCapture::SetInputFileRecording(const char fileName[kAdmMaxFileNameSize])
{
    CriticalSectionScoped lock(&_critSect);
    
    if(_pRecCallback != NULL)
    {
        _pRecCallback->setCaptureFilePath(fileName);
    }
    return 0;
    
//    _recFile.Flush();
//    _recFile.CloseFile();
//    
//    // _bytesWritten = 0;
//    
//    return (_recFile.OpenFile(fileName, false, false, false));
}

void AudioDeviceCapture::SetRecordingSampleRate(uint32_t fsHz)
{
    CriticalSectionScoped lock(&_critSect);
    _adbSampFreq = fsHz;
    if(_pRecCallback!=NULL)
    {
        _pRecCallback->setSampleRate((int)_adbSampFreq);
    }
}

void AudioDeviceCapture::SetRecordingChannels(uint8_t channels)
{
     CriticalSectionScoped lock(&_critSect);
    _recChannels = channels;
    _recBytesPerSample = 2*channels;
    if(_pRecCallback!=NULL)
    {
        _pRecCallback->setChannelLayout((FAudioChannelLayout)_recChannels);
    }
}


//////////////////////////////////////////////   Private Function ///////////////////////////////////////////////////////////////////////////////////////
int32_t AudioDeviceCapture::SetRecordedBuffer(const void* audioBuffer, uint32_t nSamples)
{
    CriticalSectionScoped lock(&_critSect);
    
    if (_recBytesPerSample == 0)
    {
        assert(false);
        return -1;
    }
    
    uint32_t _recSize = _recBytesPerSample*nSamples; // {2,4}*nSamples
    if (_recSize > kMaxBufferSizeBytes)
    {
        assert(false);
        return -1;
    }
    
    if (_recChannels == kChannelBoth)
    {
        // (default) copy the complete input buffer to the local buffer
        memcpy(&_recBuffer[0], audioBuffer, _recSize);
    }
    else
    {
        int16_t* ptr16In = (int16_t*)audioBuffer;
        int16_t* ptr16Out = (int16_t*)&_recBuffer[0];
        
        if (kChannelRight == _recChannels)
        {
            ptr16In++;
        }
        
        // exctract left or right channel from input buffer to the local buffer
        for (uint32_t i = 0; i < nSamples; i++)
        {
            *ptr16Out = *ptr16In;
            ptr16Out++;
            ptr16In++;
            ptr16In++;
        }
    }
    
//    if (_recFile.Open())
//    {
//        // write to binary file in mono or stereo (interleaved)
//        _recFile.Write(&_recBuffer[0], _recSize);
//        // _bytesWritten += _recSize; //纪录所写入的数据大小
//    }
    
    if(_pRecCallback!=NULL)
    {
        _pRecCallback->captureData((uint8_t*)audioBuffer, nSamples);
    }
    return 0;
}

OSStatus AudioDeviceCapture::RecordProcess(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    AudioDeviceCapture* ptrThis = static_cast<AudioDeviceCapture*>(inRefCon);
    
    return ptrThis->RecordProcessImpl(ioActionFlags,
                                      inTimeStamp,
                                      inBusNumber,
                                      inNumberFrames);
}


OSStatus AudioDeviceCapture::RecordProcessImpl(
                                     AudioUnitRenderActionFlags *ioActionFlags,
                                     const AudioTimeStamp *inTimeStamp,
                                     uint32_t inBusNumber,
                                     uint32_t inNumberFrames) {
    // Setup some basic stuff
    // Use temp buffer not to lock up recording buffer more than necessary
    // todo: Make dataTmp a member variable with static size that holds
    //       max possible frames?
    int16_t* dataTmp = new int16_t[inNumberFrames];
    memset(dataTmp, 0, 2*inNumberFrames);
    
    AudioBufferList abList;
    abList.mNumberBuffers = 1;
    abList.mBuffers[0].mData = dataTmp;
    abList.mBuffers[0].mDataByteSize = 2*inNumberFrames;  // 2 bytes/sample
    abList.mBuffers[0].mNumberChannels = 1;
    
    // Get data from mic
    OSStatus res = AudioUnitRender(_auVoiceProcessing,
                                   ioActionFlags, inTimeStamp,
                                   inBusNumber, inNumberFrames, &abList);
    if (res != 0) {
        //        WEBRTC_TRACE(kTraceWarning, kTraceAudioDevice, _id,
        //                     "  Error getting rec data, error = %d", res);
        delete [] dataTmp;
        return 0;
    }
    
    if (_recording) {
        // Insert all data in temp buffer into recording buffers
        // There is zero or one buffer partially full at any given time,
        // all others are full or empty
        // Full means filled with noSamp10ms samples.
        
        const unsigned int noSamp10ms = _adbSampFreq / 100;
        unsigned int dataPos = 0;
        uint16_t bufPos = 0;
        int16_t insertPos = -1;
        unsigned int nCopy = 0;  // Number of samples to copy
        
        while (dataPos < inNumberFrames) {
            // Loop over all recording buffers or
            // until we find the partially full buffer
            // First choice is to insert into partially full buffer,
            // second choice is to insert into empty buffer
            bufPos = 0;
            insertPos = -1;
            nCopy = 0;
            while (bufPos < N_REC_BUFFERS) {
                if ((_recordingLength[bufPos] > 0)
                    && (_recordingLength[bufPos] < noSamp10ms)) {
                    // Found the partially full buffer
                    insertPos = static_cast<int16_t>(bufPos);
                    // Don't need to search more, quit loop
                    bufPos = N_REC_BUFFERS;
                } else if ((-1 == insertPos)
                           && (0 == _recordingLength[bufPos])) {
                    // Found an empty buffer
                    insertPos = static_cast<int16_t>(bufPos);
                }
                ++bufPos;
            }//end while
            
            // Insert data into buffer
            if (insertPos > -1) {
                // We found a non-full buffer, copy data to it
                unsigned int dataToCopy = inNumberFrames - dataPos;
                unsigned int currentRecLen = _recordingLength[insertPos];
                unsigned int roomInBuffer = noSamp10ms - currentRecLen;
                nCopy = (dataToCopy < roomInBuffer ? dataToCopy : roomInBuffer);
                
                memcpy(&_recordingBuffer[insertPos][currentRecLen],
                       &dataTmp[dataPos], nCopy*sizeof(int16_t));
                if (0 == currentRecLen) {
                    _recordingSeqNumber[insertPos] = _recordingCurrentSeq;
                    ++_recordingCurrentSeq;
                }
//                _recordingBufferTotalSize += nCopy;
                // Has to be done last to avoid interrupt problems
                // between threads
                _recordingLength[insertPos] += nCopy;
                dataPos += nCopy;
            } else {
                // Didn't find a non-full buffer
                dataPos = inNumberFrames;  // Don't try to insert more
            }
        }//end while
    }
    
    delete [] dataTmp;
    
    return 0;
}

bool AudioDeviceCapture::RunCapture(void* ptrThis) {
    return static_cast<AudioDeviceCapture*>(ptrThis)->CaptureWorkerThread();
}

bool AudioDeviceCapture::CaptureWorkerThread() {
    if (_recording) {
        int bufPos = 0;
        unsigned int lowestSeq = 0;
        int lowestSeqBufPos = 0;
        bool foundBuf = true;
        const unsigned int noSamp10ms = _adbSampFreq / 100;
        
        while (foundBuf) {
            // Check if we have any buffer with data to insert
            // into the Audio Device Buffer,
            // and find the one with the lowest seq number
            foundBuf = false;
            for (bufPos = 0; bufPos < N_REC_BUFFERS; ++bufPos) {
                if (noSamp10ms == _recordingLength[bufPos]) {
                    if (!foundBuf) {
                        lowestSeq = _recordingSeqNumber[bufPos];
                        lowestSeqBufPos = bufPos;
                        foundBuf = true;
                    } else if (_recordingSeqNumber[bufPos] < lowestSeq) {
                        lowestSeq = _recordingSeqNumber[bufPos];
                        lowestSeqBufPos = bufPos;
                    }
                }
            }  // for
            
            // Insert data into the Audio Device Buffer if found any
            if (foundBuf) {
                //*
                // Update recording delay
//                UpdateRecordingDelay();
                
                // Set the recorded buffer
                this->SetRecordedBuffer(reinterpret_cast<int8_t*>(
                                                       _recordingBuffer[lowestSeqBufPos]),
                                                       _recordingLength[lowestSeqBufPos]);
                
                // Don't need to set the current mic level in ADB since we only
                // support digital AGC,
                // and besides we cannot get or set the IOS mic level anyway.
                
                // Set VQE info, use clockdrift == 0
                // _ptrAudioBuffer->SetVQEData(_playoutDelay, _recordingDelay, 0);
                
                // Deliver recorded samples at specified sample rate, mic level
                // etc. to the observer using callback
                // _ptrAudioBuffer->DeliverRecordedData();
                
                // Make buffer available
                _recordingSeqNumber[lowestSeqBufPos] = 0;
                // _recordingBufferTotalSize -= _recordingLength[lowestSeqBufPos];
                // Must be done last to avoid interrupt problems between threads
                _recordingLength[lowestSeqBufPos] = 0;
                 //*/
            }
        }  // while (foundBuf)
    }  // if (_recording)
    
    {
        // Normal case
        // Sleep thread (5ms) to let other threads get to work
        // todo: Is 5 ms optimal? Sleep shorter if inserted into the Audio
        //       Device Buffer?
        timespec t;
        t.tv_sec = 0;
        t.tv_nsec = 5*1000*1000;
        nanosleep(&t, NULL);
    }
    
    return true;
}

int32_t AudioDeviceCapture::ShutdownRecord()
{
    if(_pRecCallback!=NULL)
    {
        _pRecCallback->stop();
    }
    
    // Close and delete AU
    OSStatus result = -1;
    if (NULL != _auVoiceProcessing) {
        result = AudioOutputUnitStop(_auVoiceProcessing);
        result = AudioComponentInstanceDispose(_auVoiceProcessing);
         _auVoiceProcessing = NULL;
        _recording = false;
    }
    return 0;
}




