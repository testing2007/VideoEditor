//
//  ObjcClass.h
//  FeinnoVideoApp
//
//  Created by wzq on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef FeinnoVideoApp_ObjcClass_h
#define FeinnoVideoApp_ObjcClass_h

#include <objc/objc.h>
#ifdef __OBJC__
#define OBJC_CLASS(name) @class name
#else
#define OBJC_CLASS(name) typedef struct objc_object name
#endif

#endif
