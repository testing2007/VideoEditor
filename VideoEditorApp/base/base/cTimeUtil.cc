/*
 * cTimeUtil.cpp
 *
 *  Created on: 2014-8-3
 *      Author: henryliu
 */

#include "cTimeUtil.h"
#include "assert.h"

#ifdef POSIX
#include <sys/time.h>
#if defined(OSX) || defined(IOS)
#include <mach/mach_time.h>
#endif
#endif

namespace webrtc {

const uint32 LAST = 0xFFFFFFFF;
const uint32 HALF = 0x80000000;

cTimeUtil::cTimeUtil() {
	// TODO Auto-generated constructor stub

}

cTimeUtil::~cTimeUtil() {
	// TODO Auto-generated destructor stub
}

uint64_t cTimeUtil::TimeNanos()
{
	int64_t ticks = 0;
	#if defined(OSX) || defined(IOS)
	  static mach_timebase_info_data_t timebase;
	  if (timebase.denom == 0) {
	    // Get the timebase if this is the first time we run.
	    // Recommended by Apple's QA1398.
	    //zhiqiang-- VERIFY(KERN_SUCCESS == mach_timebase_info(&timebase));
          return (KERN_SUCCESS == mach_timebase_info(&timebase));//zhiqiang++
	  }
	  // Use timebase to convert absolute time tick units into nanoseconds.
	  ticks = mach_absolute_time() * timebase.numer / timebase.denom;
	#elif defined(POSIX)
	  struct timespec ts;
	  // TODO: Do we need to handle the case when CLOCK_MONOTONIC
	  // is not supported?
	  clock_gettime(CLOCK_MONOTONIC, &ts);
	  ticks = kNumNanosecsPerSec * static_cast<int64_t>(ts.tv_sec) +
	      static_cast<int64>(ts.tv_nsec);
	#elif defined(WIN32)
	  static volatile LONG last_timegettime = 0;
	  static volatile int64 num_wrap_timegettime = 0;
	  volatile LONG* last_timegettime_ptr = &last_timegettime;
	  DWORD now = timeGetTime();
	  // Atomically update the last gotten time
	  DWORD old = InterlockedExchange(last_timegettime_ptr, now);
	  if (now < old) {
	    // If now is earlier than old, there may have been a race between
	    // threads.
	    // 0x0fffffff ~3.1 days, the code will not take that long to execute
	    // so it must have been a wrap around.
	    if (old > 0xf0000000 && now < 0x0fffffff) {
	      num_wrap_timegettime++;
	    }
	  }
	  ticks = now + (num_wrap_timegettime << 32);
	  // TODO: Calculate with nanosecond precision.  Otherwise, we're just
	  // wasting a multiply and divide when doing Time() on Windows.
	  ticks = ticks * kNumNanosecsPerMillisec;
	#endif
	return ticks;
}

uint32_t cTimeUtil::Time()
{
	return static_cast<uint32>(TimeNanos() / kNumNanosecsPerMillisec);
}

uint32_t cTimeUtil::TimeAfter(int32_t elapsed)
{
	assert(elapsed >= 0);
	assert(static_cast<uint32>(elapsed) < HALF);
	return Time() + elapsed;
}

int32_t cTimeUtil::TimeDiff(uint32_t later, uint32_t earlier)
{
#if EFFICIENT_IMPLEMENTATION
	return later - earlier;
#else
	const bool later_or_equal = TimeIsBetween(earlier, later, earlier + HALF);
	if (later_or_equal) {
		if (earlier <= later) {
		  return static_cast<long>(later - earlier);
		} else {
		  return static_cast<long>(later + (LAST - earlier) + 1);
		}
	} else {
		if (later <= earlier) {
		  return -static_cast<long>(earlier - later);
		} else {
		  return -static_cast<long>(earlier + (LAST - later) + 1);
		}
	}
#endif
}

bool cTimeUtil::TimeIsBetween(uint32_t earlier, uint32_t middle, uint32_t later) {
  if (earlier <= later) {
    return ((earlier <= middle) && (middle <= later));
  } else {
    return !((later < middle) && (middle < earlier));
  }
}

bool cTimeUtil::TimeIsLater(uint32_t earlier, uint32_t later) {
#if EFFICIENT_IMPLEMENTATION
  int32_t diff = later - earlier;
  return (diff > 0 && static_cast<uint32_t>(diff) < HALF);
#else
  const bool earlier_or_equal = cTimeUtil::TimeIsBetween(later, earlier, later + HALF);
  return !earlier_or_equal;
#endif
}

bool cTimeUtil::TimeIsLaterOrEqual(uint32_t earlier, uint32_t later) {
#if EFFICIENT_IMPLEMENTATION
  int32_t diff = later - earlier;
  return (diff >= 0 && static_cast<uint32_t>(diff) < HALF);
#else
  const bool later_or_equal = cTimeUtil::TimeIsBetween(earlier, later, earlier + HALF);
  return later_or_equal;
#endif
}

} /* namespace gtalk */
