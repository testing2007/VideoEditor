/*
 * audio_reader_wav.h
 *
 *  Created on: 2014年8月28日
 *      Author: 尚博才
 */

#ifndef AUDIO_READER_WAV_H_
#define AUDIO_READER_WAV_H_

#include <stdio.h>
#include "audio_utils.h"
#include "audio_reader_interface.h"

//先InitInputFile然后GetBufferSize得到解码帧字节数
//GetFrame传入的数据大小等于GetBufferSize的值
//调用GetFrame取数据sample_count为数据大小，最后一帧可能比较小，is_finished为1后结束
class AudioReaderWav : public AudioReaderInterface {
private:
	static const int kMaxAudioBufferSize = 2048*8*2; //最大每帧2048样，double类型2声道。针对有的格式解码没有帧大小
public:

	AudioReaderWav();
    ~AudioReaderWav();

    //初始化打开文件
    int InitInputFile(const char* file_name);

    //取解码后的音频数据。返回负数，并且：is_finished设置为1表示文件结束，is_finished为0时有错误
    int GetFrame(short* data, int& sample_count, int &is_finished);

    //关闭文件
    int CloseInputFile();
    //一帧的数据大小
    int GetBufferSize() {
        return buffer_size_;
    }
    //采样率
    int sample_rate() {
        return wav_header_.samples_persecond;
    }
    //声道样式
    FAudioChannelLayout channel_layout() {
    	if(wav_header_.channels_count == 1)
    		return kMono;
    	else
    		return kStereo;
    }
    //采样样式
    FSampleFormat sample_format() {
    	if(wav_header_.bits_persample == 16)
    		return kSampleFmtS16;
    	else
    		return kSampleFmtU8;
    }
    //声道数
    int channel_count() {
        return wav_header_.channels_count;
    }
    //比特率
    int bit_rate() {
        return wav_header_.bytes_persecond * 8;
    }

private:
    typedef struct{
		char riff_fileid[4];//"RIFF"
		unsigned int riff_file_length;
		char waveid[4];//"WAVE"

		char fmt_chkid[4];//"fmt"
		unsigned int     fmt_chk_length;

		unsigned short    format_tag;        /* format type */
		unsigned short    channels_count;         /* number of channels (i.e. mono, stereo, etc.) */
		unsigned int  	  samples_persecond;    /* sample rate */
		unsigned int  	  bytes_persecond;   /* for buffer estimation */
		unsigned short    block_align;       /* block size of data */
		unsigned short    bits_persample;

		char data_chkid[4];//"DATA"
		unsigned int data_chkLen;
	}WaveHeader;


#if !defined(__LITTLE_ENDIAN__) && ( defined(WORDS_BIGENDIAN) || defined(__BIG_ENDIAN__) )
#define le_short(s) ((short) ((unsigned short) (s) << 8) | ((unsigned short) (s) >> 8))
#define be_short(s) ((short) (s))
#else
#define le_short(s) ((short) (s))
#define be_short(s) ((short) ((unsigned short) (s) << 8) | ((unsigned short) (s) >> 8))
#endif

/** Convert little endian */
static inline int le_int(int i)
{
#if !defined(__LITTLE_ENDIAN__) && ( defined(WORDS_BIGENDIAN) || defined(__BIG_ENDIAN__) )
	unsigned int ui, ret;
   ui = i;
   ret =  ui>>24;
   ret |= (ui>>8)&0x0000ff00;
   ret |= (ui<<8)&0x00ff0000;
   ret |= (ui<<24);
   return ret;
#else
   return i;
#endif
}


    int OpenInputAudioFile(const char* filename);

    int DecodeAudioFrame(void* data, int *datapresent, int *finished);

    int sample_rate_;
    FAudioChannelLayout channel_layout_;
    FSampleFormat sample_format_;
    int channel_count_;
    int bit_rate_;

    int buffer_size_;

    FILE* wav_file_;
    int frame_size_;
    WaveHeader wav_header_;

};




#endif /* AUDIO_READER_WAV_H_ */
