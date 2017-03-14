/*
 * audio_recoder_wav.h
 *
 *  Created on: 2014年8月28日
 *      Author: 尚博才
 */

#ifndef AUDIO_RECODER_WAV_H_
#define AUDIO_RECODER_WAV_H_

#include <stdio.h>

#include "audio_recorder_interface.h"
#include "audio_denoise_interface.h"
#include "audio_effect_interface.h"

class AudioSampleFifo;

//FIXME 只支持单声道、16位采样
//用法：先SetInputAudioFormat，可选[SetOutPutAudioFormat，SetAudioDenoise，SetAudioEffect]，
//     然后InitAudioFile，EncodeAudioFrame，CloseAudioFile
class AudioRecorderWav : public AudioRecorderIntreface {

public:
	AudioRecorderWav();
    ~AudioRecorderWav();

    //设置输入音频PCM格式
    void SetInputAudioFormat(int sample_rate, FAudioChannelLayout channel_layout,
            FSampleFormat sample_format, int channel_count, int bit_rate);
    //设置输出音频PCM格式，
    // FIXME 无效，为了简单，不实现音频重采样，所以不能转格式
    void SetOutPutAudioFormat(int sample_rate, FAudioChannelLayout channel_layout,
            FSampleFormat sample_format, int channel_count, int bit_rate);
    //开启降噪
    void SetAudioDenoise();
    //添加音效
    void SetAudioEffect(AudioEffect audio_effect);

    //初始化，创建文件，初始化编码器
    int InitAudioFile(AudioEncoderName codec_name, const char* filename);

    //输入音频数据，编码写入文件，注意planar时data是指针数组(例：char*[4])
    int EncodeAudioFrame(unsigned char **data, int sample_count);

    //关闭文件，结束
    int CloseAudioFile();

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

    struct AudioFormat {
        int sample_rate;
        FAudioChannelLayout channel_layout;
        FSampleFormat sample_format;
        int channel_count;
        int bit_rate;
    } input_format_, output_format_;

    void InitWaveHeader(WaveHeader& wh);
    int GetBytesCountPerSample(FSampleFormat sf);

    int AddFrameToBuffer(unsigned char **data, const int sample_count);
    int GetFrameFromBuffer(unsigned char **data, int& sample_count);

    int Encode(int sample_count);

    int InitFrame();
    int InitAudioFifo();
    void InitAudioDenoise();
    void InitAudioEffect();
    int Denoise();

    AudioDenoiseInterface * audio_denoise_;
    AudioEffectInterface * audio_effect_;

    AudioEffect audio_effect_name_;
    FILE * wav_file_;

    WaveHeader wav_header_;

    AudioSampleFifo* audio_fifo_;
    // 每次处理采样数，20毫秒数据量
    int frame_size_;
    // 从fifo取出的数据
    short *frame_buffer_;
};



#endif /* AUDIO_RECODER_WAV_H_ */
