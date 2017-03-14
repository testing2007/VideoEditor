#include "audio_utils.h"

#include <jni.h>

static const char* kClassAudioConvert = "com/feinno/faudio/AudioConvert";
static const char* kClassAudioRecorder = "com/feinno/faudio/AudioRecorder";

extern JNINativeMethod g_audio_convert_native_methods[];
extern int g_audio_convert_native_count;
extern JNINativeMethod g_audio_recorder_native_methods[];
extern int g_audio_recorder_native_count;


extern "C" jint JNI_OnLoad(JavaVM *jvm, void *reserved) {
    JNIEnv *env = 0;
    jclass java_audio_convert, java_audio_recorder;
    F_AUDIO_LOG_INFO("FAudio v1.0.0\n JNI_OnLoad jvm: %X", (unsigned int)jvm);
    
    if(jvm->GetEnv((void **)&env, JNI_VERSION_1_4) < 0) {
        F_AUDIO_LOG_ERROR("jvm->GetEnv failed");
        return JNI_FALSE;
    }

    F_AUDIO_LOG_INFO("get env: %X", (unsigned int)env);
    
    java_audio_convert = env->FindClass(kClassAudioConvert);
    java_audio_recorder = env->FindClass(kClassAudioRecorder);

    if(java_audio_convert && java_audio_convert) {
        F_AUDIO_LOG_VERBOSE("RegisterNatives begin");
        env->RegisterNatives(java_audio_convert, g_audio_convert_native_methods,
                g_audio_convert_native_count);
        F_AUDIO_LOG_INFO("RegisterNatives audio convert");
        env->RegisterNatives(java_audio_recorder, g_audio_recorder_native_methods,
                g_audio_recorder_native_count);
        F_AUDIO_LOG_INFO("RegisterNatives audio recorder");
        F_AUDIO_LOG_VERBOSE("RegisterNatives end");

    } else {
        F_AUDIO_LOG_ERROR("FindClass error: java_audio_convert(%p) java_audio_recorder(%p)",
                java_audio_convert, java_audio_recorder);
    }

    return JNI_VERSION_1_4;
}

extern "C" void JNI_OnUnload(JavaVM *jvm, void *reserved) {
}
