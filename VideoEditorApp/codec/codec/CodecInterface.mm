//
//  CodecInterface.cpp
//  libCodec
//
//  Created by wangxiang on 14-9-13.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#include "CodecInterface.h"
#import "MediaSourceImp.h"
#import "MediaTargetImp.h"

IMediaSource *CreateMediaSource(const std::string &file_name) {
    return new CMediaSource(file_name);
}

IMediaTarget *CreateMediaTarget(const std::string &file_name) {
    return new CMediaTarget(file_name);
}
