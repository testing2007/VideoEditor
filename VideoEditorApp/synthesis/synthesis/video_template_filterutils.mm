/*
 * video_template_filterutils.cpp
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#include "video_template_filterutils.h"

#include "tinyxml2/tinyxml2.h"
#include "GPUImage.h"
#include "MyGPUImageFilter5.h"


namespace feinnovideotemplate {
using namespace tinyxml2;

Filter* FilterUtils::BuildFromXML(const string& id) {
    //文件路径
    //return BuildFromXML(InitUtil.getFilterPath() + id, "meta.xml");
    return BuildFromXML(id, "meta.xml");
}


Filter* FilterUtils::BuildFromXML(const string& filterPath, const string& metaName) {

    Filter *filter = new Filter();

    XMLDocument doc;
    string xml_file = filterPath + "/" + metaName;
    doc.LoadFile(xml_file.c_str());

    XMLElement *filter_node = doc.RootElement();
    //zhiqiang++ begin
    if(filter_node == NULL)
        return NULL;
    //zhiqiang++ end
    
    filter->set_id(filter_node->Attribute("ID"));
    filter->set_name(filter_node->Attribute("name"));
    filter->set_filter_type(filter_node->Attribute("filterType"));
    filter->set_percentage(filter_node->IntAttribute("percentage"));

    XMLElement *attachment_node = filter_node->FirstChildElement();
    const char* file_attribute = attachment_node->Attribute("file");
    if(file_attribute != NULL) {
        string filename = filterPath + "/" + file_attribute;
        filter->set_attachment(filename);
    }

    return filter;
}

    
    static GPUImageFilter* CreateGPUImageFilter(string filer_name){
        GPUImageFilter* gpufilter = nil;
        if(filer_name == "LOOKUP_AMATORKA"){
            gpufilter = [[GPUImageLookupFilter alloc] init];
        } else if (filer_name == "VEGNETTE"){
            gpufilter = [[GPUImageVignetteFilter alloc] init];
        } else if (filer_name == "BLEND_SCREEN"){
            gpufilter = [[GPUImageScreenBlendFilter alloc] init];
        } else if (filer_name == "GRAYSCALE"){
            gpufilter = [[GPUImageGrayscaleFilter alloc] init];
        } else if (filer_name == "EXPOSURE") {
            gpufilter = [[GPUImageExposureFilter alloc] init];
            [(GPUImageExposureFilter*)gpufilter setExposure:0.0f];
        } else if (filer_name == "PIXELATION") {
            gpufilter = [[GPUImagePixellateFilter alloc] init];
        } else if (filer_name == "BLEND_NORMAL") {
            gpufilter = [[GPUImageNormalBlendFilter alloc] init];
        } else if (filer_name == "TONE_CURVE") {
            NSString* srcPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/tone_cuver_sample.acv"];
            NSURL* acvurl = [[NSURL alloc] initFileURLWithPath:srcPath];
            gpufilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:acvurl];
        } else if (filer_name == "EMBOSS") {
            gpufilter = [[GPUImageEmbossFilter alloc] init];
        } else if (filer_name == "SOBEL_EDGE_DETECTION") {
            gpufilter = [[GPUImageSobelEdgeDetectionFilter alloc] init];
        } else if (filer_name == "SATURATION") {
            gpufilter = [[GPUImageSaturationFilter alloc] init];
            [(GPUImageSaturationFilter*)gpufilter setSaturation:1.0f];
        } else if (filer_name == "SEPIA") {
            gpufilter = [[GPUImageSepiaFilter alloc] init];
        } else if (filer_name == "BLEND_OVERLAY") {
            gpufilter = [[GPUImageOverlayBlendFilter alloc] init];
            
        } else if (filer_name == "BLEND_DARKEN") {
            gpufilter = [[GPUImageDarkenBlendFilter alloc] init];
            
        } else if (filer_name == "HUE") {
            gpufilter = [[GPUImageHueFilter alloc] init];
            [(GPUImageHueFilter*)gpufilter setHue:90.0f];
            
        } else if (filer_name == "VIGNETTE") {
            gpufilter = [[GPUImageVignetteFilter alloc] init];
            [(GPUImageVignetteFilter*)gpufilter setVignetteCenter:{.5f, .5f}];
             [(GPUImageVignetteFilter*)gpufilter setVignetteColor:{.0f, .0f, .0f}];
             [(GPUImageVignetteFilter*)gpufilter setVignetteStart:.3f];
             [(GPUImageVignetteFilter*)gpufilter setVignetteEnd:.75f];
            
        } else if (filer_name == "RGB" ) {
            gpufilter = [[GPUImageRGBFilter alloc] init];
            [(GPUImageRGBFilter*)gpufilter setRed:1.0f];
            [(GPUImageRGBFilter*)gpufilter setBlue:1.0f];
            [(GPUImageRGBFilter*)gpufilter setGreen:1.0f];
            
        } else if (filer_name == "MONOCHROME" ) {
            gpufilter = [[GPUImageMonochromeFilter alloc] init];
            
        } else if (filer_name == "INSTAINKWELL" ) {
            
            const GLchar *fragment_shader_source_insta_inkwell =
            {
                "const highp vec4 luminance_weight = vec4(0.3, 0.6, 0.1, 0.0);\n"
                
                "uniform sampler2D inputImageTexture;\n"
                
                "uniform sampler2D inputImageTexture2;\n"
                
                "varying highp vec2 textureCoordinate;\n"
                
                "void main(void) {\n"
                
                "  highp vec4 rgb = texture2D(inputImageTexture, textureCoordinate);\n"
                
                "  highp float luminance = dot(luminance_weight, rgb);\n"
                
                "  highp float result = texture2D(inputImageTexture2, vec2(luminance, 0.16666)).r;\n"
                
                "  gl_FragColor = vec4(result, result, result, 1.0);\n"
                
                "}\n"
            };

            NSString* fragment = [[NSString alloc] initWithFormat:@"%s", fragment_shader_source_insta_inkwell];
            gpufilter = [[GPUImageTwoInputFilter alloc] initWithVertexShaderFromString:kGPUImageVertexShaderString fragmentShaderFromString:fragment];
            
        } else if (filer_name == "INSTAEARLYBIRD" ) {
            gpufilter = [[MyGPUImageFilter5 alloc] init];
            
            
        } else if (filer_name == "INSTAHUDSON" ) {
            
            const GLchar *fragment_shader_source_insta_hudson =
            {
                "uniform sampler2D inputImageTexture;\n"
                
                "uniform sampler2D inputImageTexture2;\n"
                "uniform sampler2D inputImageTexture3;\n"
                "uniform sampler2D inputImageTexture4;\n"
                
                "varying highp vec2 textureCoordinate;\n"
                
                "void main(void) {\n"
                
                "  highp vec4 rgb = texture2D(inputImageTexture, textureCoordinate);\n"
                
                "  highp vec4 texel = texture2D(inputImageTexture2, textureCoordinate);\n"
                
                "  rgb.r = texture2D(inputImageTexture3, vec2(texel.r, rgb.r)).r;\n"
                "  rgb.g = texture2D(inputImageTexture3, vec2(texel.g, rgb.g)).g;\n"
                "  rgb.b = texture2D(inputImageTexture3, vec2(texel.b, rgb.b)).b;\n"
                
                "  highp vec4 color = vec4(texture2D(inputImageTexture4, vec2(rgb.r, 0.16666)).r, texture2D(inputImageTexture4, vec2(rgb.g, 0.5)).g, texture2D(inputImageTexture4, vec2(rgb.b, 0.83333)).b, 1.0);\n"
                
                "  gl_FragColor = color;\n"
                
                "}\n"
            };
            
            gpufilter = [[MyGPUImageFilter5 alloc]
                                           initWithFragmentShaderFromString:[[NSString alloc] initWithFormat:@"%s",fragment_shader_source_insta_hudson]];
            
            
        } else if (filer_name == "INSTAHEFE" ) {
            
            
            const GLchar *fragment_shader_source_insta_hefe =
            {
                "uniform sampler2D inputImageTexture;\n"
                
                "uniform sampler2D inputImageTexture2;\n"
                "uniform sampler2D inputImageTexture3;\n"
                "uniform sampler2D inputImageTexture4;\n"
                "uniform sampler2D inputImageTexture5;\n"
                
                "varying highp vec2 textureCoordinate;\n"
                
                "void main(void) {\n"
                
                "  highp vec4 rgb = texture2D(inputImageTexture, textureCoordinate);\n"
                
                "  highp vec4 edge = texture2D(inputImageTexture2, textureCoordinate);\n"
                
                "  highp vec3 texel = rgb.rgb * edge.rgb;\n"
                
                "  texel = vec3(texture2D(inputImageTexture3, vec2(texel.r, 0.16666)).r, texture2D(inputImageTexture3, vec2(texel.g, 0.5)).g, texture2D(inputImageTexture3, vec2(texel.b, 0.83333)).b);\n"
                
                "  highp vec3 metaled = texture2D(inputImageTexture5, textureCoordinate).rgb;\n"
                
                "  rgb = vec4(texture2D(inputImageTexture4, vec2(metaled.r, texel.r)).r, texture2D(inputImageTexture4, vec2(metaled.g, texel.g)).g, texture2D(inputImageTexture4, vec2(metaled.b, texel.b)).b, 1.0);\n"
                
                "  gl_FragColor = rgb;\n"
                
                "}\n"
            };
            NSString* fragment = [[NSString alloc] initWithFormat:@"%s", fragment_shader_source_insta_hefe];
            gpufilter = [[MyGPUImageFilter5 alloc] initWithFragmentShaderFromString:fragment];
            
        } else if (filer_name == "INSTAKELVIN" ) {
            
            const GLchar *fragment_shader_source_insta_kelvin =
            {
                "uniform sampler2D inputImageTexture;\n"
                
                "uniform sampler2D inputImageTexture2;\n"
                
                "varying highp vec2 textureCoordinate;\n"
                
                "void main(void) {\n"
                
                "  highp vec4 rgb = texture2D(inputImageTexture, textureCoordinate);\n"
                
                "  rgb.r = texture2D(inputImageTexture2, vec2(rgb.r, 0.5)).r;\n"
                "  rgb.g = texture2D(inputImageTexture2, vec2(rgb.g, 0.5)).g;\n"
                "  rgb.b = texture2D(inputImageTexture2, vec2(rgb.b, 0.5)).b;\n"
                
                "  gl_FragColor = rgb;\n"
                
                "}\n"
            };
            NSString* fragment = [[NSString alloc] initWithFormat:@"%s", fragment_shader_source_insta_kelvin];
            gpufilter = [[GPUImageTwoInputFilter alloc] initWithVertexShaderFromString:kGPUImageVertexShaderString fragmentShaderFromString:fragment];
            
        } else if (filer_name == "INSTALOFI" ) {
            const GLchar *fragment_shader_source_insta_lo_fi =
            {
                "uniform sampler2D inputImageTexture;\n"
                
                "uniform sampler2D inputImageTexture2;\n"
                "uniform sampler2D inputImageTexture3;\n"
                
                "varying highp vec2 textureCoordinate;\n"
                
                "void main(void) {\n"
                
                "  highp vec4 rgb = texture2D(inputImageTexture, textureCoordinate);\n"
                
                "  rgb.r = texture2D(inputImageTexture2, vec2(rgb.r, 0.16666)).r;\n"
                "  rgb.g = texture2D(inputImageTexture2, vec2(rgb.g, 0.5)).g;\n"
                "  rgb.b = texture2D(inputImageTexture2, vec2(rgb.b, 0.83333)).b;\n"
                
                "  highp vec2 tc = 2.0 * textureCoordinate - 1.0;\n"
                
                "  highp float d = dot(tc, tc);\n"
                
                "  rgb.r = texture2D(inputImageTexture3, vec2(d, rgb.r)).r;\n"
                "  rgb.g = texture2D(inputImageTexture3, vec2(d, rgb.g)).g;\n"
                "  rgb.b = texture2D(inputImageTexture3, vec2(d, rgb.b)).b;\n"
                
                "  gl_FragColor = rgb;\n"
                
                "}\n"
            };
            NSString* fragment = [[NSString alloc] initWithFormat:@"%s", fragment_shader_source_insta_lo_fi];
            gpufilter = [[MyGPUImageFilter5 alloc] initWithFragmentShaderFromString:fragment];
            
        } else if (filer_name == "TOON" ) {
            gpufilter = [[GPUImageToonFilter alloc] init];
            
        } else if (filer_name == "ZOOMBLUR" ) {
            gpufilter = [[GPUImageZoomBlurFilter alloc] init];
            
        } else if (filer_name == "" ) {
            
        }
        
        
        
        return gpufilter;
    }
    
GPUImageFilter* FilterUtils::GenGPUImageFilter(Filter* filter) {

    GPUImageFilter* gpuImageFilter = nil;
    if("BLANK" == filter->filter_type()){
        return [[GPUImageFilter alloc] init];
    }
  
     //   Context context = VideoBeautifyContext.getInstance().getmContext();
        // 暂定滤镜类型为枚举
       // FilterType type = FilterType.valueOf(filter->filter_type());

       // gpuImageFilter = GPUImageFilterTools.createFilterForType(context, type);

//          // 设置滤镜可调参数
//          FilterAdjuster adjuster = new GPUImageFilterTools.FilterAdjuster(gpuImageFilter);
//          if (adjuster != null) {
//              adjuster.adjust(filter.getPercentage());
//          }
        
        gpuImageFilter = CreateGPUImageFilter(filter->filter_type());
        
        

 //   unsigned char* buf = filter->attach_image();

    // 设置混合型滤镜的附加资源,在处理图像时再用Filter添加一个输入
//       if ([gpuImageFilter isKindOfClass:GPUImageTwoInputFilter.class]) {
//            if(filter->attach_image() != NULL){
//                [(GPUImageTwoInputFilter*)gpuImageFilter setInputFramebuffer:filter->attach_image() atIndex:1 ];
//            }
//            if (filter->attachment() != NULL) {
//                unsigned char* image = BitmapFactory.decodeFile(filter.getAttachment().getPath());
//                ((GPUImageTwoInputFilter) gpuImageFilter).setBitmap(image);
//            }
//            if (filter->attach_id() > 0) {
//                unsigned char* image = BitmapFactory.decodeResource(context.getResources(), filter.getAttachId());
//                ((GPUImageTwoInputFilter) gpuImageFilter).setBitmap(image);
//            }
//       }
  
    assert(gpuImageFilter != nil);

    return gpuImageFilter;
}

Filter* FilterUtils::BuildWatermarkFilter() {

    // Filter filter = buildFromXML("", "WatermarkFilter.xml");
    Filter *filter = new Filter();

    filter->set_id("WatermarkFilter");
    filter->set_name("WatermarkFilter");
    filter->set_filter_type("BLEND_ALPHA");
   // filter.set_attach_id(R.drawable.logo); //fixme
    filter->set_fade_in(1000);

    return filter;
}

Filter* FilterUtils::BuildTittleFilter() {
    Filter *filter = new Filter();
    filter->set_id("TittleFilter");
    filter->set_name("TittleFilter");
    filter->set_filter_type("BLEND_ALPHA");
    filter->set_fade_in(1000);
    filter->set_fade_out(1000);

    return filter;
}

Filter* FilterUtils::BuildDecorateFilter() {
    Filter *filter = new Filter();
    filter->set_id("DecorateFilter");
    filter->set_name("DecorateFilter");
    filter->set_filter_type("BLEND_NORMAL");

    return filter;
}

Filter* FilterUtils::BuildBlankFilter() {
    Filter *filter = new Filter();
    filter->set_id("balnkFilter");
    filter->set_name("balnkFilter");
    filter->set_filter_type("BLANK");
    filter->set_duration(250);

    return filter;
}



} /* namespace feinnovideotemplate */
