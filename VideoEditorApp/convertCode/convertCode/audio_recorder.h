/*
 * audio_recorder.h
 *
 *  Created on: 2014年7月17日
 *      Author: 尚博才
 */

#ifndef AUDIO_RECODER_H_
#define AUDIO_RECODER_H_

#ifndef __CANNOT_USE_LIBAV__

#include "audio_recorder_interface.h"
#include "audio_resample_interface.h"
#include "audio_denoise_interface.h"
#include "audio_effect_interface.h"

struct AVFormatContext;
struct AVCodecContext;
struct AVFrame;
struct AVAudioFifo;

//FIXME 降噪只支持单声道(输入数据)；音效只支持16位采样(输出数据)
//用法：先SetInputAudioFormat，可选[SetOutPutAudioFormat，SetAudioDenoise，SetAudioEffect]，
//     然后InitAudioFile，EncodeAudioFrame，CloseAudioFile
class AudioRecorder : public AudioRecorderIntreface,public AudioResampleCallbackIntreface {

public:
    AudioRecorder();
    ~AudioRecorder();

    //设置输入音频PCM格式
    void SetInputAudioFormat(int sample_rate, FAudioChannelLayout channel_layout,
            FSampleFormat sample_format, int channel_count, int bit_rate);
    //设置输出音频PCM格式
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

    //实现接口的方法，声音重采样回调
    int AudioResampleCallback();

private:
    struct AudioFormat {
        int sample_rate;
        FAudioChannelLayout channel_layout;
        FSampleFormat sample_format;
        int channel_count;
        int bit_rate;
    } input_format_, output_format_;

    int OpenOutputAudioFile(AudioEncoderName codec_name, const char *filename,
            AVFormatContext **fmt_ctx, AVCodecContext **codec_ctx);

    int InitAvframe();
    int InitAudioFifo();

    int AddFrameToBuffer(unsigned char **data, const int sample_count);
    int GetFrameFromBuffer(unsigned char **data, int& sample_count);
    //  int GetFifoFrameDataSize();

    int Resample();

    int Encode();

    void InitAudioDenoise();
    void InitAudioEffect();
    int Denoise();

    //每次从缓存取出的帧大小，用于重采样，使得重采样后等于编码的帧大小（frame size）
    // int fifo_frame_size_;
    //  unsigned char *fifo_frame_data_;
    //  int fifo_frame_data_size_;
    AVFrame *fifo_avframe_;

    AudioEffect audio_effect_name_;

    AudioResampleIntreface* audio_resample_;
    AudioDenoiseInterface * audio_denoise_;
    AudioEffectInterface * audio_effect_;

    AVFormatContext *avformat_context_;
    AVCodecContext *avcodec_context_;
    AVFrame *avframe_;
    AVAudioFifo *audio_fifo_;
};

#endif //__CANNOT_USE_LIBAV__

#endif // AUDIO_RECODER_H_
