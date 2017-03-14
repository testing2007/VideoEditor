/*
 * audio_resample_libav.h
 *
 *  Created on: 2014年7月17日
 *      Author: 尚博才
 */

#ifndef AUDIO_RESAMPLE_LIBAV_H_
#define AUDIO_RESAMPLE_LIBAV_H_

#ifndef __CANNOT_USE_LIBAV__

#include "audio_resample_interface.h"

struct AVAudioResampleContext;

class AudioResampleLibav : public AudioResampleIntreface {

public:
    AudioResampleLibav();
    ~AudioResampleLibav();

    virtual void SetInputAudioFormat(int sample_rate,
           FAudioChannelLayout channel_layout,
           FSampleFormat sample_format);
   virtual void SetOutputAudioFormat(int sample_rate,
           FAudioChannelLayout channel_layout,
           FSampleFormat sample_format);

   virtual int InitAudioResample(AudioResampleCallbackIntreface* callback);

   virtual int Resample(unsigned char **output,
           int out_plane_size, int out_samples, unsigned char **input,
           int in_plane_size, int in_samples);

private:

   int in_sample_rate_;
  FAudioChannelLayout in_channel_layout_;
  FSampleFormat in_sample_format_;

  int out_sample_rate_;
   FAudioChannelLayout out_channel_layout_;
   FSampleFormat out_sample_format_;

   AudioResampleCallbackIntreface* resampleCallback_;

   AVAudioResampleContext* audio_resample_context_;
};

#endif //__CANNOT_USE_LIBAV__

#endif // AUDIO_RESAMPLE_LIBAV_H_ 
