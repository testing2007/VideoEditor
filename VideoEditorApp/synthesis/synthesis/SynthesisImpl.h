//
//  SynthesisImpl.h
//  libSynthesis
//
//  Created by wzq on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef __libSynthesis__SynthesisImpl__
#define __libSynthesis__SynthesisImpl__

#include <iostream>
#include "ISynthesis.h"
#include "video_template_videotemplate.h"

class SynthesisImpl : public ISynthesis
{
public:
    SynthesisImpl();
    ~SynthesisImpl(){}
    
    virtual void registerCallback(ISynthesisCallback* synCallback);
    virtual void pause();
    virtual void stop();
    virtual void preview(SynthesisParameterInfo& param);
    virtual void save(SynthesisParameterInfo& param);
    virtual void resume();
    
private:
   // feinnovideotemplate::VideoTemplate* video_template_;
    
    ISynthesisCallback* callback_;
    
    //0 停止，1 开始，2 暂停
    int play_state_;
    
    void doProcess(SynthesisParameterInfo& param, bool ispreview);
};

#endif /* defined(__libSynthesis__SynthesisImpl__) */
