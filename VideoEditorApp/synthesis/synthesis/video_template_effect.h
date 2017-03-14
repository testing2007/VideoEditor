/*
 * video_template_effect.h
 *
 *  Created on: 2014年9月1日
 *      Author: 尚博才
 */

#ifndef VIDEO_TEMPLATE_EFFECT_H_
#define VIDEO_TEMPLATE_EFFECT_H_

#include "video_template_types.h"
#include <string>
#include <list>

namespace feinnovideotemplate {
using std::string;
    using std::list;
    class Filter;
    
class Effect {
public:
    Effect();
    Effect(const string& id);
    virtual ~Effect();

public:

    /**
     * 执行特效
     * @param curFrame 当前帧
     * @return 处理后的帧
     */
    // fixme Bitmap
//    abstract
//    Bitmap applyEffect(Bitmap curFrame, boolean isPreview);
    virtual  unsigned char* ApplyEffect(unsigned char* curFrame, bool isPreview,list<Filter*>& filterlist)=0;

public:
    // [ =============== 存取方法 =============
    const string& id() const {
        return id_;
    }

    void set_id(const string& id) {
        id_ = id;
    }

    const string& name() const {
        return name_;
    }

    void set_name(const string& name) {
        name_ = name;
    }
    const string& icon() const {
        return icon_;
    }

    void set_icon(const string& icon) {
        icon_ = icon;
    }
    // ] =============== 存取方法 =============

private:
    string id_;

    string name_;

    string icon_;

};

} /* namespace feinnovideotemplate */

#endif /* VIDEO_TEMPLATE_EFFECT_H_ */
