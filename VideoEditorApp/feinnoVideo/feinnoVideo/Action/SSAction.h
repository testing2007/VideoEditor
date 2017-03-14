//
//  SSAction.h
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-24.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ActionOperator.h"

@class SSImageView;

typedef enum _ACTION_NAME
{
    UNKNOWN_ACTION,
    
    ADD_ACTION,
    MOVE_ACTION,
    ROTATE_ACTION,
    SCALE_ACTON,
    DELETE_ACTION,
}ACTION_NAME;
// const int INVALID_TARGET_ID = -1;

@interface SSAction : NSObject

@property(nonatomic) ACTION_NAME nId; //行为标识
//@property(nonatomic) int nTargetId;   //操作目标id
@property(nonatomic, retain) UIView<ActionOperator>* targetObject; //操作目标
@property(nonatomic) CGAffineTransform curTransform;
@property(nonatomic) CGAffineTransform prevTransform;

@end
