/*
 * jni_audio_recoder.cpp
 *
 *  Created on: 2014年7月24日
 *      Author: 尚博才
 */

#include <jni.h>
#include <stdlib.h>

#include "audio_recorder.h"
#include "audio_instance_factory.h"

/*
 * Class:     com_feinno_faudio_AudioRecorder
 * Method:    nativeGetClass
 * Signature: ()I
 */
 AudioRecorderIntreface*  JniGetAudioRecorderClass
  (JNIEnv *, jobject){
     return AudioInstanceFactory::GetAudioRecorderInstance("libav");
	// return AudioInstanceFactory::GetAudioRecorderInstance("wav");
}

/*
 * Class:     com_feinno_faudio_AudioRecorder
 * Method:    nativeInit
 * Signature: (ILjava/lang/String;IIIIII)I
 */
 jint  JniAudioRecorderInit
  (JNIEnv *env, jobject,  AudioRecorderIntreface* audio_recorder, jstring file_name, jint sample_rate,
          jint channel_layout, jint sample_format, jint channel_count, jint bit_rate, jint denoise){
    const char* out = env->GetStringUTFChars(file_name, NULL);
    audio_recorder->SetInputAudioFormat(sample_rate,(FAudioChannelLayout)channel_layout,(FSampleFormat)sample_format,channel_count,bit_rate);
    audio_recorder->SetOutPutAudioFormat(44100,kStereo,kSampleFmtS16,2,bit_rate);
    if(denoise){
        audio_recorder->SetAudioDenoise();
    }
    return audio_recorder->InitAudioFile(kEncodeVoAacenc,out);
}


/*
 * Class:     com_feinno_faudio_AudioRecorder
 * Method:    nativePutData
 * Signature: (I[SI)I
 */
 jint  JniAudioRecorderPutData
  (JNIEnv *env, jobject obj,  AudioRecorderIntreface* audio_recorder, jshortArray data, jint sample_count){
    short* audio_buffer = env->GetShortArrayElements(data, NULL);
    //不适合planar格式
    int error = audio_recorder->EncodeAudioFrame((unsigned char**)&audio_buffer, sample_count);
    env->ReleaseShortArrayElements(data,audio_buffer, JNI_ABORT);
    return error;
}

/*
 * Class:     com_feinno_faudio_AudioRecorder
 * Method:    nativeFree
 * Signature: (I)V
 */
 void  JniAudioRecorderFree
  (JNIEnv *, jobject, jint native_class){
	 AudioRecorderIntreface* audio_recorder = (AudioRecorderIntreface*)native_class;
     audio_recorder->CloseAudioFile();
     delete audio_recorder;
     audio_recorder = NULL;
}

 JNINativeMethod g_audio_recorder_native_methods[]={
         {"nativeGetClass", "()I", (void*)JniGetAudioRecorderClass},
         {"nativeInit", "(ILjava/lang/String;IIIIII)I", (void*)JniAudioRecorderInit},
         {"nativePutData", "(I[SI)I", (void*)JniAudioRecorderPutData},
         {"nativeFree", "(I)V", (void*)JniAudioRecorderFree}
 };

int g_audio_recorder_native_count = sizeof(g_audio_recorder_native_methods)/sizeof(g_audio_recorder_native_methods[0]);
