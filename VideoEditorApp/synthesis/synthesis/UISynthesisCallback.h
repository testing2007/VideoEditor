//
//  UISynthesisCallback.h
//  libFeinnoVideo
//
//  Created by wzq on 14-9-24.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

//typedef enum _SYN_MESSAGE_ID
//{
//    SYN_MSG_UNKNOWN=0,
//    SYN_MSG_PREVIEW,
//    SYN_MSG_SAVE
//}SYN_MESSAGE_ID;

#import <Foundation/Foundation.h>
#import <base/SynthesisParameterInfo.h>

//@protocol UISynthesisCallback <NSObject>


@protocol UISynthesisCallback
-(void) proto_synProgress:(float)fPercent;
-(void) proto_synSuccess:(SYN_MESSAGE_ID)synMessageID;
-(void) proto_synFailure:(const char*)errorReason;
-(void) proto_synPause;
@end



// @end
