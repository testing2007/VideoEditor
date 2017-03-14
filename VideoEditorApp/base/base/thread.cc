/*
 *  Copyright (c) 2011 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#include "thread_wrapper.h"
#include "thread_posix.h"

namespace webrtc {

ThreadWrapper* ThreadWrapper::CreateThread(ThreadRunFunction func,
                                           ThreadObj obj, ThreadPriority prio,
                                           const char* thread_name) {
  return ThreadPosix::Create(func, obj, prio, thread_name);
}

bool ThreadWrapper::SetAffinity(const int* processor_numbers,
                                const unsigned int amount_of_processors) {
  return false;
}

}  // namespace webrtc
