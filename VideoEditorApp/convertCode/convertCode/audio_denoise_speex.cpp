/*
 * audio_denoise_speex.cpp
 *
 *  Created on: 2014年7月18日
 *      Author: 尚博才
 */

#include "audio_denoise_speex.h"

#include <stdlib.h>

#include "speex/speex_preprocess.h"

#include "audio_utils.h"

AudioDenoiseSpeex::AudioDenoiseSpeex() :
        speex_pre_process_state_(NULL) {

}
AudioDenoiseSpeex::~AudioDenoiseSpeex() {
    if (speex_pre_process_state_ != NULL) {
        speex_preprocess_state_destroy(speex_pre_process_state_);
        speex_pre_process_state_ = NULL;
    }
}

int AudioDenoiseSpeex::Init(int frame_size, int sample_rate,
        int channel_count) {
    F_AUDIO_LOG_ASSERT(channel_count == 1, "only support 1 channel now");

    int i;
    //  int count = 0;
    // float f;

    speex_pre_process_state_ = speex_preprocess_state_init(frame_size,
            sample_rate);
    i = 1;
    speex_preprocess_ctl(speex_pre_process_state_, SPEEX_PREPROCESS_SET_DENOISE,
            &i); // 降噪
    i = 25;
    speex_preprocess_ctl(speex_pre_process_state_,
            SPEEX_PREPROCESS_SET_NOISE_SUPPRESS, &i); //设置噪声的dB
    i = 0; // （官方手册 1 开 2 关闭，看代码怀疑不是这样，应该是0关,1开）
    speex_preprocess_ctl(speex_pre_process_state_, SPEEX_PREPROCESS_SET_AGC,
            &i); //自动增益
    //    i = 8000;
    //    speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_AGC_LEVEL, &i);
    //    i = 0;
    //    speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_DEREVERB, &i);
    //    f = .0;
    //    speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_DEREVERB_DECAY, &f);
    //    f = .0;
    //    speex_preprocess_ctl(st, SPEEX_PREPROCESS_SET_DEREVERB_LEVEL, &f);

    return kNoError;
}

int AudioDenoiseSpeex::Denoise(short *data) {

    speex_preprocess_run(speex_pre_process_state_, data);

    return kNoError;
}

