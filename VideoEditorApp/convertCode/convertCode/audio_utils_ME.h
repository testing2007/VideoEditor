/*
 * audio_utils.h
 *
 *  Created on: 2014ƒÍ7‘¬16»’
 *      Author: …–≤©≤≈
 */

#ifndef AUDIO_UTILS_H_
#define AUDIO_UTILS_H_

//#ifdef ANDROID
//#include <android/log.h>
//#endif

#include "f_audio_types.h"
#include <stdio.h>
//namespace FVideo
//{

#define F_AUDIO_LOG_LEVEL_VERBOSE   1
#define F_AUDIO_LOG_LEVEL_DEBUG     2
#define F_AUDIO_LOG_LEVEL_INFO      3
#define F_AUDIO_LOG_LEVEL_WARNING   4
#define F_AUDIO_LOG_LEVEL_ERROR     5
#define F_AUDIO_LOG_LEVEL_FATAL     6
#define F_AUDIO_LOG_LEVEL_SILENT    7

#ifndef F_AUDIO_LOG_TAG
#   define F_AUDIO_LOG_TAG __FILE__
#endif

#ifndef F_AUDIO_LOG_LEVEL
#    define F_AUDIO_LOG_LEVEL F_AUDIO_LOG_LEVEL_VERBOSE
#endif

#define F_AUDIO_LOG_NOOP (void) 0

//#   define F_AUDIO_LOG_ASSERT(expression, fmt, ...) ;
//#define F_AUDIO_LOG_VERBOSE
//#define
#ifdef ANDROID //BEGIN

//#define F_AUDIO_LOG_PRINT(level, fmt, ...) \
//        __android_log_print(level, F_AUDIO_LOG_TAG, "(%s:%u) %s: " fmt, \
//                __FILE__, __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__)
//
//#if F_AUDIO_LOG_LEVEL_VERBOSE >= F_AUDIO_LOG_LEVEL
//#   define F_AUDIO_LOG_VERBOSE(fmt, ...) \
//    F_AUDIO_LOG_PRINT(ANDROID_LOG_VERBOSE, fmt, ##__VA_ARGS__)
//#else
//#   define F_AUDIO_LOG_VERBOSE(...) F_AUDIO_LOG_NOOP
//#endif
//
//#if F_AUDIO_LOG_LEVEL_DEBUG >= F_AUDIO_LOG_LEVEL
//#   define F_AUDIO_LOG_DEBUG(fmt, ...) \
//    F_AUDIO_LOG_PRINT(ANDROID_LOG_DEBUG, fmt, ##__VA_ARGS__)
//#else
//#   define F_AUDIO_LOG_DEBUG(...) F_AUDIO_LOG_NOOP
//#endif
//
//#if F_AUDIO_LOG_LEVEL_INFO >= F_AUDIO_LOG_LEVEL
//#   define F_AUDIO_LOG_INFO(fmt, ...) \
//    F_AUDIO_LOG_PRINT(ANDROID_LOG_INFO, fmt, ##__VA_ARGS__)
//#else
//#   define F_AUDIO_LOG_INFO(...) F_AUDIO_LOG_NOOP
//#endif
//
//#if F_AUDIO_LOG_LEVEL_WARNING >= F_AUDIO_LOG_LEVEL
//#   define F_AUDIO_LOG_WARNING(fmt, ...) \
//    F_AUDIO_LOG_PRINT(ANDROID_LOG_WARN, fmt, ##__VA_ARGS__)
//#else
//#   define F_AUDIO_LOG_WARNING(...) F_AUDIO_LOG_NOOP
//#endif
//
//#if F_AUDIO_LOG_LEVEL_ERROR >= F_AUDIO_LOG_LEVEL
//#   define F_AUDIO_LOG_ERROR(fmt, ...) \
//    F_AUDIO_LOG_PRINT(ANDROID_LOG_ERROR, fmt, ##__VA_ARGS__)
//#else
//#   define F_AUDIO_LOG_ERROR(...) F_AUDIO_LOG_NOOP
//#endif
//
//#if F_AUDIO_LOG_LEVEL_FATAL >= F_AUDIO_LOG_LEVEL
//#   define F_AUDIO_LOG_FATAL(fmt, ...) \
//    F_AUDIO_LOG_PRINT(ANDROID_LOG_FATAL, fmt, ##__VA_ARGS__)
//#else
//#   define F_AUDIO_LOG_FATAL(...) F_AUDIO_LOG_NOOP
//#endif
//
//#if F_AUDIO_LOG_LEVEL_SILENT >= F_AUDIO_LOG_LEVEL
//#   define F_AUDIO_LOG_SILENT(fmt, ...) \
//    F_AUDIO_LOG_PRINT(ANDROID_LOG_SILENT, fmt, ##__VA_ARGS__)
//#else
//#   define F_AUDIO_LOG_SILENT(...) F_AUDIO_LOG_NOOP
//#endif
//
//#if F_AUDIO_LOG_LEVEL_SILENT >= F_AUDIO_LOG_LEVEL
//#   define F_AUDIO_LOG_ASSERT(expression, fmt, ...) \
//        if (!(expression)) \
//        { \
//           __android_log_assert(#expression, F_AUDIO_LOG_TAG, \
//                  "(%s:%u) %s: " fmt,  __FILE__, __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__); \
//        }
//#else
//#   define F_AUDIO_LOG_ASSERT(...) F_AUDIO_LOG_NOOP
//#endif

#else

#define F_AUDIO_LOG_PRINT(fmt, ...) \
{
char* strOutputFormat = new char[1024];
memset(strOutputFormat, 0, 1024);
strcat(strOutputFormat,  __FILE__);
printf(fmt, ##__VA_ARGS__);
}
#   define F_AUDIO_LOG_VERBOSE(fmt, ...) \
F_AUDIO_LOG_PRINT(fmt, ##__VA_ARGS__)

#   define F_AUDIO_LOG_DEBUG(fmt, ...) \
F_AUDIO_LOG_PRINT(fmt, ##__VA_ARGS__)

#   define F_AUDIO_LOG_INFO(fmt, ...) \
F_AUDIO_LOG_PRINT(fmt, ##__VA_ARGS__)

#   define F_AUDIO_LOG_WARNING(fmt, ...) \
F_AUDIO_LOG_PRINT(fmt, ##__VA_ARGS__)

#   define F_AUDIO_LOG_ERROR(fmt, ...) \
F_AUDIO_LOG_PRINT(fmt, ##__VA_ARGS__)

#   define F_AUDIO_LOG_FATAL(fmt, ...) \
F_AUDIO_LOG_PRINT(fmt, ##__VA_ARGS__)

#   define F_AUDIO_LOG_SILENT(fmt, ...) \
F_AUDIO_LOG_PRINT(fmt, ##__VA_ARGS__)

#   define F_AUDIO_LOG_ASSERT(expression, fmt, ...) \
F_AUDIO_LOG_PRINT(fmt, ##__VA_ARGS__)

#endif


#ifndef INT64_C
#define INT64_C(c) (c##LL)
#define UINT64_C(c) (c##ULL)
#endif


class AudioUtil{
public:
    //AudioEncoderName◊™◊÷∑˚¥Æ£¨±‡¬Î∆˜√˚≥∆
    //codec_name  ‰»Î≤Œ ˝
    //string  ‰≥ˆ≤Œ ˝
    static void AudioEncoderName2String(const AudioEncoderName codec_name, char* string);

    static int FSampleFormat2libav(FSampleFormat sample_format);

    static long long AudioChannelLayout2libav(IOS_AudioChannelLayout audio_channel_layout);

    static FSampleFormat libav2FSampleFormat(int sample_format);

    static IOS_AudioChannelLayout libav2AudioChannelLayout(long long audio_channel_layout);
};

//}//namespace


#endif // AUDIO_UTILS_H_ 
