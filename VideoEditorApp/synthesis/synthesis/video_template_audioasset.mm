/*
 * video_template_audioasset.cpp
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#include "video_template_audioasset.h"
#include <codec/CodecInterface.h>


namespace feinnovideotemplate {

    AudioAsset::AudioAsset():media_source_(NULL) {
    set_asset_type(AUDIO);
}

AudioAsset::~AudioAsset() {

    CloseDecode();
}

    long AudioAsset::duration()  {
        
        if (media_source_ == NULL) {
            StartDecode();
        }
        if(duration_ == 0){
            duration_ = media_source_->info(kMediaFileInfoKeyDuration) * 25 / 1000;
        }
        return duration_;
    }
    
    void AudioAsset::set_duration(long duration) {
        duration_ = duration;
    }
    
    void AudioAsset::StartDecode() {
        if (media_source_ != NULL) {
            return;
        }
        media_source_ = CreateMediaSource("");
        int open = media_source_->open(uri());
        if (open != 0) {
            // 异常处理
            printf( "open audio fail:%d @ %s",  open,uri().c_str());
            return;
        }
        printf("start audio Decode:%s @ %p", uri().c_str(), media_source_);
    }

     void AudioAsset::CloseDecode() {
        if (media_source_ != NULL) {
            media_source_->close();
            printf( "close audio Decode: %s @ %p", uri().c_str(), media_source_);
            delete media_source_;
            media_source_ = NULL;
        }
    }

     unsigned char* AudioAsset::GetNextAudioSamples(){
        if (media_source_ == NULL) {
            StartDecode();
        }
//
//        if (media_source_->getFrame() != 0) {
//            // 异常处理
//            Log.e("ExcecuteProject", "decode audio fail:" + "@" + getUri().getPath());
//            closeDecode();
//            return null;
//        }

        return media_source_->next_audio_frame();
    }

    
    unsigned char* AudioAsset::MixAudio(unsigned char* audio2){
        
        if(audio2 == NULL){
            return NULL;
        }
        unsigned char* audioSamples = GetNextAudioSamples();
        if(audioSamples == NULL){
            return audio2;
        }
        for (int i = 0; i < AUDIO_DATA_SIZE; i++) {
            audioSamples[i] += audio2[i];
        }
        
        return audioSamples;
    }



} /* namespace feinnovideotemplate */
