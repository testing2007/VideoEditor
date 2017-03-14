/*
 * video_template_types.h
 *
 *  Created on: 2014年9月1日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_TYPES_H_
#define VIDEO_TEMPLATE_TYPES_H_

#include <cstring>
#include <cassert>
#include <string>

namespace feinnovideotemplate {
using std::string;

const static double MATH_E = 2.718281828459045;
const static int AUDIO_DATA_SIZE = 1024 * 2 * 2; //1024采样，16位，2声道
const static int SAMPLES_COUNT_PER_AUDIO_BUFFER = 1024; //音频包采样数
    

    
// 资源类型
enum AssetType {

    VIDEO, // 视频
    IMAGE, // 图片
    AUDIO, // 音频
    TITTLE // 字体

};
typedef enum AssetType AssetType;


// 渲染树节点类型
enum NodeType {
    VIDEO_TRACK,          //视频轨
    TRANSITION_TRACK,     //转场特效轨
    FXEFFECT_TRACK,       //Fx特效轨
    AUDIO_TRACK,          //音频轨
    TITTLE_TRACK,         //字幕轨

    VIDEO_NODE,          //视频素材
    IMAGE_NODE,          //图像素材
    FILER_NODE,          //滤镜
    TRANSITION_NODE,     //转场特效
    FXEFFECT_NODE,       //Fx特效
    TITTLE_NODE          //字幕
};
typedef enum NodeType NodeType;

////fixme Bitmap定义类还是直接使用基础类型？？这里定义是为了编译能过
//struct Bitmap {
//   unsigned char* data;
//   int len;
//};
//typedef struct Bitmap Bitmap;
    AssetType GetValueOfAssetType(const char* value);
    std::string GetAssetTypeString(AssetType type);

}

#endif /* VIDEO_TEMPLATE_TYPES_H_ */
