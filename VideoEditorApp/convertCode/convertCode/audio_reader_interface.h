/*
 * audio_reader_interface.h
 *
 *  Created on: 2014年8月28日
 *      Author: 尚博才
 */

#ifndef AUDIO_READER_INTERFACE_H_
#define AUDIO_READER_INTERFACE_H_


#include "audio_utils.h"


struct AVFormatContext;
struct AVCodecContext;
struct AVFrame;

//先InitInputFile然后GetBufferSize得到解码帧字节数
//GetFrame传入的数据大小等于GetBufferSize的值
//调用GetFrame取数据sample_count为数据大小，最后一帧可能比较小，is_finished为1后结束
class AudioReaderInterface {
public:
    enum {
        kNoError = 0,
        kCannotOpenInputFile = -1,
        kNotFindStream = -2,
        kNotFindCodec = -3,
        kCannotOpenCodec = -4,
        kNotFindAudioStream = -5,
        kFileEnd = -6,
        kDecodeFrameError = -7,
        kAvframeMallocError = -8,
        kDatabufferError    = -9,
        kReadFrameError      = -10,
    };

    virtual ~AudioReaderInterface(){}

    //初始化打开文件
    virtual int InitInputFile(const char* file_name)=0;

    //取解码后的音频数据。返回负数，is_finished设置为1表示文件结束，is_finished为0时有错误
    virtual int GetFrame(short* data, int& sample_count, int &is_finished)=0;

    //关闭文件
    virtual int CloseInputFile()=0;
    //一帧的数据大小
    virtual int GetBufferSize() =0;
    //采样率
    virtual int sample_rate() =0;
    //声道样式
    virtual FAudioChannelLayout channel_layout() =0;
    //采样样式
    virtual FSampleFormat sample_format() =0;
    //声道数
    virtual int channel_count() =0;
    //比特率
    virtual int bit_rate() =0;

};


#endif /* AUDIO_READER_INTERFACE_H_ */
