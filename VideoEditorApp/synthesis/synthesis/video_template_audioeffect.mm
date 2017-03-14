/*
 * video_template_audioeffect.cpp
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#include "video_template_audioeffect.h"
#include <AVFoundation/AVFoundation.h>

namespace feinnovideotemplate {


AVPlayer*  AudioEffect::src_audio_player_ = nil;// = [AVPlayer alloc];
AVPlayerItem* AudioEffect::player_item_ = nil;
    
AudioEffect::AudioEffect(): Effect() {

}

AudioEffect::AudioEffect(const string& id) : Effect(id) {

}

AudioEffect::~AudioEffect() {
    Close();
}

unsigned char* AudioEffect::ApplyEffect(unsigned char* curFrame, bool isPreview,list<Filter*>& filterlist)
{
    return curFrame;
}

void AudioEffect::ApplyEffect(const string& uri) {
//    if (uri.length() > 0) {
//        //fixme
////        player = MediaPlayer.create(VideoBeautifyContext.getInstance().getmContext(), uri);
////        player.setVolume(1.0f, 1.0f);
////        player.start();
//        NSURL *url = [[NSURL alloc]initWithString:[[NSString alloc] initWithUTF8String:uri.c_str()]];
//        player_ = [[AVPlayer alloc] initWithURL:url];
//        [player_ setVolume:1.0f];
//        [player_ play];
//    }
//
}

void AudioEffect::Close() {
//    //fixme
//    if (player_ != nil) {
////        if (player.isPlaying()) {
////            player.stop();
////        }
////        [player_ pause];
//        player_ = nil;
//    }
   if(src_audio_player_ != nil)
   {
       src_audio_player_ = nil;
   }
    if(player_item_ != nil)
    {
        player_item_ = nil;
    }
}


void AudioEffect::PlaySrcAudio(const string& srcAudio){
    //fixme
    //try {
//    NSURL *url = [[NSURL alloc]initWithString:[[NSString alloc] initWithUTF8String:srcAudio.c_str()]];
//    player_item_ = (AVPlayerItem*)[AVPlayerItem playerItemWithURL:url];
//    src_audio_player_ = [AVPlayer playerWithPlayerItem:player_item_];
//    //src_audio_player_ = [[AVPlayer alloc] initWithURL:url ];
//    [src_audio_player_ setVolume:1.0];
//    [(AVPlayer*)src_audio_player_ play];
        //srcAudioPlayer.setVolume(1.0f, 1.0f);
//        srcAudioPlayer.prepare();
//        srcAudioPlayer.start();
//    } catch (IllegalArgumentException e) {
//        e.printStackTrace();
//    } catch (SecurityException e) {
//        e.printStackTrace();
//    } catch (IllegalStateException e) {
//        e.printStackTrace();
//    } catch (IOException e) {
//        e.printStackTrace();
//    }
}

void AudioEffect::SetSrcPlayerMute(bool isMute){
    //fixme
    //if (srcAudioPlayer.isPlaying()) {
//        if(isMute){
//            [(AVPlayer*)src_audio_player_ setVolume:0.0f];
//        } else {
//            [(AVPlayer*)src_audio_player_ setVolume:1.0f];
//        }
    //}
}

void AudioEffect::StopSrcPlayer() {
//    [(AVPlayer*)src_audio_player_ pause];
    //fixme
//   if (srcAudioPlayer.isPlaying()) {
//        srcAudioPlayer.stop();
//        srcAudioPlayer.reset();
//   }
//    [(AVPlayer*)src_audio_player_ pause];
}
    
} /* namespace feinnovideotemplate */
