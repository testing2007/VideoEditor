//
//  ISynthesis.h
//  FeinnoVideoApp
//
//  Created by wzq on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef FeinnoVideoApp_ISynthesis_h
#define FeinnoVideoApp_ISynthesis_h

#include <base/typedef.h>
//#include <feinnoVideo/SynthesisParameterInfo.h>
//#include <feinnoVideo/SynthesisParamterInstance.h>

#include <base/ObjcClass.h>
OBJC_CLASS(GPUImageView);

class ISynthesisCallback;
// struct ContextWrapper;
class SynthesisParameterInfo;

class ISynthesis
{
public:
    ISynthesis() {}
    virtual ~ISynthesis() {}
    
    //如果界面上需要反馈合成信息，需要注册
    virtual void registerCallback(ISynthesisCallback* synCallback) = 0;
    //停止上一个task;
    virtual void stop()=0;
    //暂停
    virtual void pause()=0;
    //预览合成
    virtual void preview(SynthesisParameterInfo& param) = 0;
    //存盘合成文件
    virtual void save(SynthesisParameterInfo& param) = 0;
    
    virtual void resume()=0;
};

#endif
