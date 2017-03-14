//
//  Render.cpp
//  libFeinnoVideo
//
//  Created by wzq on 14-9-14.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#include "Render.h"
#include <base/thread_wrapper.h>
#include <base/cMessageQueue.h>
#include "FVideoViewController.h"
#import "base/SynthesisParameterInfo.h"
#import "SynthesisParamterInstance.h"
 #import "SynthesisCallback.h"

Render::Render(FVideoViewController* videoViewController):
_criticalSection(*CriticalSectionWrapper::CreateCriticalSection()),
_event(*EventWrapper::Create()),
_bSureExitThread(false)
{
    _videoViewController = videoViewController;
    _synthesisCallback = new SynthesisCallback((FVideoViewController*)videoViewController);
    _synthesisImpl.registerCallback(_synthesisCallback);
    
    _bExitThread = false;
    _renderThread = ThreadWrapper::CreateThread(RunRender, this, kNormalPriority,
                                                    "RenderWorkerThread");
    unsigned int threadID(0);
    _renderThread->Start(threadID);
}

Render::~Render()
{
    Exit();
    delete &_criticalSection;
    delete &_event;
}

void Render::Stop()
{
    _synthesisImpl.stop();
}

void Render::Pause()
{
    _synthesisImpl.pause();
}

void Render::Resume()
{
    _synthesisImpl.resume();
}

void Render::push(RenderMessage* msg)
{
    CriticalSectionScoped lock(&_criticalSection);
    Stop();

    std::list<RenderMessage*>::iterator iterator;
    for(iterator =_renderMsgQueue.begin(); iterator != _renderMsgQueue.end(); iterator++)
    {
        delete *iterator;
    }
    _renderMsgQueue.clear();
    
    _renderMsgQueue.push_back(msg);
    _event.Set();
}

bool Render::RunRender(void* ptrThis)
{
    static_cast<Render*>(ptrThis)->Run();
    return true;
}

void Render::Run()
{
    std::list<RenderMessage*> tempList;
    while(!_bExitThread)
    {
        RenderMessage msg;
        if(_event.Wait(-1))
        {
            //
            {
                CriticalSectionScoped lock(&_criticalSection);
                {
                    tempList = _renderMsgQueue;
                    _renderMsgQueue.clear();
                }
            }
            if(!tempList.empty())
            {
                [_videoViewController removeProgressDialog];
            }
            while(!tempList.empty() && !_bExitThread)
            {
                msg = *tempList.front();
                delete tempList.front();
                tempList.pop_front();
                if(msg.data!=NULL && msg.message_id!=SYN_MSG_UNKNOWN)
                {
                    if(msg.message_id==SYN_MSG_PREVIEW)
                    {
                        _synthesisImpl.preview((SynthesisParameterInfo&)*msg.data);
                    }
                    else if(msg.message_id==SYN_MSG_SAVE)
                    {
                        _synthesisImpl.save((SynthesisParameterInfo&)*msg.data);
                    }
                }
                //usleep(1);
            }//end while
        }
        //       timespec t;
        //       t.tv_sec = 0;
        //       t.tv_nsec = 5*1000*1000;
        //       nanosleep(&t, NULL);
    }
    
    std::list<RenderMessage*>::iterator iterator;
    for(iterator =tempList.begin(); iterator != tempList.end(); iterator++)
    {
        delete *iterator;
    }
    tempList.clear();
    
    _bSureExitThread = true;
}

void Render::Exit()
{
    Stop();
    if(_renderThread != NULL)
    {
        _bExitThread = true;
        _event.Set();
        _renderThread->Stop();
        while(!_bSureExitThread)
        {
            usleep(100);
        }
        delete _renderThread;
        _renderThread = NULL;
    }
    if(_synthesisCallback != NULL)
    {
        delete _synthesisCallback;
        _synthesisCallback = NULL;
    }
}


