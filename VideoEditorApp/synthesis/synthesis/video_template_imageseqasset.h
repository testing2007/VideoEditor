/*
 * video_template_imageseqasset.h
 *
 *  Created on: 2014年9月2日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_IMAGESEQASSET_H_
#define VIDEO_TEMPLATE_IMAGESEQASSET_H_

#include "video_template_asset.h"
#include <list>

namespace feinnovideotemplate {
using std::list;
using std::string;

class ImageSeqAsset: public feinnovideotemplate::Asset {
public:
    ImageSeqAsset();
    virtual ~ImageSeqAsset();




public: // 存取方法
    int attach_size() const {
        return attach_size_;
    }

    const list<unsigned char*>& image_list() const {
        return image_list_;
    }

    const list<string>& image_uri_list() const {
        return image_uri_list_;
    }

    void set_image_uri_list(const list<string>& imageUriList) {
        image_uri_list_ = imageUriList;

        attach_size_ = (int)image_uri_list_.size();
        LoadImage();
    }


    /**
     * 取缓存的Bitmap对象
     *
     * @param index
     * @return
     */
    unsigned char* GetImage(int index) {
        unsigned char* bmp;
        list<unsigned char*>::iterator iter = image_list_.begin();
        for(int i=0; i< image_list_.size(); i++, iter++)
            bmp = *iter;

        return bmp;
    }

private:

    void LoadImage();


    // 图片URI列表（循环）
    list<string> image_uri_list_;

    // 缓存Bitmap对象
    list<unsigned char*> image_list_;

    int attach_size_;

};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_IMAGESEQASSET_H_ */
