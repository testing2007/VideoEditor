//
//  SSUndoManager.h
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-24.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SSAction;

@interface SSUndoManager : NSObject

@property(nonatomic, retain)NSMutableArray* arrUndo;
@property(nonatomic, retain)NSMutableArray* arrRedo;

-(void) doIt:(SSAction*)action;
-(void) removeAllData;
-(BOOL) undo:(SSAction**)action;
-(BOOL) redo:(SSAction**)action;
// -(SSAction*)getFirstMatchInfoFromUndoStack:(int)_nId;

@end
