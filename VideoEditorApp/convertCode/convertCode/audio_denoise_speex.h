/*
 * audio_denoise_speex.h
 *
 *  Created on: 2014年7月18日
 *      Author: 尚博才
 */

#ifndef AUDIO_DENOISE_SPEEX_H_
#define AUDIO_DENOISE_SPEEX_H_

#include "audio_denoise_interface.h"

struct SpeexPreprocessState_;

//fixme 使用speex降噪，目前只能处理单声道（每个SpeexPreprocessState_只能处理一个声道）
class AudioDenoiseSpeex : public AudioDenoiseInterface{
public:
    AudioDenoiseSpeex();
    virtual ~AudioDenoiseSpeex();

    virtual int Init(int frame_size, int sample_rate, int channel_count);

    virtual int Denoise(short *data);



private:
    SpeexPreprocessState_* speex_pre_process_state_;

};




#endif // AUDIO_DENOISE_SPEEX_H_ 
