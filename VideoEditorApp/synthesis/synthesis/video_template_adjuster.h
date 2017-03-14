//
//  video_template_adjuster.h
//  libSynthesis
//
//  Created by shangbocai on 14-9-14.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef __libSynthesis__video_template_adjuster__
#define __libSynthesis__video_template_adjuster__

#include <iostream>

#include <base/ObjcClass.h>

OBJC_CLASS(GPUImageFilter);

namespace feinnovideotemplate {

    class FilterAdjuster{
    private:
        FilterAdjuster();
        
    public:
        
        static void adjust(GPUImageFilter*  filter, int percentage);
    };
    
    
    
}
#endif /* defined(__libSynthesis__video_template_adjuster__) */
