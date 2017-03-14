/*
 * cTimeUtil.h
 *
 *  Created on: 2014-8-3
 *      Author: henryliu
 */

#ifndef CTIMEUTIL_H_
#define CTIMEUTIL_H_

#include "typedefs.h"

namespace webrtc {

static const int64_t kNumMillisecsPerSec = INT64_C(1000);
static const int64_t kNumMicrosecsPerSec = INT64_C(1000000);
static const int64_t kNumNanosecsPerSec = INT64_C(1000000000);

static const int64_t kNumMicrosecsPerMillisec = kNumMicrosecsPerSec/kNumMillisecsPerSec;
static const int64_t kNumNanosecsPerMillisec =  kNumNanosecsPerSec /kNumMillisecsPerSec;

// January 1970, in NTP milliseconds.
static const int64_t kJan1970AsNtpMillisecs = INT64_C(2208988800000);

typedef uint32 TimeStamp;

class cTimeUtil {
public:
	cTimeUtil();
	virtual ~cTimeUtil();

	static uint32_t Time();

	static uint64_t TimeNanos();

	static uint32_t TimeAfter(int32_t elapsed);

	// Comparisons between time values, which can wrap around.
	static bool TimeIsLaterOrEqual(uint32_t earlier, uint32_t later);  				// Inclusive

	static bool TimeIsLater(uint32_t earlier, uint32_t later);  					// Exclusive

	static int32_t TimeDiff(uint32_t later, uint32_t earlier);

	static bool TimeIsBetween(uint32_t earlier, uint32_t middle, uint32_t later);

	static inline int32_t TimeUntil(uint32_t later) {
	  return TimeDiff(later, Time());
	}
};

} /* namespace end */
#endif /* CTIMEUTIL_H_ */
