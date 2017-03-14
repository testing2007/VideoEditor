/*
 * cMessageQueue.cpp
 *
 *  Created on: 2014-8-3
 *      Author: henryliu
 */

#include "cMessageQueue.h"
//#include "cEvent.h"
//#include <feinnoVideo/SynthesisParamterInstance.h>
//#include <feinnoVideo/SynthesisParameterInfo.h>

namespace webrtc {

const uint32 kMaxMsgLatency = 150;  // 150 ms

//////////////////////////////////////////////////
///	message queue
//
cMessageQueue::cMessageQueue() :
fStop_( false ),
fPeekKeep_( false ),
dmsgq_next_num_(0),
crit_(CriticalSectionWrapper::CreateCriticalSection())/*,
event_(cEvent::Create())*/{
	// TODO Auto-generated constructor stub

}

cMessageQueue::~cMessageQueue() {
	// TODO Auto-generated destructor stub
	//SignalQueueDestroyed();
	Clear(NULL);
}

//void cMessageQueue::SignalQueueDestroyed()
//{
//	//FireEvent(ID_EVENT_QUEUEDESTORYED,0,0,0);
//}

void cMessageQueue::Quit() {
  fStop_ = true;
}

bool cMessageQueue::IsQuitting() {
  return fStop_;
}

void cMessageQueue::Restart() {
  fStop_ = false;
}

bool cMessageQueue::Peek(Message *pmsg, int cmsWait) {
  if (fPeekKeep_) {
    *pmsg = msgPeek_;
    return true;
  }
  if (!Get(pmsg, cmsWait))
    return false;
  msgPeek_ = *pmsg;
  fPeekKeep_ = true;
  return true;
}

/*
bool cMessageQueue::Get( Message *pmsg, int cmsWait, bool process_io ){
  // Return and clear peek if present
  // Always return the peek if it exists so there is Peek/Get symmetry
  if (fPeekKeep_) {
    *pmsg = msgPeek_;
    fPeekKeep_ = false;
    return true;
  }

  // Get w/wait + timer scan / dispatch + socket / event multiplexer dispatch

  int cmsTotal = cmsWait;
  int cmsElapsed = 0;
  uint32_t msStart = cTimeUtil::Time();
  uint32_t msCurrent = msStart;

  // Check for sent messages

  // Check for posted events
  int cmsDelayNext = kForever;
  bool first_pass = true;
  while (true) {
      // All queue operations need to be locked, but nothing else in this loop
      // (specifically handling disposed message) can happen inside the crit.
      // Otherwise, disposed MessageHandlers will cause deadlocks.
	  {
		  CriticalSectionScoped cs(crit_);

		  // On the first pass, check for delayed messages that have been
		  // triggered and calculate the next trigger time.
		  if (first_pass) {
			first_pass = false;
			while (!dmsgq_.empty()) {
			  if (cTimeUtil::TimeIsLater(msCurrent, dmsgq_.top().msTrigger_)) {
				cmsDelayNext = cTimeUtil::TimeDiff(dmsgq_.top().msTrigger_, msCurrent);
				break;
			  }
			  msgq_.push_back(dmsgq_.top().msg_);
			  dmsgq_.pop();
			}
		  }
		  // Pull a message off the message queue, if available.
		  if (msgq_.empty()) {
			break;
		  } else {
			*pmsg = msgq_.front();
			msgq_.pop_front();
		  }
	  }

	  // Log a warning for time-sensitive messages that we're late to deliver.
	  if (pmsg->ts_sensitive) {
		int32 delay = cTimeUtil::TimeDiff(msCurrent, pmsg->ts_sensitive);
		if (delay > 0) {
		  //LOG_F(LS_WARNING) << "id: " << pmsg->message_id << "  delay: "
		  //                  << (delay + kMaxMsgLatency) << "ms";
		}
	  }
	  // If this was a dispose message, delete it and skip it.
	  if (MQID_DISPOSE == pmsg->message_id) {
		delete pmsg->pdata;
		*pmsg = Message();
		continue;
	  }

	  return true;
  }

  event_->Wait( cmsWait );
  return false;
}
*/

bool cMessageQueue::Get(Message *pmsg, int cmsWait, bool process_io) {
  // Return and clear peek if present
  // Always return the peek if it exists so there is Peek/Get symmetry

  if (fPeekKeep_) {
    *pmsg = msgPeek_;
    fPeekKeep_ = false;
    return true;
  }

  // Get w/wait + timer scan / dispatch + socket / event multiplexer dispatch

  int cmsTotal = cmsWait;
  int cmsElapsed = 0;
  uint32_t msStart = cTimeUtil::Time();
  uint32_t msCurrent = msStart;
  while (true) {
    // Check for sent messages

    // Check for posted events
    int cmsDelayNext = kForever;
    bool first_pass = true;
    while (true) {
      // All queue operations need to be locked, but nothing else in this loop
      // (specifically handling disposed message) can happen inside the crit.
      // Otherwise, disposed MessageHandlers will cause deadlocks.
      {
    	CriticalSectionScoped cs(crit_);
        // On the first pass, check for delayed messages that have been
        // triggered and calculate the next trigger time.
        if (first_pass) {
          first_pass = false;
          while (!dmsgq_.empty()) {
            if (cTimeUtil::TimeIsLater(msCurrent, dmsgq_.top().msTrigger_)) {
              cmsDelayNext = cTimeUtil::TimeDiff(dmsgq_.top().msTrigger_, msCurrent);
              break;
            }
            msgq_.push_back(dmsgq_.top().msg_);
            dmsgq_.pop();
          }
        }
        // Pull a message off the message queue, if available.
        if (msgq_.empty()) {
          break;
        } else {
          *pmsg = msgq_.front();
          msgq_.pop_front();
        }
      }  // crit_ is released here.

      // Log a warning for time-sensitive messages that we're late to deliver.
      if (pmsg->ts_sensitive) {
        int32_t delay = cTimeUtil::TimeDiff(msCurrent, pmsg->ts_sensitive);
        if (delay > 0) {
          //LOG_F(LS_WARNING) << "id: " << pmsg->message_id << "  delay: "
          //                  << (delay + kMaxMsgLatency) << "ms";
        }
      }
      // If this was a dispose message, delete it and skip it.
      if (MQID_DISPOSE == pmsg->message_id) {
        delete pmsg->pdata;
        *pmsg = Message();
        continue;
      }
      return true;
    }

    if (fStop_)
      break;

    // Which is shorter, the delay wait or the asked wait?

    int cmsNext;
    if (cmsWait == kForever) {
      cmsNext = cmsDelayNext;
    } else {
      cmsNext = std::max(0, cmsTotal - cmsElapsed);
      if ((cmsDelayNext != kForever) && (cmsDelayNext < cmsNext))
        cmsNext = cmsDelayNext;
    }

    // If the specified timeout expired, return

    msCurrent = cTimeUtil::Time();
    cmsElapsed = cTimeUtil::TimeDiff(msCurrent, msStart);
    if (cmsWait != kForever) {
      if (cmsElapsed >= cmsWait)
        return false;
    }
  }
  return false;
}
    
void cMessageQueue::Post( uint32 id,MessageData *pdata, bool time_sensitive) {
  if (fStop_)
    return;

  // Keep thread safe
  // Add the message to the end of the queue
  // Signal for the multiplexer to return

  CriticalSectionScoped cs(crit_);

  Message msg;
  msg.message_id = id;
  msg.pdata = pdata;
  if (time_sensitive) {
    msg.ts_sensitive = cTimeUtil::Time() + kMaxMsgLatency;
  }
  msgq_.push_back(msg);
//    Message msg1;
//    this->get(&msg1);
//    
//    TypedMessageData<SynthesisParamterInfo>* data = static_cast<TypedMessageData<SynthesisParamterInfo>*>(msg1->pdata);
    
//    Message msg1;
//    TypedMessageData<SynthesisParameterInfo>* message_data;
//    if(this->Get(&msg1))
//    {
//     message_data = static_cast<TypedMessageData<SynthesisParameterInfo>*>(msg1.pdata);
//    }

}

void cMessageQueue::DoDelayPost(int cmsDelay, uint32 tstamp,uint32 id, MessageData* pdata) {
  if (fStop_)
    return;

  // Keep thread safe
  // Add to the priority queue. Gets sorted soonest first.
  // Signal for the multiplexer to return.

  CriticalSectionScoped cs(crit_);
  Message msg;
  msg.message_id = id;
  msg.pdata = pdata;
  DelayedMessage dmsg(cmsDelay, tstamp, dmsgq_next_num_, msg);
  dmsgq_.push(dmsg);
}

int cMessageQueue::GetDelay() {
  CriticalSectionScoped cs(crit_);

  if (!msgq_.empty())
    return 0;

  if (!dmsgq_.empty()) {
    int delay = cTimeUtil::TimeUntil(dmsgq_.top().msTrigger_);
    if (delay < 0)
      delay = 0;
    return delay;
  }

  return kForever;
}

void cMessageQueue::Clear( uint32 id,MessageList* removed) {
  CriticalSectionScoped cs(crit_);

  // Remove messages with phandler

  if (fPeekKeep_ && msgPeek_.Match(id)) {
    if (removed) {
      removed->push_back(msgPeek_);
    } else {
      delete msgPeek_.pdata;
    }
    fPeekKeep_ = false;
  }

  // Remove from ordered message queue

  for (MessageList::iterator it = msgq_.begin(); it != msgq_.end();) {
    if (it->Match(id)) {
      if (removed) {
        removed->push_back(*it);
      } else {
        delete it->pdata;
      }
      it = msgq_.erase(it);
    } else {
      ++it;
    }
  }

  // Remove from priority queue. Not directly iterable, so use this approach

  PriorityQueue::container_type::iterator new_end = dmsgq_.container().begin();
  for (PriorityQueue::container_type::iterator it = new_end;
       it != dmsgq_.container().end(); ++it) {
    if (it->msg_.Match(id)) {
      if (removed) {
        removed->push_back(it->msg_);
      } else {
        delete it->msg_.pdata;
      }
    } else {
      *new_end++ = *it;
    }
  }
  dmsgq_.container().erase(new_end, dmsgq_.container().end());
  dmsgq_.reheap();
}

} /* namespace gtalk */
