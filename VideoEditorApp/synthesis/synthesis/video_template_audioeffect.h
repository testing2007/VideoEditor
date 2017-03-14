/*
 * video_template_audioeffect.h
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_AUDIOEFFECT_H_
#define VIDEO_TEMPLATE_AUDIOEFFECT_H_

#include "video_template_effect.h"
#include <string>
#include <base/ObjcClass.h>

OBJC_CLASS(AVPlayer);
OBJC_CLASS(AVPlayerItem);

namespace feinnovideotemplate {
using std::string;

    // 播放声音用，在界面实现了，这个类没用了

class AudioEffect: public feinnovideotemplate::Effect {
public:
    AudioEffect();
    AudioEffect(const string& id);
    virtual ~AudioEffect();


    unsigned char* ApplyEffect(unsigned char* curFrame, bool isPreview,list<Filter*>& filterlist);
    void Close();


    static void PlaySrcAudio(const string& srcAudio);
    static void SetSrcPlayerMute(bool isMute);
    static void StopSrcPlayer();

//protected:
    void ApplyEffect(const string& uri);



private:
    

    static AVPlayer* src_audio_player_;// = new MediaPlayer();
    AVPlayer* player_;
    static AVPlayerItem* player_item_;
};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_AUDIOEFFECT_H_ */
