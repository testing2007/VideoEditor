/*
 * audio_convert.h
 *
 *  Created on: 2014年7月24日
 *      Author: 尚博才
 */

#ifndef AUDIO_CONVERT_H_
#define AUDIO_CONVERT_H_

#include <base/f_audio_types.h>

#include "audio_reader_interface.h"
#include "audio_recorder_interface.h"


//FIXME 不是线程安全的
class AudioConvert{
public:
    const static int kNoError             = 0;
    const static int kAllocMemoryError    = -1;

    AudioConvert(char* libname);
    ~AudioConvert();

    //添加音效，在init之前调用
    void AddAudioEffect(AudioEffect effect);
    //设置输出音频PCM格式
    void SetOutPutAudioFormat(int sample_rate, FAudioChannelLayout channel_layout,
		   FSampleFormat sample_format, int channel_count, int bit_rate);
    //初始化，打开文件、编解码器、[音效]等
    int Init(const char* in, const char* out);
    //转换，直到文件处理结束
    int Convert();

private:

AudioReaderInterface    *reader_;
AudioRecorderIntreface   *recorder_;

//解码得到的声音数据
unsigned char* audio_frame_buffer_;
//用于planar格式，每个声道数据分开，记录每个声道数据在audio_frame_buffer_的地址
unsigned char** encode_frame_buffer_;

//volatile bool is_stopped;

const static AudioEncoderName kEncoder = kEncodeVoAacenc;
};



#endif // AUDIO_CONVERT_H_ 
