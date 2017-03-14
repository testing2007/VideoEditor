/*
 * video_template_videotemplateutils.h
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_VIDEOTEMPLATEUTILS_H_
#define VIDEO_TEMPLATE_VIDEOTEMPLATEUTILS_H_

#include <string>

#include "video_template_videotemplate.h"

namespace feinnovideotemplate {
using std::string;

class VideoTemplateUtils {


public:
    VideoTemplateUtils();
    virtual ~VideoTemplateUtils();


public:
    const static long WATERMARK_DURATION = 25;
    static bool ADD_WATERMARK;

    static VideoTemplate* BuildFromXML(const string& id);
    static void AddWatermarkNode(VideoTemplate* videoTemplate);
    static VideoTemplate* CreateBlankTemplate();

//protected:
    static VideoTemplate* CreateSimpleTemplate(const string& filterId);


public:
    //从图片文件取RGBA数据
    static unsigned char* GetDataFromImgFile(string& imagePath);

    // debug测试用，显示rgba图片
    static void toImage(unsigned char* data, string userData);
};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_VIDEOTEMPLATEUTILS_H_ */
