/*
 * cMessageQueue.h
 *
 *  Created on: 2014-8-3
 *      Author: henryliu
 */

#ifndef CMESSAGEQUEUE_H_
#define CMESSAGEQUEUE_H_

#include <algorithm>
#include <cstring>
#include <list>
#include <queue>
#include <vector>
#include "typedefs.h"
#include "scoped_ptr.h"
#include "scoped_ref_ptr.h"
#include "critical_section_wrapper.h"
#include "cTimeUtil.h"

using namespace webrtc;

namespace webrtc {

struct Message;
class cMessageQueue;
//class cEvent;
//
//#define	ID_EVENT_QUEUEDESTORYED					0x0010

const uint32_t MQID_ANY 	= static_cast<uint32_t>(-1);
const uint32_t MQID_DISPOSE = static_cast<uint32_t>(-2);

class MessageData {
 public:
  MessageData() {}
  virtual ~MessageData() {}
};

template <class T>
class TypedMessageData : public MessageData {
 public:
  explicit TypedMessageData(const T& data) : data_(data) { }
  const T& data() const { return data_; }
  T& data() { return data_; }
 private:
  T data_;
};

// Like TypedMessageData, but for pointers that require a delete.
template <class T>
class ScopedMessageData : public MessageData {
 public:
  explicit ScopedMessageData(T* data) : data_(data) { }
  const scoped_ptr<T>& data() const { return data_; }
  scoped_ptr<T>& data() { return data_; }
 private:
  scoped_ptr<T> data_;
};

// Like ScopedMessageData, but for reference counted pointers.
template <class T>
class ScopedRefMessageData : public MessageData {
 public:
  explicit ScopedRefMessageData(T* data) : data_(data) { }
  const scoped_refptr<T>& data() const { return data_; }
  scoped_refptr<T>& data() { return data_; }
 private:
  scoped_refptr<T> data_;
};

template<class T>
inline MessageData* WrapMessageData(const T& data) {
  return new TypedMessageData<T>(data);
}

template<class T>
inline const T& UseMessageData(MessageData* data) {
  return static_cast< TypedMessageData<T>* >(data)->data();
}

template<class T>
class DisposeData : public MessageData {
 public:
  explicit DisposeData(T* data) : data_(data) { }
  virtual ~DisposeData() { delete data_; }
 private:
  T* data_;
};

typedef struct Message {
  Message() {
    memset(this, 0, sizeof(*this));
  }
  inline bool Match( uint32_t id ) const {
    return (id == MQID_ANY || id == message_id);
  }

  uint32_t 			message_id;
  MessageData*		pdata;
  uint32_t 			ts_sensitive;
}Message;

typedef std::list<Message> MessageList;

// DelayedMessage goes into a priority queue, sorted by trigger time.  Messages
// with the same trigger time are processed in num_ (FIFO) order.

class DelayedMessage {
 public:
  DelayedMessage(int delay, uint32_t trigger, uint32_t num, const Message& msg)
  : cmsDelay_(delay), msTrigger_(trigger), num_(num), msg_(msg) { }

  bool operator< (const DelayedMessage& dmsg) const {
    return (dmsg.msTrigger_ < msTrigger_)
           || ((dmsg.msTrigger_ == msTrigger_) && (dmsg.num_ < num_));
  }

  int 			cmsDelay_;  // for debugging
  uint32_t 		msTrigger_;
  uint32_t 		num_;
  Message 		msg_;
};

class cMessageQueue //: public IDispEventImpl
{
public:
	cMessageQueue();
	virtual ~cMessageQueue();

	// Note: The behavior of MessageQueue has changed.  When a MQ is stopped,
	// futher Posts and Sends will fail.  However, any pending Sends and *ready*
	// Posts (as opposed to unexpired delayed Posts) will be delivered before
	// Get (or Peek) returns false.  By guaranteeing delivery of those messages,
	// we eliminate the race condition when an MessageHandler and MessageQueue
	// may be destroyed independently of each other.
	virtual void Quit();
	virtual bool IsQuitting();
	virtual void Restart();

	// Get() will process I/O until:
	//  1) A message is available (returns true)
	//  2) cmsWait seconds have elapsed (returns false)
	//  3) Stop() is called (returns false)
	virtual bool Get(Message *pmsg, int cmsWait = kForever,bool process_io = true);
	virtual bool Peek(Message *pmsg, int cmsWait = 0);
	virtual void Post( uint32_t id = 0,MessageData *pdata = NULL, bool time_sensitive = false);
	virtual void PostDelayed(int cmsDelay, uint32_t id = 0, MessageData *pdata = NULL) {
	  return DoDelayPost(cmsDelay, cTimeUtil::TimeAfter(cmsDelay), id, pdata);
	}

	virtual void PostAt(uint32_t tstamp,uint32_t id = 0, MessageData *pdata = NULL) {
	  return DoDelayPost( cTimeUtil::TimeUntil(tstamp), tstamp, id, pdata);
	}

	virtual void Clear( uint32_t id = MQID_ANY,MessageList* removed = NULL);

	// Amount of time until the next message can be retrieved
	virtual int GetDelay();

	bool empty() const { return size() == 0u; }
	size_t size() const {
	  CriticalSectionScoped cs(crit_);// msgq_.size() is not thread safe.
	  return msgq_.size() + dmsgq_.size() + (fPeekKeep_ ? 1u : 0u);
	}

	// Internally posts a message which causes the doomed object to be deleted
	template<class T> void Dispose(T* doomed) {
	  if (doomed) {
	    Post(NULL, MQID_DISPOSE, new DisposeData<T>(doomed));
	  }
	}

	// When this signal is sent out, any references to this queue should
	// no longer be used.
	//sigslot::signal0<> SignalQueueDestroyed;
	// void SignalQueueDestroyed();
protected:
	class PriorityQueue : public std::priority_queue<DelayedMessage> {
	 public:
	  container_type& container() { return c; }
	  void reheap() { make_heap(c.begin(), c.end(), comp); }
	};

	void DoDelayPost(int cmsDelay, uint32_t tstamp, uint32_t id, MessageData* pdata);

	// If a server isn't supplied in the constructor, use this one.

	bool 					fStop_;
	bool 					fPeekKeep_;
	Message	 				msgPeek_;

	// A message queue is active if it has ever had a message posted to it.
	// This also corresponds to being in MessageQueueManager's global list.
	MessageList 					msgq_;
	PriorityQueue 					dmsgq_;
	uint32_t 						dmsgq_next_num_;
	mutable CriticalSectionWrapper*	crit_;
	//cEvent*							event_;
private:
	DISALLOW_COPY_AND_ASSIGN(cMessageQueue);
};

} /* namespace gtalk */
#endif /* CMESSAGEQUEUE_H_ */
