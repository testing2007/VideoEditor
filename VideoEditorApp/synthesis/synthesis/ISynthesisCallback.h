//
//  Header.h
//  FeinnoVideoApp
//
//  Created by wzq on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef FeinnoVideoApp_Header_h
#define FeinnoVideoApp_Header_h

#include "UISynthesisCallback.h"
#include <base/SynthesisParameterInfo.h>
#include <base/ObjcClass.h>
OBJC_CLASS(FVideoViewController);

//struct SynthesisCallbackWrapper;
class ISynthesisCallback
{
public:
    explicit ISynthesisCallback(const FVideoViewController* vc):_vc(vc){}
    virtual ~ISynthesisCallback(){}
    
    //fPercent范围从 0.0  ～ 1.0
    virtual void synProgress(float fPercent) = 0;
    virtual void synPause()=0;
    //合成成功
    virtual void synSuccess(SYN_MESSAGE_ID synMessageID) = 0;
    //合成失败
    virtual void synFailure(const char* errorReason=NULL) = 0;
    
protected:
    const FVideoViewController* _vc;
};

#endif
