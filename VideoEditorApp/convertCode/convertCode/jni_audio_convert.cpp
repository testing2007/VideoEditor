/*
 * jni_audio_convert.cpp
 *
 *  Created on: 2014年7月24日
 *      Author: 尚博才
 */

#include <jni.h>
#include <stdlib.h>

#include "audio_convert.h"

extern "C" {
/*
 * Class:     com_feinno_faudio_AudioConvert
 * Method:    nativeGetClass
 * Signature: ()I
 */
AudioConvert* JniGetAudioConvertClass(JNIEnv *, jobject) {
	return new AudioConvert("libav");
	//return new AudioConvert("wav");
}


void JniAudioConvertSetOutPutAudioFormat(JNIEnv *env, jobject obj,
		AudioConvert* audio_convert, jint sample_rate, jint channel_layout,
		jint sample_format, jint channel_count,	jint bit_rate) {
	audio_convert->SetOutPutAudioFormat(sample_rate,
				(FAudioChannelLayout) channel_layout, (FSampleFormat) sample_format,
				channel_count, bit_rate);
}

/*
 * Class:     com_feinno_faudio_AudioConvert
 * Method:    nativeInit
 * Signature: (ILjava/lang/String;Ljava/lang/String;IIIII)I
 */
jint JniInitAudioConvert(JNIEnv *env, jobject obj, jint native_class,
		jstring input_file, jstring output_file) {
	const char *in = env->GetStringUTFChars(input_file, NULL);
	const char *out = env->GetStringUTFChars(output_file, NULL);
	AudioConvert *audio_convert = (AudioConvert*) native_class;

	int return_value = audio_convert->Init(in, out);
	env->ReleaseStringUTFChars(input_file, in);
	env->ReleaseStringUTFChars(output_file, out);

	return return_value;
}

/*
 * Class:     com_feinno_faudio_AudioConvert
 * Method:    nativeAddEffect
 * Signature: (II)I
 */
jint JniAudioConvertAddEffect(JNIEnv *env, jobject obj, jint native_class,
		jint effect) {
	AudioConvert *audio_convert = (AudioConvert*) native_class;
	audio_convert->AddAudioEffect((AudioEffect) effect);
	return 0;
}

/*
 * Class:     com_feinno_faudio_AudioConvert
 * Method:    nativeConvert
 * Signature: (I)I
 */
jint JniAudioConvertConvert(JNIEnv *, jobject, jint native_class) {
	AudioConvert *audio_convert = (AudioConvert*) native_class;
	return audio_convert->Convert();
}

/*
 * Class:     com_feinno_faudio_AudioConvert
 * Method:    nativeFree
 * Signature: (I)V
 */
void JniAudioConvertFree(JNIEnv *, jobject, jint native_class) {
	AudioConvert *audio_convert = (AudioConvert*) native_class;
	delete audio_convert;
	audio_convert = NULL;
}
}

JNINativeMethod g_audio_convert_native_methods[] = {
	{ "nativeGetClass", "()I", (void*) JniGetAudioConvertClass },
	{ "nativeSetOutPutAudioFormat","(IIIIII)V",(void*)JniAudioConvertSetOutPutAudioFormat},
	{ "nativeInit",	"(ILjava/lang/String;Ljava/lang/String;)I",	(void*) JniInitAudioConvert },
	{ "nativeAddEffect", "(II)I",(void*) JniAudioConvertAddEffect },
	{ "nativeConvert", "(I)I",(void*) JniAudioConvertConvert },
	{ "nativeFree", "(I)V",	(void*) JniAudioConvertFree }
};

int g_audio_convert_native_count =
		sizeof(g_audio_convert_native_methods)/ sizeof(g_audio_convert_native_methods[0]);

