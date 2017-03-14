/*
 * audio_utils.cpp
 *
 *  Created on: 2014年7月17日
 *      Author: 尚博才
 */

#include "audio_utils.h"

#include <string.h>

#ifndef __CANNOT_USE_LIBAV__

extern "C"{
#include "libavutil/channel_layout.h"
#include "libavutil/samplefmt.h"
}

#endif //__CANNOT_USE_LIBAV__

void AudioUtil::AudioEncoderName2String(const AudioEncoderName codec_name, char* string) {
    F_AUDIO_LOG_ASSERT(string != NULL,
            "codec name need 20 chars at least.");
    switch (codec_name) {
    case kEncodeVoAacenc:
        strcpy(string, "libvo_aacenc");
        break;
    case kEncodeSpeex:
        strcpy(string, "libspeex");
        break;
    case kEncodeAmrNb:
        strcpy(string, "libopencore_amrnb");
        break;
    default:
        strcpy(string, "");
        break;
    }
}
#ifndef __CANNOT_USE_LIBAV__

int AudioUtil::FSampleFormat2libav(FSampleFormat sample_format){
    switch (sample_format) {
    case kSampleFmtU8:
        return AV_SAMPLE_FMT_U8;
    case kSampleFmtS16:
        return AV_SAMPLE_FMT_S16;
    case kSampleFmtS32:
        return AV_SAMPLE_FMT_S32;
    case kSampleFmtFlt:
        return AV_SAMPLE_FMT_FLT;
    case kSampleFmtDbl:
        return AV_SAMPLE_FMT_DBL;
    case kSampleFmtU8p:
        return AV_SAMPLE_FMT_U8P;
    case kSampleFmtS16p:
        return AV_SAMPLE_FMT_S16P;
    case kSampleFmtS32p:
        return AV_SAMPLE_FMT_S32P;
    case kSampleFmtFltp:
        return AV_SAMPLE_FMT_FLTP;
    case kSampleFmtDblp:
        return AV_SAMPLE_FMT_DBLP;
    }

    F_AUDIO_LOG_ASSERT(false, "no support sample format %d", sample_format);
    return AV_SAMPLE_FMT_S16;
}

long long AudioUtil::AudioChannelLayout2libav(FAudioChannelLayout audio_channel_layout){
    switch (audio_channel_layout) {
    case kMono:
        return AV_CH_LAYOUT_MONO;
    case kStereo:
        return AV_CH_LAYOUT_STEREO;
    }
    F_AUDIO_LOG_ASSERT(false, "no support channel layout %d", audio_channel_layout);
    return AV_CH_LAYOUT_MONO;
}

FSampleFormat AudioUtil::libav2FSampleFormat(int sample_format){
    switch (sample_format) {
      case AV_SAMPLE_FMT_U8:
          return kSampleFmtU8;
      case AV_SAMPLE_FMT_S16:
          return kSampleFmtS16;
      case AV_SAMPLE_FMT_S32:
          return kSampleFmtS32;
      case AV_SAMPLE_FMT_FLT:
          return kSampleFmtFlt;
      case AV_SAMPLE_FMT_DBL:
          return kSampleFmtDbl;
      case AV_SAMPLE_FMT_U8P:
          return kSampleFmtU8p;
      case AV_SAMPLE_FMT_S16P:
          return kSampleFmtS16p;
      case AV_SAMPLE_FMT_S32P:
          return kSampleFmtS32p;
      case AV_SAMPLE_FMT_FLTP:
          return kSampleFmtFltp;
      case AV_SAMPLE_FMT_DBLP:
          return kSampleFmtDblp;
      }
    F_AUDIO_LOG_ASSERT(false, "no support sample format %d", sample_format);
    return kSampleFmtS16;
}

FAudioChannelLayout AudioUtil::libav2AudioChannelLayout(long long audio_channel_layout){
    switch (audio_channel_layout) {
    case AV_CH_LAYOUT_MONO:
        return kMono;
    case AV_CH_LAYOUT_STEREO:
        return kStereo;
    }
    F_AUDIO_LOG_ASSERT(false, "no support channel layout %lld", audio_channel_layout);
    return kMono;
}
#endif //__CANNOT_USE_LIBAV__
