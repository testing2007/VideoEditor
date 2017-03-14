/*
 * audio_instance_factory.h
 *
 *  Created on: 2014年8月29日
 *      Author: 尚博才
 */

#ifndef AUDIO_INSTANCE_FACTORY_H_
#define AUDIO_INSTANCE_FACTORY_H_

#include "audio_recorder_interface.h"
#include "audio_reader_interface.h"

class AudioInstanceFactory {
public:
	static AudioRecorderIntreface* GetAudioRecorderInstance(const char* libname);
	static AudioReaderInterface* GetAudioReaderInstance(const char* libname);


};



#endif /* AUDIO_INSTANCE_FACTORY_H_ */
