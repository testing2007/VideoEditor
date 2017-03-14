//
//  video_template_adjuster.cpp
//  libSynthesis
//
//  Created by shangbocai on 14-9-14.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#include "video_template_adjuster.h"
#include <GPUImage.h>

namespace feinnovideotemplate {
    
 static   float range(const int percentage, const float start,
                const float end) {
        return (end - start) * percentage / 100.0f + start;
    }

    void FilterAdjuster::adjust(GPUImageFilter*  filter, int percentage){
        if([(GPUImageFilter*)filter isKindOfClass:GPUImageGrayscaleFilter.class]){
            
        } else if([(GPUImageFilter*)filter isKindOfClass:GPUImageExposureFilter.class]) {
            [(GPUImageExposureFilter*)filter setExposure:range(percentage, -10.0, 10.0)];
        } else if([filter isKindOfClass:GPUImagePixellateFilter.class]) {
            [(GPUImagePixellateFilter*)filter setFractionalWidthOfAPixel:range(percentage, 0.01f, 0.1f)];
        }
        else if([filter isKindOfClass:GPUImageSaturationFilter.class]) {
            [( GPUImageSaturationFilter*)filter setSaturation: range(percentage , 0.0f , 2.0f )];
        }
        else if([filter isKindOfClass: GPUImageSobelEdgeDetectionFilter.class]) {
            /// fixme 与安卓不一样，无对应参数。效果需调试
            [( GPUImageSobelEdgeDetectionFilter*)filter setTexelWidth: range( percentage, 0.002f , .02f )];
            [( GPUImageSobelEdgeDetectionFilter*)filter setTexelHeight:range( percentage, 0.002f , .02f )];
            
            [( GPUImageSobelEdgeDetectionFilter*)filter setEdgeStrength:range( percentage, 1.0f , 3.0f )];
        }
        else if([filter isKindOfClass: GPUImageHueFilter.class]) {
            [( GPUImageHueFilter*)filter setHue: range( percentage,  .0f,  360.0f)];
        }
        else if([filter isKindOfClass: GPUImageEmbossFilter.class]) {
            [( GPUImageEmbossFilter*)filter setIntensity: range( percentage, .0f , 4.0f )];
        }
        else if([filter isKindOfClass: GPUImageVignetteFilter.class]) {
            [( GPUImageVignetteFilter*)filter setVignetteStart:range( percentage, 0.0f , 1.0f )];
        }
        else if([filter isKindOfClass: GPUImageRGBFilter.class]) {
            [(GPUImageRGBFilter*)filter setRed: range( percentage, 0.0f , 1.0f )];
        }
        else if([filter isKindOfClass: GPUImageMonochromeFilter.class]) {
            [( GPUImageMonochromeFilter*)filter setIntensity:range( percentage, .0f , 1.0f )];
        }
        else if([filter isKindOfClass: GPUImageToonFilter.class]) {
            [( GPUImage3x3TextureSamplingFilter*)filter setTexelWidth:range( percentage, .0f / 480.0f , 5.0f / 480.0f )];
            [( GPUImage3x3TextureSamplingFilter*)filter setTexelHeight:range( percentage,.0f / 480.0f , 5.0f / 480.0f )];
        }
        else if([filter isKindOfClass: GPUImageZoomBlurFilter.class]) {
            [( GPUImageZoomBlurFilter*)filter setBlurSize:range( percentage, .0f , 10.0f )];
        }
//        else if([filter isKindOfClass: .class]) {
//            [( *)filter set  range( percentage,  ,  )];
//        }
//        else if([filter isKindOfClass: .class]) {
//            [( *)filter set  range( percentage,  ,  )];
//        }
//        else if([filter isKindOfClass: .class]) {
//            [( *)filter set  range( percentage,  ,  )];
//        }
        
    }
    
    

}