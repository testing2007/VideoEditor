/*
 * audio_recoder_interface.h
 *
 *  Created on: 2014年8月28日
 *      Author: Administrator
 */

#ifndef AUDIO_RECODER_INTERFACE_H_
#define AUDIO_RECODER_INTERFACE_H_

#include <base/f_audio_types.h>

//FIXME 降噪只支持单声道(输入数据)；音效只支持16位采样(输出数据)
//用法：先SetInputAudioFormat，可选[SetOutPutAudioFormat，SetAudioDenoise，SetAudioEffect]，
//     然后InitAudioFile，EncodeAudioFrame，CloseAudioFile
class AudioRecorderIntreface {

public:
    enum {
        kNoError = 0,
        kCannotOpenOutputFile = -1,
        KAllocAvformatError = -2,
        kNotSupportFormatOfOutputFile = -3,
        kNotFoundEncoder = -4,
        kAllocStreamError = -5,
        kCannotOpenCodec = -6,
        kWriteFileHeaderError = -7,
        kFrameAllocError = -8,
        kAvframeGetbufferError = -9,
        kAudioEncodeError = -10,
        kWriteFrameError = -11,
        kFillFrameError = -12,
        kWriteFileTrailerError = -13,
        kFifoAllocError = -14,
        kCannotReallocateFifo = -15,
        kCannotWriteFifo = -16,
        kCannotReadFifo = -17,

    };

public:
    virtual ~AudioRecorderIntreface(){}

    //设置输入音频PCM格式
    virtual void SetInputAudioFormat(int sample_rate, FAudioChannelLayout channel_layout,
            FSampleFormat sample_format, int channel_count, int bit_rate)=0;
    //设置输出音频PCM格式
    virtual void SetOutPutAudioFormat(int sample_rate, FAudioChannelLayout channel_layout,
            FSampleFormat sample_format, int channel_count, int bit_rate)=0;
    //开启降噪
    virtual void SetAudioDenoise()=0;
    //添加音效
    virtual void SetAudioEffect(AudioEffect audio_effect)=0;

    //初始化，创建文件，初始化编码器
    virtual int InitAudioFile(AudioEncoderName codec_name, const char* filename)=0;

    //输入音频数据，编码写入文件，注意planar时data是指针数组(例：char*[4])
    virtual int EncodeAudioFrame(unsigned char **data, int sample_count)=0;

    //关闭文件，结束
    virtual int CloseAudioFile()=0;
};



#endif /* AUDIO_RECODER_INTERFACE_H_ */
