/*
 *  Copyright (c) 2011 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#ifndef WEBRTC_MODULES_AUDIO_CONFERENCE_MIXER_SOURCE_MEMORY_POOL_GENERIC_H_
#define WEBRTC_MODULES_AUDIO_CONFERENCE_MIXER_SOURCE_MEMORY_POOL_GENERIC_H_

#include <assert.h>
#include <queue>

#include "common/critical_section_wrapper.h"
#include "common/typedefs.h"

namespace webrtc {
    
template<class DataType>
class FifoQueueImpl
{
public:
    int32_t Pop(DataType*&  dt);
    int32_t Push(DataType*& dt);

    FifoQueueImpl(int32_t initialQueueSize);
    ~FifoQueueImpl();

    // Atomic functions
    int32_t Terminate();
    bool Initialize();
private:
    // Non-atomic function.
    int32_t CreateQueue(uint32_t amountToCreate);

    CriticalSectionWrapper* _crit;

    bool _terminate;
    
    uint32_t _initialQueueSize;

    std::queue<DataType*> _dtQueue;
};

template<class DataType>
FifoQueueImpl<DataType>::FifoQueueImpl(int32_t initialQueueSize)
    : _crit(CriticalSectionWrapper::CreateCriticalSection()),
      _terminate(false),
      _initialQueueSize(initialQueueSize)
{
}

template<class DataType>
FifoQueueImpl<DataType>::~FifoQueueImpl()
{
    delete _crit;
}

template<class DataType>
int32_t FifoQueueImpl<DataType>::Pop(DataType*& dt)
{
    CriticalSectionScoped cs(_crit);
    if(_terminate)
    {
        return -1;
    }
    if (_dtQueue.empty()) {
            return -1;
    }
    dt = _dtQueue.front();
    _dtQueue.pop();
 
    return 0;
}

template<class DataType>
int32_t FifoQueueImpl<DataType>::Push(DataType*& dt)
{
    CriticalSectionScoped cs(_crit);
    /*zhiqiang--
    if(_dtQueue.size() > (_initialQueueSize << 1))
    {
        // Reclaim memory if less than half of the pool is unused.
        return 0;
    }
    //*/
    _dtQueue.push(dt);
    return 0;
}

    template<class DataType>
    bool FifoQueueImpl<DataType>::Initialize()
{
    CriticalSectionScoped cs(_crit);
    return CreateQueue(_initialQueueSize) == 0;
}

template<class DataType>
int32_t FifoQueueImpl<DataType>::Terminate()
{
    //为什么释放动作不放在析构函数中呢？
    CriticalSectionScoped cs(_crit);
    _terminate = true;
 
    // Reclaim all  queue data
    /*
    while(_createdMemory > 0)
    {
        MemoryType* memory = _memoryPool.front();
        _memoryPool.pop_front();
        delete memory;
        _createdMemory--;
    }
     //*/
    return 0;
}

    template<class DataType>
    int32_t FifoQueueImpl<DataType>::CreateQueue(
    uint32_t amountToCreate)
{
    /*
    for(uint32_t i = 0; i < amountToCreate; i++)
    {
        MemoryType* memory = new MemoryType();
        if(memory == NULL)
        {
            return -1;
        }
        _memoryPool.push_back(memory);
        _createdMemory++;
    }
    //*/
    // _dtQueue.capcity(amountToCreate);
    return 0;
}
    
}  // namespace webrtc
//*/
#endif // WEBRTC_MODULES_AUDIO_CONFERENCE_MIXER_SOURCE_MEMORY_POOL_GENERIC_H_
