/*
 * audio_recorder_wav.cpp
 *
 *  Created on: 2014年8月28日
 *      Author: 尚博才
 */

#include "audio_recorder_wav.h"
#include "audio_utils.h"

#include <string.h>

#include "audio_sample_fifo.h"
#include "audio_denoise_speex.h"
#include "audio_effect_soundtouch.h"

AudioRecorderWav::AudioRecorderWav() :
        audio_denoise_(NULL),
        audio_effect_(NULL),
        wav_file_(NULL),
        audio_fifo_(NULL),
        frame_buffer_(NULL),
        frame_size_(0),
        audio_effect_name_(kMale) {
	//wav_header_ = { 0 };
}

AudioRecorderWav::~AudioRecorderWav() {
    F_AUDIO_LOG_VERBOSE("begin");

    if(audio_denoise_ != NULL){
        F_AUDIO_LOG_DEBUG("delete denoise");
        delete audio_denoise_;
        audio_denoise_ = NULL;
    }
    if(audio_effect_ != NULL){
        F_AUDIO_LOG_DEBUG("delete effect");
        delete audio_effect_;
        audio_effect_ = NULL;
    }
    if(audio_fifo_ != NULL) {
    	delete audio_fifo_;
    	audio_fifo_ = NULL;
    }
    if(frame_buffer_ != NULL) {
    	delete frame_buffer_;
    	frame_buffer_ = NULL;
    }

    F_AUDIO_LOG_VERBOSE("end");
}

void AudioRecorderWav::SetInputAudioFormat(int sample_rate,
        FAudioChannelLayout channel_layout, FSampleFormat sample_format,
        int channel_count, int bit_rate) {
    F_AUDIO_LOG_VERBOSE("begin");
    input_format_.bit_rate = bit_rate;
    input_format_.sample_format = sample_format;
    input_format_.channel_count = channel_count;
    input_format_.channel_layout = channel_layout;
    input_format_.sample_rate = sample_rate;
    // 输出与输入相同，为了简单，不做任何处理
    output_format_.bit_rate = bit_rate;
    output_format_.sample_format = sample_format;
    output_format_.channel_count = channel_count;
    output_format_.channel_layout = channel_layout;
    output_format_.sample_rate = sample_rate;
    F_AUDIO_LOG_VERBOSE("end");
}

void AudioRecorderWav::SetOutPutAudioFormat(int sample_rate,
        FAudioChannelLayout channel_layout, FSampleFormat sample_format,
        int channel_count, int bit_rate) {
	F_AUDIO_LOG_WARNING("do nothing, OutPutAudioFormat same as input");
}


void AudioRecorderWav::SetAudioDenoise(){
    F_AUDIO_LOG_VERBOSE("begin");
	audio_denoise_ = new AudioDenoiseSpeex();
	F_AUDIO_LOG_VERBOSE("end");
}

void AudioRecorderWav::SetAudioEffect(AudioEffect audio_effect){
    F_AUDIO_LOG_VERBOSE("begin");
    audio_effect_ = new AudioEffectSoundtouch();
    audio_effect_name_ = audio_effect;
    F_AUDIO_LOG_VERBOSE("end");
}

int AudioRecorderWav::InitFrame() {
	frame_size_ = output_format_.sample_rate * 20 / 1000;
	frame_buffer_ = new short[frame_size_];

	if(frame_buffer_ == NULL)
		return kFrameAllocError;

	return kNoError;
}


int AudioRecorderWav::InitAudioFile(AudioEncoderName codec_name,
        const char* filename) {
    F_AUDIO_LOG_VERBOSE("begin");

    int error;
    //打开文件。写文件头占位，文件关闭时更新成正确内容。
    wav_file_ = fopen(filename, "wb");
    if(wav_file_ == NULL) {
    	F_AUDIO_LOG_ERROR("cann't open file %s", filename);
    	return kCannotOpenOutputFile;
    }
    InitWaveHeader(wav_header_);
	fwrite((void*)&wav_header_, 1, sizeof(wav_header_), wav_file_);
	F_AUDIO_LOG_INFO("wav file %s, bits per sample %d, samples per second %d,"
			"bytes per second %d,block align %d,channel count %d",
			filename,wav_header_.bits_persample,wav_header_.samples_persecond,
			wav_header_.bytes_persecond,wav_header_.block_align,wav_header_.channels_count);


	error = InitFrame();
	if (error != kNoError)
		return error;

    //是否需要重采样，不允许
    if(input_format_.sample_rate != output_format_.sample_rate
            || input_format_.channel_layout != output_format_.channel_layout
            || input_format_.sample_format != output_format_.sample_format) {
    	F_AUDIO_LOG_ERROR("output mast equals to input format");
        return kNotSupportFormatOfOutputFile;
    }

    error = InitAudioFifo();
        if(error != kNoError) return error;

    InitAudioDenoise();

    InitAudioEffect();

    F_AUDIO_LOG_VERBOSE("end");
    return kNoError;
}
//缓存->[降噪]->重采样->[音效]->编码
int AudioRecorderWav::EncodeAudioFrame(uint8_t **data, int sample_count) {
    F_AUDIO_LOG_VERBOSE("begin");

    int error;

    //缓存
    if ((error = AddFrameToBuffer(data, sample_count)) != kNoError)
        return error;


    while (true) {
        int get_sample_count = 0;
        if ((error = GetFrameFromBuffer((unsigned char**)(&frame_buffer_), get_sample_count))
                      != kNoError)
            return error;
        if (get_sample_count == 0)
            break;

        //从缓存得到合适的帧，继续处理

        //降噪
        Denoise();

        //音效
        if (audio_effect_ != NULL) {
        	F_AUDIO_LOG_VERBOSE("Add Audio effect");
            audio_effect_->PutSamples(frame_buffer_, get_sample_count);
            while (audio_effect_->GetRemainedSampleCount()
                    >= get_sample_count) {
                audio_effect_->ReceiveSamples(frame_buffer_,
                		get_sample_count);
                //编码
                if ((error = Encode(get_sample_count)) != kNoError)
                    return error;
            }
        } else {
            if ((error = Encode(get_sample_count)) != kNoError)
                return error;
        }
    };

    F_AUDIO_LOG_VERBOSE("end");
    return kNoError;
}

int AudioRecorderWav::Encode(int sample_count) {

	int n = fwrite(frame_buffer_, 1, sample_count * wav_header_.block_align, wav_file_);
	wav_header_.data_chkLen += sample_count * wav_header_.block_align;

	F_AUDIO_LOG_VERBOSE("write %d samples to file, now %d bytes", sample_count, wav_header_.data_chkLen);

	return kNoError;
}

int AudioRecorderWav::CloseAudioFile() {
    F_AUDIO_LOG_VERBOSE("begin");
    //修正文件头信息，写回文件
    wav_header_.riff_file_length = wav_header_.data_chkLen  + sizeof(wav_header_) - 8;
    fflush(wav_file_);
    fseek(wav_file_, 0, SEEK_SET);
    fwrite((void*)&wav_header_, 1, sizeof(wav_header_), wav_file_);
    fclose(wav_file_);
    wav_file_ = NULL;

    F_AUDIO_LOG_INFO("record over, data size %d bytes", wav_header_.data_chkLen);

    F_AUDIO_LOG_VERBOSE("end");
    return kNoError;
}


void AudioRecorderWav::InitWaveHeader(WaveHeader& wh) {
	strcpy(wh.riff_fileid, "RIFF");
	wh.riff_file_length = 0 + sizeof(wh)-8;
	strcpy(wh.waveid, "WAVE");

	strcpy(wh.fmt_chkid, "fmt ");
	wh.fmt_chk_length = 16;

	wh.format_tag = 1;
	wh.channels_count = output_format_.channel_count;
	wh.samples_persecond = output_format_.sample_rate;
	wh.bits_persample =  GetBytesCountPerSample(output_format_.sample_format) * 8;
	wh.block_align = wh.channels_count*wh.bits_persample / 8;
	wh.bytes_persecond = wh.block_align*wh.samples_persecond;

	strcpy(wh.data_chkid, "data");
	wh.data_chkLen = 0;

}

int AudioRecorderWav::GetBytesCountPerSample(FSampleFormat sf) {
	switch (sf) {
	case kSampleFmtU8:
	case kSampleFmtU8p:
		return 1;
	case kSampleFmtS16:
	case kSampleFmtS16p:
		return 2;
	case kSampleFmtS32:
	case kSampleFmtS32p:
	case kSampleFmtFlt:
	case kSampleFmtFltp:
		return 4;
	case kSampleFmtDbl:
	case kSampleFmtDblp:
		return 8;

	}
	F_AUDIO_LOG_ASSERT(false ,"No support sample format %d", sf);
	return 0;
}


int AudioRecorderWav::InitAudioFifo(){

    audio_fifo_ = new AudioSampleFifo(input_format_.sample_format, input_format_.channel_count);

    return kNoError;
}

int AudioRecorderWav::AddFrameToBuffer(uint8_t **data,
        const int frame_size){
    F_AUDIO_LOG_VERBOSE("add to audio fifo ");

    int error = audio_fifo_->PutData(*data,frame_size);

    return error;
}

int AudioRecorderWav::GetFrameFromBuffer(uint8_t **data, int& sample_count) {
	F_AUDIO_LOG_VERBOSE("have %d need %d ",
			audio_fifo_->GetSamplesCount(), frame_size_);
	if(audio_fifo_->GetSamplesCount() >= frame_size_){
		sample_count = audio_fifo_->GetData(*data, frame_size_);
	} else {
		sample_count = 0;
	}
    return kNoError;
}

void AudioRecorderWav::InitAudioDenoise(){
    if(audio_denoise_ != NULL){
        audio_denoise_->Init(frame_size_, input_format_.sample_rate, input_format_.channel_count);
    }
}

void AudioRecorderWav::InitAudioEffect() {
    if(audio_effect_ != NULL) {
        int error = audio_effect_->InitAudioEffect(output_format_.channel_count,
                output_format_.sample_rate,audio_effect_name_);
        if(error != kNoError){
            delete audio_effect_;
            audio_effect_ = NULL;
        }
    }
}

int AudioRecorderWav::Denoise(){
    if(audio_denoise_ == NULL) return kNoError;
    audio_denoise_->Denoise(frame_buffer_);
    return kNoError;
}


