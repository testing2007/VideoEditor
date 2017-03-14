/*
 * f_audio_types.h
 *
 *  Created on: 2014年7月16日
 *      Author: 尚博才
 */

#ifndef F_AUDIO_TYPES_H_
#define F_AUDIO_TYPES_H_

//TODO 音频处理通用的结构体定义，需要时添加

//音频帧，PCM
struct FAudioFrame{
    void *data;                 //音频帧数据
    unsigned sample_count;      //采样数
};

//音频包，编码后
struct FAudioPacket{
    void *data;                 //音频编码数据
    unsigned size;              //数据长度
    int stream_index;           //所属音频流
    long long pts;                //显示时间戳
    long long dts;                //解码时间戳
};

//有理数，用于表示时基
struct FRational{
    int num; //分子
    int den; //分母
};

//支持的音频编码器
enum AudioEncoderName{
    kEncodeNone = -1,
    kEncodeVoAacenc   = 0,
    kEncodeSpeex      = 1,
    kEncodeAmrNb      = 2
};

//支持的音频解码器
enum AudioDecoderName{
    kDecodeAAC,
    kDecodeSpeex,
    kDecodeAmrNb
};

//音频声道格式
enum FAudioChannelLayout{
    kMono      = 0,
    kStereo    = 1
};

//采样格式
enum FSampleFormat{
    kSampleFmtU8        = 0,         // unsigned 8 bits
    kSampleFmtS16       = 1,         // signed 16 bits
    kSampleFmtS32       = 2,         // signed 32 bits
    kSampleFmtFlt       = 3,         // float
    kSampleFmtDbl       = 4,         // double

    kSampleFmtU8p       = 5,        // unsigned 8 bits, planar
    kSampleFmtS16p      = 6,        // signed 16 bits, planar
    kSampleFmtS32p      = 7,        // signed 32 bits, planar
    kSampleFmtFltp      = 8,        // float, planar
    kSampleFmtDblp      = 9         // double, planar
};

enum AudioEffect{
    kMale               = 0,
    kFemale             = 1,
    kLabixiaoxin        = 2
};

#endif // F_AUDIO_TYPES_H_ 
