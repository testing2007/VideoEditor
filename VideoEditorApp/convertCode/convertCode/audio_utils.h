/*
 * audio_utils.h
 *
 *  Created on: 2014年7月16日
 *      Author: 尚博才
 */

#ifndef AUDIO_UTILS_H_
#define AUDIO_UTILS_H_

#ifdef __ANDROID__
#include <android/log.h>
#else
#include <stdio.h>
#include <assert.h>
#endif

#include <base/f_audio_types.h>

//日志级别默认从1开始，与安卓的枚举类型值可能不对应
//通过自定义F_AUDIO_LOG_LEVEL_VERBOSE可以调整
#ifndef F_AUDIO_LOG_LEVEL_VERBOSE
#define F_AUDIO_LOG_LEVEL_VERBOSE 2
#endif

#define F_AUDIO_LOG_LEVEL_DEBUG     (F_AUDIO_LOG_LEVEL_VERBOSE + 1)
#define F_AUDIO_LOG_LEVEL_INFO      (F_AUDIO_LOG_LEVEL_VERBOSE + 2)
#define F_AUDIO_LOG_LEVEL_WARNING   (F_AUDIO_LOG_LEVEL_VERBOSE + 3)
#define F_AUDIO_LOG_LEVEL_ERROR     (F_AUDIO_LOG_LEVEL_VERBOSE + 4)
#define F_AUDIO_LOG_LEVEL_FATAL     (F_AUDIO_LOG_LEVEL_VERBOSE + 5)
#define F_AUDIO_LOG_LEVEL_SILENT    (F_AUDIO_LOG_LEVEL_VERBOSE + 6)


#ifndef F_AUDIO_LOG_TAG
#   define F_AUDIO_LOG_TAG __FILE__
#endif

#ifndef F_AUDIO_LOG_LEVEL
#    define F_AUDIO_LOG_LEVEL F_AUDIO_LOG_LEVEL_VERBOSE
#endif

#define F_AUDIO_LOG_NOOP (void) 0

#ifdef __ANDROID__ //安卓log输出到logcat
#   define F_AUDIO_LOG_PRINT(level, fmt, ...) \
        __android_log_print(level, F_AUDIO_LOG_TAG, "(%s:%u) %s: " fmt, \
                __FILE__, __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__)
#else // 其他默认输出到控制台
#   define F_AUDIO_LOG_PRINT(level, fmt, ...) \
        printf("[level %d](%s:%u) %s: " fmt "\n", \
                level, __FILE__, __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__)
#endif



#if F_AUDIO_LOG_LEVEL_VERBOSE >= F_AUDIO_LOG_LEVEL
#   define F_AUDIO_LOG_VERBOSE(fmt, ...) \
    F_AUDIO_LOG_PRINT(F_AUDIO_LOG_LEVEL_VERBOSE, fmt, ##__VA_ARGS__)
#else
#   define F_AUDIO_LOG_VERBOSE(...) F_AUDIO_LOG_NOOP
#endif

#if F_AUDIO_LOG_LEVEL_DEBUG >= F_AUDIO_LOG_LEVEL
#   define F_AUDIO_LOG_DEBUG(fmt, ...) \
    F_AUDIO_LOG_PRINT(F_AUDIO_LOG_LEVEL_DEBUG, fmt, ##__VA_ARGS__)
#else
#   define F_AUDIO_LOG_DEBUG(...) F_AUDIO_LOG_NOOP
#endif

#if F_AUDIO_LOG_LEVEL_INFO >= F_AUDIO_LOG_LEVEL
#   define F_AUDIO_LOG_INFO(fmt, ...) \
    F_AUDIO_LOG_PRINT(F_AUDIO_LOG_LEVEL_INFO, fmt, ##__VA_ARGS__)
#else
#   define F_AUDIO_LOG_INFO(...) F_AUDIO_LOG_NOOP
#endif

#if F_AUDIO_LOG_LEVEL_WARNING >= F_AUDIO_LOG_LEVEL
#   define F_AUDIO_LOG_WARNING(fmt, ...) \
    F_AUDIO_LOG_PRINT(F_AUDIO_LOG_LEVEL_WARNING, fmt, ##__VA_ARGS__)
#else
#   define F_AUDIO_LOG_WARNING(...) F_AUDIO_LOG_NOOP
#endif

#if F_AUDIO_LOG_LEVEL_ERROR >= F_AUDIO_LOG_LEVEL
#   define F_AUDIO_LOG_ERROR(fmt, ...) \
    F_AUDIO_LOG_PRINT(F_AUDIO_LOG_LEVEL_ERROR, fmt, ##__VA_ARGS__)
#else
#   define F_AUDIO_LOG_ERROR(...) F_AUDIO_LOG_NOOP
#endif

#if F_AUDIO_LOG_LEVEL_FATAL >= F_AUDIO_LOG_LEVEL
#   define F_AUDIO_LOG_FATAL(fmt, ...) \
    F_AUDIO_LOG_PRINT(F_AUDIO_LOG_LEVEL_FATAL, fmt, ##__VA_ARGS__)
#else
#   define F_AUDIO_LOG_FATAL(...) F_AUDIO_LOG_NOOP
#endif

#if F_AUDIO_LOG_LEVEL_SILENT >= F_AUDIO_LOG_LEVEL
#   define F_AUDIO_LOG_SILENT(fmt, ...) \
    F_AUDIO_LOG_PRINT(F_AUDIO_LOG_LEVEL_SILENT, fmt, ##__VA_ARGS__)
#else
#   define F_AUDIO_LOG_SILENT(...) F_AUDIO_LOG_NOOP
#endif

#if F_AUDIO_LOG_LEVEL_SILENT >= F_AUDIO_LOG_LEVEL
#   ifdef __ANDROID__
#      define F_AUDIO_LOG_ASSERT(expression, fmt, ...) \
            if (!(expression)) \
            { \
               __android_log_assert(#expression, F_AUDIO_LOG_TAG, \
                      "(%s:%u) %s: " fmt,  __FILE__, __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__); \
            }
#   else
#       define  F_AUDIO_LOG_ASSERT(expression, fmt, ...) \
            if (!(expression)) \
            { \
               printf("[level %d](%s:%u) %s: " fmt "\n", \
               F_AUDIO_LOG_LEVEL_SILENT, __FILE__, __LINE__, __PRETTY_FUNCTION__, ##__VA_ARGS__); \
               assert(#expression); \
            }
#   endif
#else
#   define F_AUDIO_LOG_ASSERT(...) F_AUDIO_LOG_NOOP
#endif



#ifndef INT64_C
#define INT64_C(c) (c##LL)
#define UINT64_C(c) (c##ULL)
#endif


class AudioUtil{
public:
    //AudioEncoderName转字符串，编码器名称
    //codec_name 输入参数
    //string 输出参数
    static void AudioEncoderName2String(const AudioEncoderName codec_name, char* string);

#ifndef __CANNOT_USE_LIBAV__
    static int FSampleFormat2libav(FSampleFormat sample_format);

    static long long AudioChannelLayout2libav(FAudioChannelLayout audio_channel_layout);

    static FSampleFormat libav2FSampleFormat(int sample_format);

    static FAudioChannelLayout libav2AudioChannelLayout(long long audio_channel_layout);
#endif //__CANNOT_USE_LIBAV__
};



#endif // AUDIO_UTILS_H_ 
