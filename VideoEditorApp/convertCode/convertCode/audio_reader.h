/*
 * audio_reader.h
 *
 *  Created on: 2014年7月22日
 *      Author: 尚博才
 */

#ifndef AUDIO_READER_H_
#define AUDIO_READER_H_

#ifndef __CANNOT_USE_LIBAV__

#include "audio_utils.h"
#include "audio_reader_interface.h"

struct AVFormatContext;
struct AVCodecContext;
struct AVFrame;

//先InitInputFile然后GetBufferSize得到解码帧字节数
//GetFrame传入的数据大小等于GetBufferSize的值
//调用GetFrame取数据sample_count为数据大小，最后一帧可能比较小，is_finished为1后结束
class AudioReader : public AudioReaderInterface {
private:
	static const int kMaxAudioBufferSize = 2048*8*2; //最大每帧2048样，double类型2声道。针对有的格式解码没有帧大小
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

    AudioReader();
    ~AudioReader();

    //初始化打开文件
    int InitInputFile(const char* file_name);

    //取解码后的音频数据。返回负数，is_finished设置为1表示文件结束，is_finished为0时有错误
    int GetFrame(short* data, int& sample_count, int &is_finished);

//异步
//    int Start(int is_async);
//    int Pause();
//    int Stop();

    //关闭文件
    int CloseInputFile();
    //一帧的数据大小
    int GetBufferSize() {
        return buffer_size_;
    }
    //采样率
    int sample_rate() {
        return sample_rate_;
    }
    //声道样式
    FAudioChannelLayout channel_layout() {
        return channel_layout_;
    }
    //采样样式
    FSampleFormat sample_format() {
        return sample_format_;
    }
    //声道数
    int channel_count() {
        return channel_count_;
    }
    //比特率
    int bit_rate() {
        return bit_rate_;
    }

private:
    int OpenInputAudioFile(const char* filename, AVFormatContext ** fmt_ctx, AVCodecContext **av_ctx,
            int& stream_index);

    int DecodeAudioFrame(AVFrame *frame, AVFormatContext *fmtctx, AVCodecContext *avctx, int stream_index,
            int *datapresent, int *finished);

    const char *AvcodecGetName(int id);

    AVFormatContext *avformat_context_;
    AVCodecContext *avcodec_context_;
    AVFrame *avframe_;

    int sample_rate_;
    FAudioChannelLayout channel_layout_;
    FSampleFormat sample_format_;
    int channel_count_;
    int bit_rate_;

    int buffer_size_;

    int state_;
    int stream_index_;
    //planar格式的声音，各声道数据是分开的，需要把buffer分成几等分，分别存储各声道数据
    bool is_planar_;
};

#endif //#ifndef __CANNOT_USE_LIBAV__

#endif // AUDIO_READER_H_
