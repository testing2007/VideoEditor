/*
 *  Copyright (c) 2012 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#include "media_file_utility.h"

#include <assert.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <string.h>

#include "common_types.h"
//#include "webrtc/engine_configurations.h"
// #include "module_common_types.h"
#include "file_wrapper.h"
// #include "c/system_wrappers/interface/trace.h"

#define WEBRTC_TRACE //FOR TESTING

namespace webrtc {
ModuleFileUtility::ModuleFileUtility(const int32_t id)
    : _wavFormatObj(),
      _dataSize(0),
      _readSizeBytes(0),
      _id(id),
      _stopPointInMs(0),
      _startPointInMs(0),
      _playoutPositionMs(0),
      _bytesWritten(0),
      codec_info_(),
 //      _codecId(kCodecNoCodec),
      _bytesPerSample(0),
      _readPos(0),
      _reading(false),
      _writing(false),
      _tempData()
{
    WEBRTC_TRACE(kTraceMemory, kTraceFile, _id,
                 "ModuleFileUtility::ModuleFileUtility()");
}

ModuleFileUtility::~ModuleFileUtility()
{
    WEBRTC_TRACE(kTraceMemory, kTraceFile, _id,
                 "ModuleFileUtility::~ModuleFileUtility()");
}


int32_t ModuleFileUtility::ReadWavHeader(InStream& wav)
{
    WAVE_RIFF_header RIFFheaderObj;
    WAVE_CHUNK_header CHUNKheaderObj;
    // TODO (hellner): tmpStr and tmpStr2 seems unnecessary here.
    char tmpStr[6] = "FOUR";
    unsigned char tmpStr2[4];
    int32_t i, len;
    bool dataFound = false;
    bool fmtFound = false;
    int8_t dummyRead;


    _dataSize = 0;
    len = wav.Read(&RIFFheaderObj, sizeof(WAVE_RIFF_header));
    if(len != sizeof(WAVE_RIFF_header))
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "Not a wave file (too short)");
        return -1;
    }

    for (i = 0; i < 4; i++)
    {
        tmpStr[i] = RIFFheaderObj.ckID[i];
    }
    if(strcmp(tmpStr, "RIFF") != 0)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "Not a wave file (does not have RIFF)");
        return -1;
    }
    for (i = 0; i < 4; i++)
    {
        tmpStr[i] = RIFFheaderObj.wave_ckID[i];
    }
    if(strcmp(tmpStr, "WAVE") != 0)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "Not a wave file (does not have WAVE)");
        return -1;
    }

    len = wav.Read(&CHUNKheaderObj, sizeof(WAVE_CHUNK_header));

    // WAVE files are stored in little endian byte order. Make sure that the
    // data can be read on big endian as well.
    // TODO (hellner): little endian to system byte order should be done in
    //                 in a subroutine.
    memcpy(tmpStr2, &CHUNKheaderObj.fmt_ckSize, 4);
    CHUNKheaderObj.fmt_ckSize =
        (int32_t) ((uint32_t) tmpStr2[0] +
                         (((uint32_t)tmpStr2[1])<<8) +
                         (((uint32_t)tmpStr2[2])<<16) +
                         (((uint32_t)tmpStr2[3])<<24));

    memcpy(tmpStr, CHUNKheaderObj.fmt_ckID, 4);

    while ((len == sizeof(WAVE_CHUNK_header)) && (!fmtFound || !dataFound))
    {
        if(strcmp(tmpStr, "fmt ") == 0)
        {
            len = wav.Read(&_wavFormatObj, sizeof(WAVE_FMTINFO_header));

            memcpy(tmpStr2, &_wavFormatObj.formatTag, 2);
            _wavFormatObj.formatTag =
                (WaveFormats) ((uint32_t)tmpStr2[0] +
                               (((uint32_t)tmpStr2[1])<<8));
            memcpy(tmpStr2, &_wavFormatObj.nChannels, 2);
            _wavFormatObj.nChannels =
                (int16_t) ((uint32_t)tmpStr2[0] +
                                 (((uint32_t)tmpStr2[1])<<8));
            memcpy(tmpStr2, &_wavFormatObj.nSamplesPerSec, 4);
            _wavFormatObj.nSamplesPerSec =
                (int32_t) ((uint32_t)tmpStr2[0] +
                                 (((uint32_t)tmpStr2[1])<<8) +
                                 (((uint32_t)tmpStr2[2])<<16) +
                                 (((uint32_t)tmpStr2[3])<<24));
            memcpy(tmpStr2, &_wavFormatObj.nAvgBytesPerSec, 4);
            _wavFormatObj.nAvgBytesPerSec =
                (int32_t) ((uint32_t)tmpStr2[0] +
                                 (((uint32_t)tmpStr2[1])<<8) +
                                 (((uint32_t)tmpStr2[2])<<16) +
                                 (((uint32_t)tmpStr2[3])<<24));
            memcpy(tmpStr2, &_wavFormatObj.nBlockAlign, 2);
            _wavFormatObj.nBlockAlign =
                (int16_t) ((uint32_t)tmpStr2[0] +
                                 (((uint32_t)tmpStr2[1])<<8));
            memcpy(tmpStr2, &_wavFormatObj.nBitsPerSample, 2);
            _wavFormatObj.nBitsPerSample =
                (int16_t) ((uint32_t)tmpStr2[0] +
                                 (((uint32_t)tmpStr2[1])<<8));

            for (i = 0;
                 i < (CHUNKheaderObj.fmt_ckSize -
                      (int32_t)sizeof(WAVE_FMTINFO_header));
                 i++)
            {
                len = wav.Read(&dummyRead, 1);
                if(len != 1)
                {
                    WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                                 "File corrupted, reached EOF (reading fmt)");
                    return -1;
                }
            }
            fmtFound = true;
        }
        else if(strcmp(tmpStr, "data") == 0)
        {
            _dataSize = CHUNKheaderObj.fmt_ckSize;
            dataFound = true;
            break;
        }
        else
        {
            for (i = 0; i < (CHUNKheaderObj.fmt_ckSize); i++)
            {
                len = wav.Read(&dummyRead, 1);
                if(len != 1)
                {
                    WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                                 "File corrupted, reached EOF (reading other)");
                    return -1;
                }
            }
        }

        len = wav.Read(&CHUNKheaderObj, sizeof(WAVE_CHUNK_header));

        memcpy(tmpStr2, &CHUNKheaderObj.fmt_ckSize, 4);
        CHUNKheaderObj.fmt_ckSize =
            (int32_t) ((uint32_t)tmpStr2[0] +
                             (((uint32_t)tmpStr2[1])<<8) +
                             (((uint32_t)tmpStr2[2])<<16) +
                             (((uint32_t)tmpStr2[3])<<24));

        memcpy(tmpStr, CHUNKheaderObj.fmt_ckID, 4);
    }

    // Either a proper format chunk has been read or a data chunk was come
    // across.
    if( (_wavFormatObj.formatTag != kWaveFormatPcm) &&
        (_wavFormatObj.formatTag != kWaveFormatALaw) &&
        (_wavFormatObj.formatTag != kWaveFormatMuLaw))
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "Coding formatTag value=%d not supported!",
                     _wavFormatObj.formatTag);
        return -1;
    }
    if((_wavFormatObj.nChannels < 1) ||
        (_wavFormatObj.nChannels > 2))
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "nChannels value=%d not supported!",
                     _wavFormatObj.nChannels);
        return -1;
    }

    if((_wavFormatObj.nBitsPerSample != 8) &&
        (_wavFormatObj.nBitsPerSample != 16))
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "nBitsPerSample value=%d not supported!",
                     _wavFormatObj.nBitsPerSample);
        return -1;
    }

    // Calculate the number of bytes that 10 ms of audio data correspond to.
    if(_wavFormatObj.formatTag == kWaveFormatPcm)
    {
        // TODO (hellner): integer division for 22050 and 11025 would yield
        //                 the same result as the else statement. Remove those
        //                 special cases?
        if(_wavFormatObj.nSamplesPerSec == 44100)
        {
            _readSizeBytes = 440 * _wavFormatObj.nChannels *
                (_wavFormatObj.nBitsPerSample / 8);
        } else if(_wavFormatObj.nSamplesPerSec == 22050) {
            _readSizeBytes = 220 * _wavFormatObj.nChannels *
                (_wavFormatObj.nBitsPerSample / 8);
        } else if(_wavFormatObj.nSamplesPerSec == 11025) {
            _readSizeBytes = 110 * _wavFormatObj.nChannels *
                (_wavFormatObj.nBitsPerSample / 8);
        } else {
            _readSizeBytes = (_wavFormatObj.nSamplesPerSec/100) *
              _wavFormatObj.nChannels * (_wavFormatObj.nBitsPerSample / 8);
        }

    } else {
        _readSizeBytes = (_wavFormatObj.nSamplesPerSec/100) *
            _wavFormatObj.nChannels * (_wavFormatObj.nBitsPerSample / 8);
    }
    return 0;
}

int32_t ModuleFileUtility::InitWavReading(InStream& wav,
                                          const uint32_t start,
                                          const uint32_t stop)
{

    _reading = false;

    if(ReadWavHeader(wav) == -1)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "failed to read WAV header!");
        return -1;
    }

    _playoutPositionMs = 0;
    _readPos = 0;

    if(start > 0)
    {
        uint8_t dummy[WAV_MAX_BUFFER_SIZE];
        int32_t readLength;
        if(_readSizeBytes <= WAV_MAX_BUFFER_SIZE)
        {
            while (_playoutPositionMs < start)
            {
                readLength = wav.Read(dummy, _readSizeBytes);
                if(readLength == _readSizeBytes)
                {
                    _readPos += readLength;
                    _playoutPositionMs += 10;
                }
                else // Must have reached EOF before start position!
                {
                    WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                       "InitWavReading(), EOF before start position");
                    return -1;
                }
            }
        }
        else
        {
            return -1;
        }
    }
   
    _bytesPerSample = _wavFormatObj.nBitsPerSample / 8;

    _startPointInMs = start;
    _stopPointInMs = stop;
    _reading = true;
    return 0;
}

int32_t ModuleFileUtility::ReadWavDataAsMono(
    InStream& wav,
    int8_t* outData,
    const uint32_t bufferSize)
{
    WEBRTC_TRACE(
        kTraceStream,
        kTraceFile,
        _id,
        "ModuleFileUtility::ReadWavDataAsMono(wav= 0x%x, outData= 0x%d,\
 bufSize= %ld)",
        &wav,
        outData,
        bufferSize);

    // The number of bytes that should be read from file.
    const uint32_t totalBytesNeeded = _readSizeBytes;
    // The number of bytes that will be written to outData.
    const uint32_t bytesRequested = (codec_info_.channels == 2) ?
        totalBytesNeeded >> 1 : totalBytesNeeded;
//    if(bufferSize < bytesRequested)
//    {
//        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
//                     "ReadWavDataAsMono: output buffer is too short!");
//        return -1;
//    }
    if(outData == NULL)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "ReadWavDataAsMono: output buffer NULL!");
        return -1;
    }

    if(!_reading)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "ReadWavDataAsMono: no longer reading file.");
        return -1;
    }

    int32_t bytesRead = ReadWavData(
        wav,
        (codec_info_.channels == 2) ? _tempData : (uint8_t*)outData,
        totalBytesNeeded);
    if(bytesRead == 0)
    {
        return 0;
    }
    if(bytesRead < 0)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "ReadWavDataAsMono: failed to read data from WAV file.");
        return -1;
    }
    // Output data is should be mono.
    if(codec_info_.channels == 2)
    {
        for (uint32_t i = 0; i < bufferSize / _bytesPerSample; i++)
        {
            // Sample value is the average of left and right buffer rounded to
            // closest integer value. Note samples can be either 1 or 2 byte.
            if(_bytesPerSample == 1)
            {
                _tempData[i] = ((_tempData[2 * i] + _tempData[(2 * i) + 1] +
                                 1) >> 1);
            }
            else
            {
                int16_t* sampleData = (int16_t*) _tempData;
                sampleData[i] = ((sampleData[2 * i] + sampleData[(2 * i) + 1] +
                                  1) >> 1);
            }
        }
        memcpy(outData, _tempData, bufferSize);
    }
    return bufferSize;
}

int32_t ModuleFileUtility::ReadWavDataAsStereo(
    InStream& wav,
    int8_t* outDataLeft,
    int8_t* outDataRight,
    const uint32_t bufferSize)
{
    WEBRTC_TRACE(
        kTraceStream,
        kTraceFile,
        _id,
        "ModuleFileUtility::ReadWavDataAsStereo(wav= 0x%x, outLeft= 0x%x,\
 outRight= 0x%x, bufSize= %ld)",
        &wav,
        outDataLeft,
        outDataRight,
        bufferSize);

    if((outDataLeft == NULL) ||
       (outDataRight == NULL))
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "ReadWavDataAsMono: an input buffer is NULL!");
        return -1;
    }
    if(codec_info_.channels != 2)
    {
        WEBRTC_TRACE(
            kTraceError,
            kTraceFile,
            _id,
            "ReadWavDataAsStereo: WAV file does not contain stereo data!");
        return -1;
    }
    if(! _reading)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "ReadWavDataAsStereo: no longer reading file.");
        return -1;
    }

    // The number of bytes that should be read from file.
    const uint32_t totalBytesNeeded = _readSizeBytes;
    // The number of bytes that will be written to the left and the right
    // buffers.
    const uint32_t bytesRequested = totalBytesNeeded >> 1;
    if(bufferSize < bytesRequested)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "ReadWavData: Output buffers are too short!");
        assert(false);
        return -1;
    }

    int32_t bytesRead = ReadWavData(wav, _tempData, totalBytesNeeded);
    if(bytesRead <= 0)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "ReadWavDataAsStereo: failed to read data from WAV file.");
        return -1;
    }

    // Turn interleaved audio to left and right buffer. Note samples can be
    // either 1 or 2 bytes
    if(_bytesPerSample == 1)
    {
        for (uint32_t i = 0; i < bytesRequested; i++)
        {
            outDataLeft[i]  = _tempData[2 * i];
            outDataRight[i] = _tempData[(2 * i) + 1];
        }
    }
    else if(_bytesPerSample == 2)
    {
        int16_t* sampleData = reinterpret_cast<int16_t*>(_tempData);
        int16_t* outLeft = reinterpret_cast<int16_t*>(outDataLeft);
        int16_t* outRight = reinterpret_cast<int16_t*>(
            outDataRight);

        // Bytes requested to samples requested.
        uint32_t sampleCount = bytesRequested >> 1;
        for (uint32_t i = 0; i < sampleCount; i++)
        {
            outLeft[i] = sampleData[2 * i];
            outRight[i] = sampleData[(2 * i) + 1];
        }
    } else {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                   "ReadWavStereoData: unsupported sample size %d!",
                   _bytesPerSample);
        assert(false);
        return -1;
    }
    return bytesRequested;
}

int32_t ModuleFileUtility::ReadWavData(
    InStream& wav,
    uint8_t* buffer,
    const uint32_t dataLengthInBytes)
{
    WEBRTC_TRACE(
        kTraceStream,
        kTraceFile,
        _id,
        "ModuleFileUtility::ReadWavData(wav= 0x%x, buffer= 0x%x, dataLen= %ld)",
        &wav,
        buffer,
        dataLengthInBytes);


    if(buffer == NULL)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "ReadWavDataAsMono: output buffer NULL!");
        return -1;
    }

    // Make sure that a read won't return too few samples.
    // TODO (hellner): why not read the remaining bytes needed from the start
    //                 of the file?
    if((_dataSize - _readPos) < (int32_t)dataLengthInBytes)
    {
        // Rewind() being -1 may be due to the file not supposed to be looped.
        if(wav.Rewind() == -1)
        {
            _reading = false;
            return 0;
        }
        if(InitWavReading(wav, _startPointInMs, _stopPointInMs) == -1)
        {
            _reading = false;
            return -1;
        }
    }

    int32_t bytesRead = wav.Read(buffer, dataLengthInBytes);
    if(bytesRead < 0)
    {
        _reading = false;
        return -1;
    }

    // This should never happen due to earlier sanity checks.
    // TODO (hellner): change to an assert and fail here since this should
    //                 never happen...
    if(bytesRead < (int32_t)dataLengthInBytes)
    {
        if((wav.Rewind() == -1) ||
            (InitWavReading(wav, _startPointInMs, _stopPointInMs) == -1))
        {
            _reading = false;
            return -1;
        }
        else
        {
            bytesRead = wav.Read(buffer, dataLengthInBytes);
            if(bytesRead < (int32_t)dataLengthInBytes)
            {
                _reading = false;
                return -1;
            }
        }
    }

    _readPos += bytesRead;

    // TODO (hellner): Why is dataLengthInBytes let dictate the number of bytes
    //                 to read when exactly 10ms should be read?!
    _playoutPositionMs += 10;
    if((_stopPointInMs > 0) &&
        (_playoutPositionMs >= _stopPointInMs))
    {
        if((wav.Rewind() == -1) ||
            (InitWavReading(wav, _startPointInMs, _stopPointInMs) == -1))
        {
            _reading = false;
        }
    }
    return bytesRead;
}

int32_t ModuleFileUtility::InitWavWriting(OutStream& wav,
                                          const WaveFormats format)
{
    _writing = false;

    
    switch (format)
    {
        case kWaveFormatMuLaw:
        {
            _bytesPerSample = 1;
            if(WriteWavHeader(wav, 8000, _bytesPerSample, 1/*zhiqiang*/,
                              kWaveFormatMuLaw, 0) == -1)
            {
                return -1;
            }
        }
            break;
        case kWaveFormatALaw:
        {
            _bytesPerSample = 1;
            if(WriteWavHeader(wav, 8000, _bytesPerSample, 1/*zhiqiang*/, kWaveFormatALaw,
                              0) == -1)
            {
                return -1;
            }
        }
            break;
        case kWaveFormatPcm:
            _bytesPerSample = 2;
            if(WriteWavHeader(wav, 16000/*zhiqiang*/, _bytesPerSample, 1/*zhiqiang*/,
                              kWaveFormatPcm, 0) == -1)
            {
                return -1;
            }
            break;
        default:
            return -1;
            break;
    }
      _writing = true;
    _bytesWritten = 0;
    return 0;
}

int32_t ModuleFileUtility::WriteWavData(OutStream& out,
                                        const int8_t*  buffer,
                                        const uint32_t dataLength)
{
    WEBRTC_TRACE(
        kTraceStream,
        kTraceFile,
        _id,
        "ModuleFileUtility::WriteWavData(out= 0x%x, buf= 0x%x, dataLen= %d)",
        &out,
        buffer,
        dataLength);

    if(buffer == NULL)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "WriteWavData: input buffer NULL!");
        return -1;
    }

    if(!out.Write(buffer, dataLength))
    {
        return -1;
    }
    _bytesWritten += dataLength;
    return dataLength;
}


int32_t ModuleFileUtility::WriteWavHeader(
    OutStream& wav,
    const uint32_t freq,
    const uint32_t bytesPerSample,
    const uint32_t channels,
    const uint32_t format,
    const uint32_t lengthInBytes)
{

    // Frame size in bytes for 10 ms of audio.
    // TODO (hellner): 44.1 kHz has 440 samples frame size. Doesn't seem to
    //                 be taken into consideration here!
    int32_t frameSize = (freq / 100) * bytesPerSample * channels;

    // Calculate the number of full frames that the wave file contain.
    const int32_t dataLengthInBytes = frameSize *
        (lengthInBytes / frameSize);

    int8_t tmpStr[4];
    int8_t tmpChar;
    uint32_t tmpLong;

    memcpy(tmpStr, "RIFF", 4);
    wav.Write(tmpStr, 4);

    tmpLong = dataLengthInBytes + 36;
    tmpChar = (int8_t)(tmpLong);
    wav.Write(&tmpChar, 1);
    tmpChar = (int8_t)(tmpLong >> 8);
    wav.Write(&tmpChar, 1);
    tmpChar = (int8_t)(tmpLong >> 16);
    wav.Write(&tmpChar, 1);
    tmpChar = (int8_t)(tmpLong >> 24);
    wav.Write(&tmpChar, 1);

    memcpy(tmpStr, "WAVE", 4);
    wav.Write(tmpStr, 4);

    memcpy(tmpStr, "fmt ", 4);
    wav.Write(tmpStr, 4);

    tmpChar = 16;
    wav.Write(&tmpChar, 1);
    tmpChar = 0;
    wav.Write(&tmpChar, 1);
    tmpChar = 0;
    wav.Write(&tmpChar, 1);
    tmpChar = 0;
    wav.Write(&tmpChar, 1);

    tmpChar = (int8_t)(format);
    wav.Write(&tmpChar, 1);
    tmpChar = 0;
    wav.Write(&tmpChar, 1);

    tmpChar = (int8_t)(channels);
    wav.Write(&tmpChar, 1);
    tmpChar = 0;
    wav.Write(&tmpChar, 1);

    tmpLong = freq;
    tmpChar = (int8_t)(tmpLong);
    wav.Write(&tmpChar, 1);
    tmpChar = (int8_t)(tmpLong >> 8);
    wav.Write(&tmpChar, 1);
    tmpChar = (int8_t)(tmpLong >> 16);
    wav.Write(&tmpChar, 1);
    tmpChar = (int8_t)(tmpLong >> 24);
    wav.Write(&tmpChar, 1);

    // nAverageBytesPerSec = Sample rate * Bytes per sample * Channels
    tmpLong = bytesPerSample * freq * channels;
    tmpChar = (int8_t)(tmpLong);
    wav.Write(&tmpChar, 1);
    tmpChar = (int8_t)(tmpLong >> 8);
    wav.Write(&tmpChar, 1);
    tmpChar = (int8_t)(tmpLong >> 16);
    wav.Write(&tmpChar, 1);
    tmpChar = (int8_t)(tmpLong >> 24);
    wav.Write(&tmpChar, 1);

    // nBlockAlign = Bytes per sample * Channels
    tmpChar = (int8_t)(bytesPerSample * channels);
    wav.Write(&tmpChar, 1);
    tmpChar = 0;
    wav.Write(&tmpChar, 1);

    tmpChar = (int8_t)(bytesPerSample*8);
    wav.Write(&tmpChar, 1);
    tmpChar = 0;
    wav.Write(&tmpChar, 1);

    memcpy(tmpStr, "data", 4);
    wav.Write(tmpStr, 4);

    tmpLong = dataLengthInBytes;
    tmpChar = (int8_t)(tmpLong);
    wav.Write(&tmpChar, 1);
    tmpChar = (int8_t)(tmpLong >> 8);
    wav.Write(&tmpChar, 1);
    tmpChar = (int8_t)(tmpLong >> 16);
    wav.Write(&tmpChar, 1);
    tmpChar = (int8_t)(tmpLong >> 24);
    wav.Write(&tmpChar, 1);

    return 0;
}

int32_t ModuleFileUtility::UpdateWavHeader(OutStream& wav)
{
    int32_t res = -1;
    if(wav.Rewind() == -1)
    {
        return -1;
    }
    uint32_t channels = (codec_info_.channels == 0) ?
        1 : codec_info_.channels;

    if(STR_CASE_CMP(codec_info_.plname, "L16") == 0)
    {
        res = WriteWavHeader(wav, codec_info_.plfreq, 2, channels,
                             kWaveFormatPcm, _bytesWritten);
    } else if(STR_CASE_CMP(codec_info_.plname, "PCMU") == 0) {
            res = WriteWavHeader(wav, 8000, 1, channels, kWaveFormatMuLaw,
                                 _bytesWritten);
    } else if(STR_CASE_CMP(codec_info_.plname, "PCMA") == 0) {
            res = WriteWavHeader(wav, 8000, 1, channels, kWaveFormatALaw,
                                 _bytesWritten);
    } else {
        // Allow calling this API even if not writing to a WAVE file.
        // TODO (hellner): why?!
        return 0;
    }
    return res;
}

int32_t ModuleFileUtility::InitPCMReading(InStream& pcm,
                                          const uint32_t start,
                                          const uint32_t stop,
                                          uint32_t freq)
{
    WEBRTC_TRACE(
        kTraceInfo,
        kTraceFile,
        _id,
        "ModuleFileUtility::InitPCMReading(pcm= 0x%x, start=%d, stop=%d,\
 freq=%d)",
        &pcm,
        start,
        stop,
        freq);

    int8_t dummy[320];
    int32_t read_len;

    _playoutPositionMs = 0;
    _startPointInMs = start;
    _stopPointInMs = stop;
    _reading = false;

    if(freq == 8000)
    {
        strcpy(codec_info_.plname, "L16");
        codec_info_.pltype   = -1;
        codec_info_.plfreq   = 8000;
        codec_info_.pacsize  = 160;
        codec_info_.channels = 1;
        codec_info_.rate     = 128000;
        _codecId = kCodecL16_8Khz;
    }
    else if(freq == 16000)
    {
        strcpy(codec_info_.plname, "L16");
        codec_info_.pltype   = -1;
        codec_info_.plfreq   = 16000;
        codec_info_.pacsize  = 320;
        codec_info_.channels = 1;
        codec_info_.rate     = 256000;
        _codecId = kCodecL16_16kHz;
    }
    else if(freq == 32000)
    {
        strcpy(codec_info_.plname, "L16");
        codec_info_.pltype   = -1;
        codec_info_.plfreq   = 32000;
        codec_info_.pacsize  = 320;
        codec_info_.channels = 1;
        codec_info_.rate     = 512000;
        _codecId = kCodecL16_32Khz;
    }

    // Readsize for 10ms of audio data (2 bytes per sample).
    _readSizeBytes = 2 * codec_info_. plfreq / 100;
    if(_startPointInMs > 0)
    {
        while (_playoutPositionMs < _startPointInMs)
        {
            read_len = pcm.Read(dummy, _readSizeBytes);
            if(read_len == _readSizeBytes)
            {
                _playoutPositionMs += 10;
            }
            else // Must have reached EOF before start position!
            {
                return -1;
            }
        }
    }
    _reading = true;
    return 0;
}

int32_t ModuleFileUtility::ReadPCMData(InStream& pcm,
                                       int8_t* outData,
                                       uint32_t bufferSize)
{
    WEBRTC_TRACE(
        kTraceStream,
        kTraceFile,
        _id,
        "ModuleFileUtility::ReadPCMData(pcm= 0x%x, outData= 0x%x, bufSize= %d)",
        &pcm,
        outData,
        bufferSize);

    if(outData == NULL)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,"buffer NULL");
    }

    // Readsize for 10ms of audio data (2 bytes per sample).
    uint32_t bytesRequested = 2 * codec_info_.plfreq / 100;
    if(bufferSize <  bytesRequested)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                   "ReadPCMData: buffer not long enough for a 10ms frame.");
        assert(false);
        return -1;
    }

    uint32_t bytesRead = pcm.Read(outData, bytesRequested);
    if(bytesRead < bytesRequested)
    {
        if(pcm.Rewind() == -1)
        {
            _reading = false;
        }
        else
        {
            if(InitPCMReading(pcm, _startPointInMs, _stopPointInMs,
                              codec_info_.plfreq) == -1)
            {
                _reading = false;
            }
            else
            {
                int32_t rest = bytesRequested - bytesRead;
                int32_t len = pcm.Read(&(outData[bytesRead]), rest);
                if(len == rest)
                {
                    bytesRead += len;
                }
                else
                {
                    _reading = false;
                }
            }
            if(bytesRead <= 0)
            {
                WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                        "ReadPCMData: Failed to rewind audio file.");
                return -1;
            }
        }
    }

    if(bytesRead <= 0)
    {
        WEBRTC_TRACE(kTraceStream, kTraceFile, _id,
                   "ReadPCMData: end of file");
        return -1;
    }
    _playoutPositionMs += 10;
    if(_stopPointInMs && _playoutPositionMs >= _stopPointInMs)
    {
        if(!pcm.Rewind())
        {
            if(InitPCMReading(pcm, _startPointInMs, _stopPointInMs,
                              codec_info_.plfreq) == -1)
            {
                _reading = false;
            }
        }
    }
    return bytesRead;
}

int32_t ModuleFileUtility::InitPCMWriting(OutStream& out, uint32_t freq)
{

    if(freq == 8000)
    {
        strcpy(codec_info_.plname, "L16");
        codec_info_.pltype   = -1;
        codec_info_.plfreq   = 8000;
        codec_info_.pacsize  = 160;
        codec_info_.channels = 1;
        codec_info_.rate     = 128000;

        _codecId = kCodecL16_8Khz;
    }
    else if(freq == 16000)
    {
        strcpy(codec_info_.plname, "L16");
        codec_info_.pltype   = -1;
        codec_info_.plfreq   = 16000;
        codec_info_.pacsize  = 320;
        codec_info_.channels = 1;
        codec_info_.rate     = 256000;

        _codecId = kCodecL16_16kHz;
    }
    else if(freq == 32000)
    {
        strcpy(codec_info_.plname, "L16");
        codec_info_.pltype   = -1;
        codec_info_.plfreq   = 32000;
        codec_info_.pacsize  = 320;
        codec_info_.channels = 1;
        codec_info_.rate     = 512000;

        _codecId = kCodecL16_32Khz;
    }
    if((_codecId != kCodecL16_8Khz) &&
       (_codecId != kCodecL16_16kHz) &&
       (_codecId != kCodecL16_32Khz))
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "CodecInst is not 8KHz PCM or 16KHz PCM!");
        return -1;
    }
    _writing = true;
    _bytesWritten = 0;
    return 0;
}

int32_t ModuleFileUtility::WritePCMData(OutStream& out,
                                        const int8_t*  buffer,
                                        const uint32_t dataLength)
{
    WEBRTC_TRACE(
        kTraceStream,
        kTraceFile,
        _id,
        "ModuleFileUtility::WritePCMData(out= 0x%x, buf= 0x%x, dataLen= %d)",
        &out,
        buffer,
        dataLength);

    if(buffer == NULL)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id, "buffer NULL");
    }

    if(!out.Write(buffer, dataLength))
    {
        return -1;
    }

    _bytesWritten += dataLength;
    return dataLength;
}

int32_t ModuleFileUtility::FileDurationMs(const char* fileName,
                                          const FileFormats fileFormat,
                                          const uint32_t freqInHz)
{

    if(fileName == NULL)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id, "filename NULL");
        return -1;
    }

    int32_t time_in_ms = -1;
    struct stat file_size;
    if(stat(fileName,&file_size) == -1)
    {
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "failed to retrieve file size with stat!");
        return -1;
    }
    FileWrapper* inStreamObj = FileWrapper::Create();
    if(inStreamObj == NULL)
    {
        WEBRTC_TRACE(kTraceMemory, kTraceFile, _id,
                     "failed to create InStream object!");
        return -1;
    }
    if(inStreamObj->OpenFile(fileName, true) == -1)
    {
        delete inStreamObj;
        WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                     "failed to open file %s!", fileName);
        return -1;
    }

    switch (fileFormat)
    {
        case kFileFormatWavFile:
        {
            if(ReadWavHeader(*inStreamObj) == -1)
            {
                WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                             "failed to read WAV file header!");
                return -1;
            }
            time_in_ms = ((file_size.st_size - 44) /
                          (_wavFormatObj.nAvgBytesPerSec/1000));
            break;
        }
        case kFileFormatPcm16kHzFile:
        {
            // 16 samples per ms. 2 bytes per sample.
            int32_t denominator = 16*2;
            time_in_ms = (file_size.st_size)/denominator;
            break;
        }
        case kFileFormatPcm8kHzFile:
        {
            // 8 samples per ms. 2 bytes per sample.
            int32_t denominator = 8*2;
            time_in_ms = (file_size.st_size)/denominator;
            break;
        }
        case kFileFormatCompressedFile:
        {
            int32_t cnt = 0;
            int32_t read_len = 0;
            char buf[64];
            do
            {
                read_len = inStreamObj->Read(&buf[cnt++], 1);
                if(read_len != 1)
                {
                    return -1;
                }
            } while ((buf[cnt-1] != '\n') && (64 > cnt));

            if(cnt == 64)
            {
                return -1;
            }
            else
            {
                buf[cnt] = 0;
            }
#ifdef WEBRTC_CODEC_AMR
            if(!strcmp("#!AMR\n", buf))
            {
                uint8_t dummy;
                read_len = inStreamObj->Read(&dummy, 1);
                if(read_len != 1)
                {
                    return -1;
                }

                int16_t AMRMode = (dummy>>3)&0xF;

                // TODO (hellner): use tables instead of hardcoding like this!
                //                 Additionally, this calculation does not
                //                 take octet alignment into consideration.
                switch (AMRMode)
                {
                        // Mode 0: 4.75 kbit/sec -> 95 bits per 20 ms frame.
                        // 20 ms = 95 bits ->
                        // file size in bytes * 8 / 95 is the number of
                        // 20 ms frames in the file ->
                        // time_in_ms = file size * 8 / 95 * 20
                    case 0:
                        time_in_ms = ((file_size.st_size)*160)/95;
                        break;
                        // Mode 1: 5.15 kbit/sec -> 103 bits per 20 ms frame.
                    case 1:
                        time_in_ms = ((file_size.st_size)*160)/103;
                        break;
                        // Mode 2: 5.90 kbit/sec -> 118 bits per 20 ms frame.
                    case 2:
                        time_in_ms = ((file_size.st_size)*160)/118;
                        break;
                        // Mode 3: 6.70 kbit/sec -> 134 bits per 20 ms frame.
                    case 3:
                        time_in_ms = ((file_size.st_size)*160)/134;
                        break;
                        // Mode 4: 7.40 kbit/sec -> 148 bits per 20 ms frame.
                    case 4:
                        time_in_ms = ((file_size.st_size)*160)/148;
                        break;
                        // Mode 5: 7.95 bit/sec -> 159 bits per 20 ms frame.
                    case 5:
                        time_in_ms = ((file_size.st_size)*160)/159;
                        break;
                        // Mode 6: 10.2 bit/sec -> 204 bits per 20 ms frame.
                    case 6:
                        time_in_ms = ((file_size.st_size)*160)/204;
                        break;
                        // Mode 7: 12.2 bit/sec -> 244 bits per 20 ms frame.
                    case 7:
                        time_in_ms = ((file_size.st_size)*160)/244;
                        break;
                        // Mode 8: SID Mode -> 39 bits per 20 ms frame.
                    case 8:
                        time_in_ms = ((file_size.st_size)*160)/39;
                        break;
                    default:
                        break;
                }
            }
#endif
#ifdef WEBRTC_CODEC_AMRWB
            if(!strcmp("#!AMRWB\n", buf))
            {
                uint8_t dummy;
                read_len = inStreamObj->Read(&dummy, 1);
                if(read_len != 1)
                {
                    return -1;
                }

                // TODO (hellner): use tables instead of hardcoding like this!
                int16_t AMRWBMode = (dummy>>3)&0xF;
                switch(AMRWBMode)
                {
                        // Mode 0: 6.6 kbit/sec -> 132 bits per 20 ms frame.
                    case 0:
                        time_in_ms = ((file_size.st_size)*160)/132;
                        break;
                        // Mode 1: 8.85 kbit/sec -> 177 bits per 20 ms frame.
                    case 1:
                        time_in_ms = ((file_size.st_size)*160)/177;
                        break;
                        // Mode 2: 12.65 kbit/sec -> 253 bits per 20 ms frame.
                    case 2:
                        time_in_ms = ((file_size.st_size)*160)/253;
                        break;
                        // Mode 3: 14.25 kbit/sec -> 285 bits per 20 ms frame.
                    case 3:
                        time_in_ms = ((file_size.st_size)*160)/285;
                        break;
                        // Mode 4: 15.85 kbit/sec -> 317 bits per 20 ms frame.
                    case 4:
                        time_in_ms = ((file_size.st_size)*160)/317;
                        break;
                        // Mode 5: 18.25 kbit/sec -> 365 bits per 20 ms frame.
                    case 5:
                        time_in_ms = ((file_size.st_size)*160)/365;
                        break;
                        // Mode 6: 19.85 kbit/sec -> 397 bits per 20 ms frame.
                    case 6:
                        time_in_ms = ((file_size.st_size)*160)/397;
                        break;
                        // Mode 7: 23.05 kbit/sec -> 461 bits per 20 ms frame.
                    case 7:
                        time_in_ms = ((file_size.st_size)*160)/461;
                        break;
                        // Mode 8: 23.85 kbit/sec -> 477 bits per 20 ms frame.
                    case 8:
                        time_in_ms = ((file_size.st_size)*160)/477;
                        break;
                    default:
                        delete inStreamObj;
                        return -1;
                }
            }
#endif
#ifdef WEBRTC_CODEC_ILBC
            if(!strcmp("#!iLBC20\n", buf))
            {
                // 20 ms is 304 bits
                time_in_ms = ((file_size.st_size)*160)/304;
                break;
            }
            if(!strcmp("#!iLBC30\n", buf))
            {
                // 30 ms takes 400 bits.
                // file size in bytes * 8 / 400 is the number of
                // 30 ms frames in the file ->
                // time_in_ms = file size * 8 / 400 * 30
                time_in_ms = ((file_size.st_size)*240)/400;
                break;
            }
#endif
        }
        case kFileFormatPreencodedFile:
        {
            WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                         "cannot determine duration of Pre-Encoded file!");
            break;
        }
        default:
            WEBRTC_TRACE(kTraceError, kTraceFile, _id,
                         "unsupported file format %d!", fileFormat);
            break;
    }
    inStreamObj->CloseFile();
    delete inStreamObj;
    return time_in_ms;
}

uint32_t ModuleFileUtility::PlayoutPositionMs()
{
    WEBRTC_TRACE(kTraceStream, kTraceFile, _id,
               "ModuleFileUtility::PlayoutPosition()");

    if(_reading)
    {
        return _playoutPositionMs;
    }
    else
    {
        return 0;
    }
}
}  // namespace webrtc
