/*
 *  Copyright (c) 2011 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#include "event_wrapper.h"

#include <pthread.h>
#include "event_posix.h"


namespace webrtc {
EventWrapper* EventWrapper::Create() {
  return EventPosix::Create();
}

}  // namespace webrtc
