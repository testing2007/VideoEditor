/*
 * video_template_videotemplateutils.cpp
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#include "video_template_videotemplateutils.h"

#include <list>
#include <cassert>
#include "tinyxml2/tinyxml2.h"

#include "video_template_timelinenode.h"
#include "video_template_assetmgr.h"
#include "video_template_filtergroup.h"
#include "video_template_filterutils.h"
#include "video_template_imageseqasset.h"
#include "video_template_mediamgr.h"

#include <CoreGraphics/CoreGraphics.h>
#include <CoreGraphics/CGImage.h>
#import <UIKit/UIImage.h>

#import <GPUImage.h>

namespace feinnovideotemplate {
using std::list;
using namespace tinyxml2;

bool VideoTemplateUtils::ADD_WATERMARK = false;

VideoTemplateUtils::VideoTemplateUtils() {
    // TODO Auto-generated constructor stub

}

VideoTemplateUtils::~VideoTemplateUtils() {
    // TODO Auto-generated destructor stub
}


/**
 * 创建一个简单自定义模板，仅包含指定滤镜操作
 *
 * @param filterId
 * @return
 */
VideoTemplate* VideoTemplateUtils::CreateSimpleTemplate(const string& filterId) {

    VideoTemplate *simpleTemplate = new VideoTemplate();
    simpleTemplate->set_id("filter" + filterId);
    simpleTemplate->set_name("simpleTemplate");
    simpleTemplate->set_width(480);
    simpleTemplate->set_height(480);

    TimeLineNode *renderTree = new TimeLineNode();
    renderTree->set_id("root");
    renderTree->set_name("root");

    list<TimeLineNode*> nodeList;
    TimeLineNode* tn = new TimeLineNode();
    nodeList.push_back(tn);
    renderTree->set_child_node_list(nodeList);

    simpleTemplate->set_render_tree(renderTree);

    TimeLineNode *videoTrackNode = new TimeLineNode();
    videoTrackNode->set_node_type(VIDEO_TRACK);
//fixme ??? 翻译java不知对否,下面用到nodeList同样问题
    videoTrackNode->set_child_node_list(nodeList);


    renderTree->child_node_list().push_back(videoTrackNode);

    TimeLineNode *videoNode = new TimeLineNode();
    videoNode->set_node_type(VIDEO_NODE);
    // videoNode->setNodeData(videoClip);
    videoNode->set_child_node_list(nodeList);

    videoTrackNode->child_node_list().push_back(videoNode);

    TimeLineNode *filterNode = new TimeLineNode();
    filterNode->set_node_type(FILER_NODE);
    FilterGroup *filterGroup = new FilterGroup();
    //fixme 文件路径
    string filepath;
    Filter *filter = FilterUtils::BuildFromXML(filepath + filterId, "meta.xml");
    filter->set_duration(250);
    filterGroup->AddFilter(filter);
    filterNode->set_node_data(filterGroup);

    videoNode->child_node_list().push_back(filterNode);

    // templateCache->put(templateId, simpleTemplate);

    return simpleTemplate;
}

static void SplitString(list<string>& list, string text, char separator) {
    while(1)
    {
        int pos = (int)text.find(separator);
        if( pos == 0)
        {
            text = text.substr(1);
            continue;
        }
        if( pos < 0)
        {
                list.push_back(text);
                break;
        }
        string word = text.substr(0,pos);
        text = text.substr(pos+1);
        list.push_back(word);
    }
}

//解析filer，并加入到filerGroup。
static void ParseFilterNode(FilterGroup* filter_group,  XMLElement *node, const string& videoTemplatePath){

  string FilterID = node->Attribute("FilterID");

  Filter *filter = FilterUtils::BuildFromXML(videoTemplatePath, FilterID + ".xml");
  //zhiqiang++ begin
  if(NULL==filter)
  {
      return ;
  }
  //zhiqiang++ end
    
  filter->set_duration((long)(node->DoubleAttribute("totalframe")));
  filter->set_offset((long)(node->DoubleAttribute("In")));


  // /////////////////
  const char* szAttachType = (const char*)(node->Attribute("attachType"));
  string attachType = (szAttachType == NULL) ? std::string("") : std::string(szAttachType);
  // 滤镜附件类型，支持图片序列和视频
  AssetType type = IMAGE;
  if (attachType.length() > 0) {
      type = GetValueOfAssetType(attachType.c_str());
      filter->set_asset(AssetMgr::BuildAsset(type, ""));
  }

  XMLElement *node1 = node->FirstChildElement();
  if(node1 != NULL) {
      const char* szFile = (const char*)node1->Attribute("file");
      string files = (szFile==NULL)? std::string("") : std::string(szFile);
      if(filter->GetAssetType() == IMAGE) {
          list<string> file_name_list;
          SplitString(file_name_list, files, ',');

          list<string> image_uri_list;
          for(list<string>::iterator iter = file_name_list.begin();
                  iter != file_name_list.end(); iter++) {
              image_uri_list.push_back(videoTemplatePath +"/" +iter->c_str() );
          }
          ((ImageSeqAsset*)(filter->asset()))->set_image_uri_list(image_uri_list);
      } else {
          string filename = videoTemplatePath + "/" + files;
          filter->asset()->set_uri(filename);
      }
  }

  filter_group->AddFilter(filter);
}


static void ParseMediaNode(TimeLineNode* mediaNode,  XMLElement *node, const string& videoTemplatePath){

    mediaNode->set_id( node->Attribute("id"));
    mediaNode->set_name(node->Attribute("name"));
    // ///////////////////////////////////////////////////////////////
    string mediaType = node->Attribute("MediaType");
    if (mediaType.compare("1") == 0) {
        mediaNode->set_node_type(VIDEO_NODE);
    } else {
        mediaNode->set_node_type(IMAGE_NODE);
    }
    // ////////////////////////////////////////////////////////////////
    mediaNode->set_offset((long)( node->IntAttribute("In")));
    mediaNode->set_duration((long)(node->IntAttribute("totalframe")));


    XMLElement *node1 = node->FirstChildElement();
    if(node1 == NULL) return;

    // 只有一个filterNode，拥有一个filterGroup来存放所有filter（xml定义的是filter）。
    FilterGroup *filter_group = new FilterGroup();
    TimeLineNode *filterNode = new TimeLineNode();
    filterNode->set_node_type(FILER_NODE);

    while(node1) {
        ParseFilterNode(filter_group, node1,videoTemplatePath);
        node1 = node1->NextSiblingElement();
    }
    filterNode->set_node_data(filter_group);
    mediaNode->child_node_list().push_back(filterNode);
}

static void ParseVideoTrack(TimeLineNode* track,  XMLElement *node, const string& videoTemplatePath){

    XMLElement *node1 = node->FirstChildElement();
    while(node1 != NULL) {
        TimeLineNode *mediaNode = new TimeLineNode();
        ParseMediaNode(mediaNode, node1,videoTemplatePath);
        track->child_node_list().push_back(mediaNode);

        node1 = node1->NextSiblingElement();
    }
}


static void ParseAudioNode(TimeLineNode* audioNode,  XMLElement *node, const string& videoTemplatePath){
    audioNode->set_id(node->Attribute("id"));
    audioNode->set_name(node->Attribute("name"));
    audioNode->set_node_type(AUDIO_TRACK);
    audioNode->set_offset((long)node->DoubleAttribute("In"));
    audioNode->set_duration((long)node->DoubleAttribute("totalframe"));

    XMLElement *node1 = node ->FirstChildElement();
    if(node1 != NULL) {
        string file_name = node1->Attribute("file");
        if(file_name.length() > 0) {
            string uri = videoTemplatePath + "/" +file_name;
            AudioAsset *asset = (AudioAsset*) AssetMgr::BuildAsset(AUDIO, uri);
            MediaClip *audio = MediaMgr::BuildMediaClip(asset, audioNode->offset(), audioNode->duration());
            audioNode->set_node_data(audio);
        }
    }
}

VideoTemplate* VideoTemplateUtils::BuildFromXML(const string& id) {

    VideoTemplate *videoTemplate = new VideoTemplate(id);
    // 模板存放的路径
    string videoTemplatePath = id;
    string videoTemplateFile = videoTemplatePath + "/" + "meta.xml";
    XMLDocument doc;
    XMLError xmlerr = doc.LoadFile(videoTemplateFile.c_str());
    assert(xmlerr == XMLError::XML_SUCCESS);

    TimeLineNode *videoTrack;// = null;
 //   TimeLineNode *mediaNode;// = null;
 //   Filter *filter;// = null;
 //   FilterGroup *filterGroup;// = null;

    TimeLineNode *audioTrack;// = null;
  //  TimeLineNode *audioNode;// = null;

    //根节点是RootNode
    XMLElement *root = doc.RootElement();
    assert(strcmp("RootNode", root->Name()) == 0);

   // videoTemplate->set_name(root->Attribute("name"));
    videoTemplate->set_total_frame((long)root->DoubleAttribute("totalframe"));
    videoTemplate->set_frame_rate(root->IntAttribute("framerate"));

    string framesize = root->Attribute("framesize");
    int splitIndex = (int)framesize.find_first_of("-");
    string width = framesize.substr(0,splitIndex);
    string height = framesize.substr(splitIndex + 1, framesize.length() - splitIndex -1);
    videoTemplate->set_width(atoi(width.c_str()));
    videoTemplate->set_height(atoi(height.c_str()));

    // XXX 有些初始化可能没必要，值类型不会为空，不是指针
    TimeLineNode *renderTree = new TimeLineNode();
    videoTemplate->set_render_tree(renderTree);
//    list<TimeLineNode*> trackList;// = new ArrayList<TimeLineNode>();
//    renderTree->set_child_node_list(trackList);


    XMLElement *node1 = root->FirstChildElement();
    while(node1 != NULL) {
        if(strcmp( node1->Name(), "VideoTrack") == 0) {
            videoTrack = new TimeLineNode();
            videoTrack->set_node_type(VIDEO_TRACK);
            ParseVideoTrack(videoTrack, node1,videoTemplatePath);

            videoTemplate->render_tree()->child_node_list().push_back(videoTrack);
        } else if (strcmp( node1->Name(), "AudioTrack") == 0) {
            audioTrack = new TimeLineNode();
            audioTrack->set_node_type(AUDIO_TRACK);

            XMLElement *node2 = node1->FirstChildElement();
            if(node2 != NULL) {
                while(node2 != NULL) {
                    TimeLineNode *an = new TimeLineNode();
                    ParseAudioNode(an, node2,videoTemplatePath);
                    audioTrack->child_node_list().push_back(an);
                    
                    node2 = node2->NextSiblingElement();
                }
            }

           videoTemplate->render_tree()->child_node_list().push_back(audioTrack);
        }
        node1 = node1->NextSiblingElement();
    }

    return videoTemplate;
}

void VideoTemplateUtils::AddWatermarkNode( VideoTemplate* videoTemplate) {
    TimeLineNode *videoTrack = NULL;
    list<TimeLineNode*>::iterator iterator = videoTemplate->render_tree()->child_node_list().begin();
    for (; iterator != videoTemplate->render_tree()->child_node_list().end();) {
        TimeLineNode *temp = *iterator;
        if (temp->node_type() == VIDEO_TRACK) {
            videoTrack = temp;
            break;
        }
    }
    assert(videoTrack != NULL);

    //取最后一个？？
    TimeLineNode *videoNode = *(videoTrack->child_node_list().rbegin());

    //取videoNode第一个
    FilterGroup *filter = (FilterGroup*)(*(videoNode->child_node_list().begin()))->node_data();

//    Filter *lastFilter = *(filter->filters().rbegin());
//    //type 是 BLEND 开头
//    if (lastFilter->filter_type().find_first_of("BLEND") == 0) {
//        Filter *blank = FilterUtils::BuildBlankFilter();
//        blank->set_offset(videoTemplate->total_frame() - WATERMARK_DURATION);
//        blank->set_duration(WATERMARK_DURATION);
//        filter->AddFilter(blank);
//    }

    Filter *watermark  = FilterUtils::BuildWatermarkFilter();
    watermark->set_offset(videoTemplate->total_frame() - WATERMARK_DURATION);
    watermark->set_duration(WATERMARK_DURATION);
    watermark->set_fade_in((int)WATERMARK_DURATION);
    filter->AddFilter(watermark);

}

VideoTemplate* VideoTemplateUtils::CreateBlankTemplate() {

    //
    VideoTemplate *simpleTemplate = new VideoTemplate();
    simpleTemplate->set_id("0");
    simpleTemplate->set_name("blankTemplate");
    simpleTemplate->set_width(480);
    simpleTemplate->set_height(480);

    TimeLineNode *renderTree = new TimeLineNode();
    renderTree->set_id("root");
    renderTree->set_name("root");
    simpleTemplate->set_render_tree(renderTree);

    TimeLineNode *videoTrackNode = new TimeLineNode();
    videoTrackNode->set_node_type(VIDEO_TRACK);
    
    renderTree->child_node_list().push_back(videoTrackNode);

    TimeLineNode *videoNode = new TimeLineNode();
    videoNode->set_node_type(VIDEO_NODE);
    // videoNode.setNodeData(videoClip);
   
    videoTrackNode->child_node_list().push_back(videoNode);

    TimeLineNode *filterNode = new TimeLineNode();
    filterNode->set_node_type(FILER_NODE);
    FilterGroup *filterGroup = new FilterGroup();
    /*Filter filter = FilterUtils.buildBlankFilter();
    filter.setDuration(250);
    filterGroup.addFilter(filter);*/
    filterNode->set_node_data(filterGroup);

    videoNode->child_node_list().push_back(filterNode);


    return simpleTemplate;
}
    
    
    
unsigned char* VideoTemplateUtils::GetDataFromImgFile(string& imagePath){
        
        NSURL *url = [[NSURL alloc]initFileURLWithPath:[[NSString alloc] initWithFormat:@"%s", imagePath.c_str()]];
        
        NSData *image_data = [[NSData alloc] initWithContentsOfURL:url];
        UIImage *inputimage = [[UIImage alloc] initWithData:image_data];
        CGImageRef newImageSource = [inputimage CGImage];
        
        
        // TODO: Dispatch this whole thing asynchronously to move image loading off main thread
        CGFloat widthOfImage = CGImageGetWidth(newImageSource);
        CGFloat heightOfImage = CGImageGetHeight(newImageSource);
        
        // If passed an empty image reference, CGContextDrawImage will fail in future versions of the SDK.
        
        assert(widthOfImage > 0 && heightOfImage > 0);
        //  NSAssert(widthOfImage > 0 && heightOfImage > 0, @"Passed image must not be empty - it should be at least 1px tall and wide");
        
        CGSize pixelSizeOfImage = CGSizeMake(widthOfImage, heightOfImage);
  //      CGSize pixelSizeToUseForTexture = pixelSizeOfImage;
        
   //     BOOL shouldRedrawUsingCoreGraphics = NO;
        
        // For now, deal with images larger than the maximum texture size by resizing to be within that limit
    //    CGSize scaledImageSizeToFitOnGPU = [GPUImageContext sizeThatFitsWithinATextureForSize:pixelSizeOfImage];
//        if (!CGSizeEqualToSize(scaledImageSizeToFitOnGPU, pixelSizeOfImage))
//        {
//            pixelSizeOfImage = scaledImageSizeToFitOnGPU;
//            pixelSizeToUseForTexture = pixelSizeOfImage;
//            shouldRedrawUsingCoreGraphics = YES;
//        }
    
        //    if (self.shouldSmoothlyScaleOutput)
        //    {
        //        // In order to use mipmaps, you need to provide power-of-two textures, so convert to the next largest power of two and stretch to fill
        //        CGFloat powerClosestToWidth = ceil(log2(pixelSizeOfImage.width));
        //        CGFloat powerClosestToHeight = ceil(log2(pixelSizeOfImage.height));
        //
        //        pixelSizeToUseForTexture = CGSizeMake(pow(2.0, powerClosestToWidth), pow(2.0, powerClosestToHeight));
        //
        //        shouldRedrawUsingCoreGraphics = YES;
        //    }
        
        GLubyte *imageData = NULL;
        CFDataRef dataFromImageDataProvider = NULL;
        GLenum format = GL_BGRA;
        
//        if (!shouldRedrawUsingCoreGraphics) {
//            /* Check that the memory layout is compatible with GL, as we cannot use glPixelStore to
//             * tell GL about the memory layout with GLES.
//             */
//            if (CGImageGetBytesPerRow(newImageSource) != CGImageGetWidth(newImageSource) * 4 ||
//                CGImageGetBitsPerPixel(newImageSource) != 32 ||
//                CGImageGetBitsPerComponent(newImageSource) != 8)
//            {
//                shouldRedrawUsingCoreGraphics = YES;
//            } else {
//                /* Check that the bitmap pixel format is compatible with GL */
//                CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(newImageSource);
//                if ((bitmapInfo & kCGBitmapFloatComponents) != 0) {
//                    /* We don't support float components for use directly in GL */
//                    shouldRedrawUsingCoreGraphics = YES;
//                } else {
//                    CGBitmapInfo byteOrderInfo = bitmapInfo & kCGBitmapByteOrderMask;
//                    if (byteOrderInfo == kCGBitmapByteOrder32Little) {
//                        /* Little endian, for alpha-first we can use this bitmap directly in GL */
//                        CGImageAlphaInfo alphaInfo = CGImageAlphaInfo(bitmapInfo & kCGBitmapAlphaInfoMask);
//                        if (alphaInfo != kCGImageAlphaPremultipliedFirst && alphaInfo != kCGImageAlphaFirst &&
//                            alphaInfo != kCGImageAlphaNoneSkipFirst) {
//                            shouldRedrawUsingCoreGraphics = YES;
//                        }
//                    } else if (byteOrderInfo == kCGBitmapByteOrderDefault || byteOrderInfo == kCGBitmapByteOrder32Big) {
//                        /* Big endian, for alpha-last we can use this bitmap directly in GL */
//                        CGImageAlphaInfo alphaInfo = CGImageAlphaInfo(bitmapInfo & kCGBitmapAlphaInfoMask);
//                        if (alphaInfo != kCGImageAlphaPremultipliedLast && alphaInfo != kCGImageAlphaLast &&
//                            alphaInfo != kCGImageAlphaNoneSkipLast) {
//                            shouldRedrawUsingCoreGraphics = YES;
//                        } else {
//                            /* Can access directly using GL_RGBA pixel format */
//                            format = GL_RGBA;
//                        }
//                    }
//                }
//            }
//        }
    
        //    CFAbsoluteTime elapsedTime, startTime = CFAbsoluteTimeGetCurrent();
        
//        if (shouldRedrawUsingCoreGraphics)
//        {
//            // For resized or incompatible image: redraw
//            imageData = (GLubyte *) calloc(1, (int)pixelSizeToUseForTexture.width * (int)pixelSizeToUseForTexture.height * 4);
//            
//            CGColorSpaceRef genericRGBColorspace = CGColorSpaceCreateDeviceRGB();
//            
//            CGContextRef imageContext = CGBitmapContextCreate(imageData, (size_t)pixelSizeToUseForTexture.width, (size_t)pixelSizeToUseForTexture.height, 8, (size_t)pixelSizeToUseForTexture.width * 4, genericRGBColorspace,  kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
//            //        CGContextSetBlendMode(imageContext, kCGBlendModeCopy); // From Technical Q&A QA1708: http://developer.apple.com/library/ios/#qa/qa1708/_index.html
//            CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, pixelSizeToUseForTexture.width, pixelSizeToUseForTexture.height), newImageSource);
//            CGContextRelease(imageContext);
//            CGColorSpaceRelease(genericRGBColorspace);
//        }
//        else
        {
            // Access the raw image bytes directly
            dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(newImageSource));
            imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
        }
        
        int data_size =CFDataGetLength(dataFromImageDataProvider);
        unsigned char* image_buffer = new unsigned char[data_size];
        memcpy(image_buffer, imageData, data_size);
        
        if(dataFromImageDataProvider){
            CFRelease(dataFromImageDataProvider);
        }
    
        image_data = nil;
        url = nil;
        inputimage = nil;
    
        return image_buffer;
    }
    
    
    //debug测试用，显示buffer中的图片
    void VideoTemplateUtils::toImage(unsigned char* data, string userData)
    {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef newContext = CGBitmapContextCreate(data,
                                                        480, 480, 8,
                                                        480 * 4,
                                                        colorSpace,
                                                        kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
        //kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGImageRef frame = CGBitmapContextCreateImage(newContext);
        UIImage* image = [UIImage imageWithCGImage:frame];
        CGImageRelease(frame);
        CGContextRelease(newContext);
        CGColorSpaceRelease(colorSpace);
    }
    


} /* namespace feinnovideotemplate */
