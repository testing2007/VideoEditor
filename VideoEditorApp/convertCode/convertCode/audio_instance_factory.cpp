/*
 * audio_instance_factory.cpp
 *
 *  Created on: 2014年8月29日
 *      Author: 尚博才
 */

#include "audio_instance_factory.h"

//#include <stdlib.h>
#include <string.h>

#include "audio_recorder.h"
#include "audio_recorder_wav.h"
#include "audio_reader.h"
#include "audio_reader_wav.h"


AudioRecorderIntreface* AudioInstanceFactory::GetAudioRecorderInstance(const char* libname) {
#ifndef __CANNOT_USE_LIBAV__
	if(strcmp("libav", libname) == 0) {
		return new AudioRecorder();
	} else
#endif //__CANNOT_USE_LIBAV__
	    if (strcmp("wav", libname) == 0) {
		return new AudioRecorderWav();
	}
	F_AUDIO_LOG_ASSERT(false, "only support %s AudioRecorderIntreface", libname);
	return NULL;
}

AudioReaderInterface* AudioInstanceFactory::GetAudioReaderInstance(const char* libname) {
#ifndef __CANNOT_USE_LIBAV__
	if(strcmp("libav", libname) == 0) {
		return new AudioReader();
	} else
#endif //__CANNOT_USE_LIBAV__
	    if (strcmp("wav", libname) == 0) {
		return new AudioReaderWav();
	}

	F_AUDIO_LOG_ASSERT(false, "only support %s AudioReaderInterface", libname);
	return NULL;
}

