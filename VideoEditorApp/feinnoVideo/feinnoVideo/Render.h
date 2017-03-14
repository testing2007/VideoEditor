//
//  Render.h
//  libFeinnoVideo
//
//  Created by wzq on 14-9-14.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef __libFeinnoVideo__Render__
#define __libFeinnoVideo__Render__

#include <iostream>
#include <base/thread_wrapper.h>
#import <synthesis/SynthesisImpl.h>
// #import "SynthesisCallback.h"
#include <base/SynthesisParameterInfo.h>
#include <base/critical_section_wrapper.h>
#include <base/event_wrapper.h>
//#import <vector.h>
#import <list>
#include <base/ObjcClass.h>
OBJC_CLASS(FVideoViewController);

class SynthesisCallback;
namespace webrtc
{
    class cMessageQueue;
    class MessageData;
}

struct RenderMessage{
    RenderMessage():message_id(SYN_MSG_UNKNOWN), data(NULL)
    {
    }
    int message_id;
    void* data;
};

/*
class ThreadWrapper
{
public:
    ~ThreadWrapper()
    {
    }
    
    typedef void (*ThreadRunFunction)(void*);
    ThreadWrapper* CreateThread(ThreadRunFunction threadFunc, void* param)
    {
        pthread_create(&tid, NULL, threadFunc, param);
    }
    
private:
    ThreadWrapper()
    {
    }
    
private:
    pthread_t tid;
    
};
//*/

using namespace webrtc;
class Render
{
public:
    explicit Render(FVideoViewController* videoViewController);
    ~Render();
    
    void push(RenderMessage* msg);
    
    static bool RunRender(void* ptrThis);
    void Run();
    void Exit();
    void Pause();
    void Stop();
    void Resume();

private:
    EventWrapper& _event;
    CriticalSectionWrapper& _criticalSection;
    ThreadWrapper* _renderThread; //渲染线程
    bool _bExitThread;
    SynthesisCallback* _synthesisCallback;
    SynthesisImpl _synthesisImpl;
    //std::vector<RenderMessage*> _renderMsgQueue;
    std::list<RenderMessage*> _renderMsgQueue;
    bool _bSureExitThread;//确信线程完全退出
    FVideoViewController* _videoViewController;
};

#endif /* defined(__libFeinnoVideo__Render__) */
