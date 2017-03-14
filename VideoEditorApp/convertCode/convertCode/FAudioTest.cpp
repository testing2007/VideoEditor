#include <jni.h>

#include "audio_recorder.h"
#include "audio_reader.h"
#include "audio_convert.h"

void init() {
//AudioRecoder *recoder = new AudioRecoder();
//recoder->SetInputAudioFormat(44100, kMono, kSampleFmtS16, 1, 0);
//recoder->SetOutPutAudioFormat(44100, kStereo, kSampleFmtS16, 2, 128000);
//recoder->SetAudioEffect(kMale);
//recoder->SetAudioDenoise();
//
//recoder->InitAudioFile(kEncodeVoAacenc, "/sdcard/mytest/rtest.mp4");
//
//
//AudioReader *reader = new AudioReader();
//reader->InitInputFile("/sdcard/mytest/a012345.mp4");

    AudioConvert *ac = new AudioConvert("libav");

    ac->Init("/sdcard/mytest/a012345.mp4", "/sdcard/mytest/rtest.mp4");
    //, 44100, kStereo,   kSampleFmtS16, 2, 64000);
    ac->Convert();
}
