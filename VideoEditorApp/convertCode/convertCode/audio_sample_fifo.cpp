/*
 * audio_sample_fifo.cpp
 *
 *  Created on: 2014年8月28日
 *      Author: 尚博才
 */

#include "audio_sample_fifo.h"

#include "audio_utils.h"
#include <string.h>

static int GetBytesCountPerSample(FSampleFormat sf) {
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
	F_AUDIO_LOG_ASSERT(false, "No support sample format %d", sf);
	return 0;
}

//采样格式，通道数，初始化大小，最大缓存
AudioSampleFifo::AudioSampleFifo(FSampleFormat sample_format, int channel_count,
		int init_size, int max_size) {
	max_samples_ = max_size;
	bytes_persample_ = GetBytesCountPerSample(sample_format) * channel_count;
	totle_sample_count_ = init_size;
	current_sample_count_ = 0;
	buffer_ = new unsigned char[totle_sample_count_ * bytes_persample_];
	buffer_start_ = buffer_end_ = buffer_;
	totle_bytes_size_ = totle_sample_count_ * bytes_persample_;
}

AudioSampleFifo::~AudioSampleFifo() {
	current_sample_count_ = 0;
	totle_sample_count_ = 0;
	buffer_end_ = buffer_start_ = NULL;
	totle_bytes_size_ = 0;
	if (buffer_) {
		delete buffer_;
		buffer_ = NULL;
	}
}

//当前存储采样数
int AudioSampleFifo::GetSamplesCount() {
	return current_sample_count_;
}

//存入数据，缓冲区不够大时，自动扩充
int AudioSampleFifo::PutData(unsigned char* data, unsigned samples_count) {
	if ((totle_bytes_size_ - (buffer_end_ - buffer_))
			>= (samples_count * bytes_persample_)) {
		//末尾有足够空间存储，直接存
		memcpy(buffer_end_, data, samples_count * bytes_persample_);
		buffer_end_ += samples_count * bytes_persample_;
		current_sample_count_ += samples_count;
	} else if (totle_sample_count_ - current_sample_count_ >= samples_count) {
		//有足够空间，
		//整理内存
		memcpy(buffer_, buffer_start_, buffer_end_ - buffer_start_);
		buffer_start_ = buffer_;
		buffer_end_ = buffer_start_ + current_sample_count_ * bytes_persample_;
		//存入新数据
		memcpy(buffer_end_, data, samples_count * bytes_persample_);
		buffer_end_ += samples_count * bytes_persample_;
		current_sample_count_ += samples_count;
	} else {
		//需要分配更大空间来存储数据
		if (totle_sample_count_ > max_samples_) {
			//出错，超过最大允许的内存
			return kOverMaxSize;
		}
		//计算新的内存空间，分配更大内存
		totle_sample_count_ += samples_count;
		totle_bytes_size_ = totle_sample_count_ * bytes_persample_;
		unsigned char* tmp = new unsigned char[totle_bytes_size_];
		if (tmp == NULL) {
			F_AUDIO_LOG_ERROR("fifo alloc memory failed");
			return kAllocMemeryError;
		}
		memcpy(tmp, buffer_start_, buffer_end_ - buffer_start_);
		delete buffer_;
		buffer_ = tmp;
		buffer_start_ = buffer_;
		buffer_end_ = buffer_start_ + current_sample_count_ * bytes_persample_;
		//存入新数据
		memcpy(buffer_end_, data, samples_count * bytes_persample_);
		buffer_end_ += samples_count * bytes_persample_;
		current_sample_count_ += samples_count;

	}
	return kNoError;
}

//取数据，输入地址和采样数，返回取出的采样数
int AudioSampleFifo::GetData(unsigned char* data, unsigned samples_count) {
	if (current_sample_count_ == 0) {
		return 0;
	} else if (current_sample_count_ >= samples_count) {
		//有足够的数据
		memcpy(data, buffer_start_, samples_count * bytes_persample_);
		current_sample_count_ -= samples_count;
		buffer_start_ += samples_count * bytes_persample_;
		//如果没有数据了，重置起止地址
		if (buffer_end_ == buffer_start_) {
			buffer_end_ = buffer_start_ = buffer_;
		}
		return samples_count;
	} else {
		//数据不足
		int copy_sample_count = current_sample_count_;
		memcpy(data, buffer_start_, buffer_end_ - buffer_start_);
		current_sample_count_ = 0;
		buffer_end_ = buffer_start_ = buffer_;
		return copy_sample_count;
	}

}

