//
//  SynthesisCallback.cpp
//  libFeinnoVideo
//
//  Created by wzq on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#include "SynthesisCallback.h"
#include "FVideoViewController.h"

SynthesisCallback::SynthesisCallback(const FVideoViewController* vc):ISynthesisCallback(vc)
{
}

SynthesisCallback::~SynthesisCallback()
{
    
}

void SynthesisCallback::synProgress(float fPercent)
{
    [(FVideoViewController*)_vc proto_synProgress:fPercent];
}

void SynthesisCallback::synSuccess(SYN_MESSAGE_ID synMessageID)
{
    [(FVideoViewController*)_vc proto_synSuccess:synMessageID];
}

void SynthesisCallback::synFailure(const char* errorReason/*=NULL*/)
{
    [(FVideoViewController*)_vc proto_synFailure:errorReason];
}

void SynthesisCallback::synPause()
{
    [(FVideoViewController*)_vc proto_synPause];
}
