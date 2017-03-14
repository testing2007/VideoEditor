/*
 * audio_sample_fifo.h
 *
 *  Created on: 2014年8月28日
 *      Author: 尚博才
 */

#ifndef AUDIO_SAMPLE_FIFO_H_
#define AUDIO_SAMPLE_FIFO_H_

#include <base/f_audio_types.h>

//音频采样队列，仅处理单声道或交错存储的采样数据，没有支持planar存储。
class AudioSampleFifo {
public:
	static int const kNoError 			= 0;
	static int const kOverMaxSize 		= -1;
	static int const kAllocMemeryError  = -2;

public:
	//采样格式，通道数，初始化大小，最大缓存
	AudioSampleFifo(FSampleFormat sample_format, int channel_count, int init_size = 1024, int max_size = 4096);
	~AudioSampleFifo();

	//当前存储采样数
	int GetSamplesCount();
	//存入数据，缓冲区不够大时，自动扩充，内存超过允许的最大值后操作失败。0成功，其他失败。
	int PutData(unsigned char* data, unsigned samples_count);
	//取数据，输入地址和采样数，返回取出的采样数
	int GetData(unsigned char* data, unsigned samples_count);

private:

	//每采样字节数，采样字节数*声道数
	int bytes_persample_;
	//缓存总大小
	int totle_sample_count_;
	int totle_bytes_size_;
	//当前存储采样数
	int current_sample_count_;
	//缓存地址
	unsigned char* buffer_;
	//当前数据起始地址
	unsigned char* buffer_start_;
	//数据结束地址
	unsigned char* buffer_end_;

	//最大缓存
	int max_samples_;

};



#endif /* AUDIO_SAMPLE_FIFO_H_ */
