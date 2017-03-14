//
//  SSUndoManager.m
//  testPCEvent
//
//  Created by weizhiqiangzz on 12-12-24.
//  Copyright (c) 2012年 weizhiqiangzz. All rights reserved.
//

#import "SSUndoManager.h"
#import "SSAction.h"

@interface SSUndoManager ()
@end

@implementation SSUndoManager
@synthesize arrRedo;
@synthesize arrUndo;

-(SSUndoManager *)init
{
    self = [super init];
    if(self)
    {
        arrUndo = [[NSMutableArray alloc]init];
        arrRedo = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void) doIt:(SSAction*)action
{
   [arrUndo addObject:action];
   if([arrRedo count] > 0)
   {
       [arrRedo removeAllObjects];
   }
}

-(BOOL) undo:(SSAction**)action
{
    if([arrUndo count] > 0)
    {
        *action = [arrUndo lastObject];
        [arrRedo addObject:*action];
        [arrUndo removeLastObject];
    }
    return [arrUndo count]==0 ? NO : YES;
}

-(BOOL) redo:(SSAction**)action
{
   if([arrRedo count] > 0)
    {
        *action = [arrRedo lastObject];
        [arrUndo addObject:*action];
        [arrRedo removeLastObject];
    }
    return  [arrRedo count]==0 ? NO : YES;;
}

-(void) removeAllData
{
    [arrUndo removeAllObjects];
    [arrRedo removeAllObjects];
}

/*
-(SSAction*)getFirstMatchInfoFromUndoStack:(int)_nId
{
    int nCount = arrUndo.count;
    for(int i=arrUndo.count-1; i>=0; --i)
    {
        if(_nId == ((SSAction*)arrUndo[i]).nId)
        {
            return arrUndo[i];
        }
    }
    return nil;
}
//*/

@end
