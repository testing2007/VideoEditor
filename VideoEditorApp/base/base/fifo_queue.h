/*
 *  Copyright (c) 2011 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#ifndef WEBRTC_MODULES_AUDIO_CONFERENCE_MIXER_SOURCE_MEMORY_POOL_H_
#define WEBRTC_MODULES_AUDIO_CONFERENCE_MIXER_SOURCE_MEMORY_POOL_H_

#include <assert.h>
#include "common/fifo_queue_impl.h"

namespace webrtc {

template<class DataType>
class FifoQueue
{
public:
    // Factory method, constructor disabled.
    static int32_t CreateFifoQueue(FifoQueue*& fifoQueue,
                                    uint32_t initialQueueSize);


    // Try to delete the queue.
    static int32_t DeleteFifoQueue(
        FifoQueue*& fifoQueue);

    int32_t Pop(DataType*&  dt);
    int32_t Push(DataType*& dt);

 private:
    FifoQueue(int32_t initialQueueSize);
    ~FifoQueue();
 
    FifoQueueImpl<DataType>* _ptrImpl;
};

template<class DataType>
FifoQueue<DataType>::FifoQueue(int32_t initialQueueSize)
{
    _ptrImpl = new FifoQueueImpl<DataType>(initialQueueSize);
}

template<class DataType>
FifoQueue<DataType>::~FifoQueue()
{
    delete _ptrImpl;
}

template<class DataType>
int32_t FifoQueue<DataType>::CreateFifoQueue(FifoQueue*&   fifoQueue,
                                         uint32_t initialQueueSize)
{
    fifoQueue = new FifoQueue(initialQueueSize);
    if(fifoQueue == NULL)
    {
        return -1;
    }
    if(fifoQueue->_ptrImpl == NULL)
    {
        delete fifoQueue;
        fifoQueue = NULL;
        return -1;
    }
    if(!fifoQueue->_ptrImpl->Initialize())
    {
        delete fifoQueue;
        fifoQueue = NULL;
        return -1;
    }
    return 0;
}

template<class DataType>
int32_t FifoQueue<DataType>::DeleteFifoQueue(FifoQueue*& fileQueue)
{
    if(fileQueue == NULL)
    {
        return -1;
    }
    if(fileQueue->_ptrImpl == NULL)
    {
        return -1;
    }
    if(fileQueue->_ptrImpl->Terminate() == -1)
    {
        return -1;
    }
    delete fileQueue;
    fileQueue = NULL;
    return 0;
}

template<class DataType>
int32_t FifoQueue<DataType>::Pop(DataType*& dt)
{
    return _ptrImpl->Pop(dt);
}

template<class DataType>
int32_t FifoQueue<DataType>::Push(DataType*& dt)
{
    return _ptrImpl->Push(dt);
}
    
} // namespace webrtc

#endif // WEBRTC_MODULES_AUDIO_CONFERENCE_MIXER_SOURCE_MEMORY_POOL_H_
