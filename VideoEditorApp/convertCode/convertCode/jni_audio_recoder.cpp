/*
 * jni_audio_recoder.cpp
 *
 *  Created on: 2014年7月24日
 *      Author: 尚博才
 */

#include <jni.h>
#include <stdlib.h>

#include "audio_recoder.h"

/*
 * Class:     com_feinno_faudio_AudioRecoder
 * Method:    nativeGetClass
 * Signature: ()I
 */
 AudioRecoder*  JniGetAudioRecoderClass
  (JNIEnv *, jobject){
     return new AudioRecoder();
}

/*
 * Class:     com_feinno_faudio_AudioRecoder
 * Method:    nativeInit
 * Signature: (ILjava/lang/String;IIIIII)I
 */
 jint  JniAudioRecoderInit
  (JNIEnv *env, jobject,  AudioRecoder* audio_recoder, jstring file_name, jint sample_rate,
          jint channel_layout, jint sample_format, jint channel_count, jint bit_rate, jint denoise){
    const char* out = env->GetStringUTFChars(file_name, NULL);
    audio_recoder->SetInputAudioFormat(sample_rate,(AudioChannelLayout)channel_layout,(FSampleFormat)sample_format,channel_count,bit_rate);
    audio_recoder->SetOutPutAudioFormat(44100,kStereo,kSampleFmtS16,2,bit_rate);
    if(denoise){
        audio_recoder->SetAudioDenoise();
    }
    return audio_recoder->InitAudioFile(kEncodeVoAacenc,out);
}


/*
 * Class:     com_feinno_faudio_AudioRecoder
 * Method:    nativePutData
 * Signature: (I[SI)I
 */
 jint  JniAudioRecoderPutData
  (JNIEnv *env, jobject obj,  AudioRecoder* audio_recoder, jshortArray data, jint sample_count){
    short* audio_buffer = env->GetShortArrayElements(data, NULL);
    //不适合planar格式
    int error = audio_recoder->EncodeAudioFrame((unsigned char**)&audio_buffer, sample_count);
    env->ReleaseShortArrayElements(data,audio_buffer, JNI_ABORT);
    return error;
}

/*
 * Class:     com_feinno_faudio_AudioRecoder
 * Method:    nativeFree
 * Signature: (I)V
 */
 void  JniAudioRecoderFree
  (JNIEnv *, jobject, jint native_class){
     AudioRecoder* audio_recoder = (AudioRecoder*)native_class;
     audio_recoder->CloseAudioFile();
     delete audio_recoder;
     audio_recoder = NULL;
}

 JNINativeMethod g_audio_recorder_native_methods[]={
         {"nativeGetClass", "()I", (void*)JniGetAudioRecoderClass},
         {"nativeInit", "(ILjava/lang/String;IIIIII)I", (void*)JniAudioRecoderInit},
         {"nativePutData", "(I[SI)I", (void*)JniAudioRecoderPutData},
         {"nativeFree", "(I)V", (void*)JniAudioRecoderFree}
 };

int g_audio_recorder_native_count = sizeof(g_audio_recorder_native_methods)/sizeof(g_audio_recorder_native_methods[0]);
