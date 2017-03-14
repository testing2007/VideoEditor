//
//  SynthesisCallback.h
//  libFeinnoVideo
//
//  Created by wzq on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef __libFeinnoVideo__SynthesisCallback__
#define __libFeinnoVideo__SynthesisCallback__

#include <iostream>
#include <synthesis/ISynthesisCallback.h>


class SynthesisCallback : public ISynthesisCallback
{
public:
    explicit SynthesisCallback(const FVideoViewController* vc);
    virtual ~SynthesisCallback();
    
    //fPercent范围从 0.0  ～ 1.0
    virtual void synProgress(float fPercent);
    virtual void synPause();
    //合成成功
    virtual void synSuccess(SYN_MESSAGE_ID synMessageID);
    //合成失败
    virtual void synFailure(const char* errorReason=NULL);

//    virtual void synProgress(float fPercent);
//    virtual void synSuccess();
//    virtual void synFailure(const char* errorReason=NULL);
};

#endif /* defined(__libFeinnoVideo__SynthesisCallback__) */
