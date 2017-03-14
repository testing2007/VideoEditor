//
//  video_template_type.c
//  libSynthesis
//
//  Created by wzq on 14-9-15.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#include <stdio.h>
#include "video_template_types.h"

namespace feinnovideotemplate {
AssetType GetValueOfAssetType(const char* value) {
    if(strcmp(value, "VIDEO") == 0){
        return VIDEO;
    } else if(strcmp(value, "IMAGE") == 0){
        return IMAGE;
    } else if(strcmp(value, "AUDIO") == 0){
        return AUDIO;
    } else if(strcmp(value, "TITTLE") == 0){
        return TITTLE;
    }
    assert(false);
    return TITTLE;
}

std::string GetAssetTypeString(AssetType type) {
    switch(type) {
        case VIDEO:
            return "VIDEO";
        case IMAGE:
            return "IMAGE";
        case AUDIO:
            return "AUDIO";
        case TITTLE:
            return "TITTLE";
        default:
            assert(false);
            return "";
    }
}
}
