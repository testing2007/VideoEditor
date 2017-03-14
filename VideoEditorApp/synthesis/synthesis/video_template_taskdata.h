//
//  video_template_taskdata.h
//  libSynthesis
//
//  Created by shangbocai on 14-9-15.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#ifndef libSynthesis_video_template_taskdata_h
#define libSynthesis_video_template_taskdata_h

#include <string>
#include <list>



namespace feinnovideotemplate {

    using std::string;
    using std::list;
    
    struct VideoTaskData {
        VideoTaskData():
        progress(0),isDone(false),isSynthesis(false),isPreview(false),isSaveFile(false),isMute(false),
        decorateFilter(NULL),music(NULL)
        {
            
        }
        
        ~VideoTaskData(){
//            if(decorateFilter != NULL)
//            {
//                delete decorateFilter;
//                decorateFilter = NULL;
//            }
//            if(music != NULL){
//                delete  music;
//                music = NULL;
//            }
//            if(titlles.size()>0){
//                for(list<Tittle*>::iterator iter = titlles.begin();iter != titlles.end();iter++){
//                    delete *iter;
//                }
//                
//                titlles.clear();
//            }
//            if(audioClips.size()>0){
//                for(list<AudioClip*>::iterator iter = audioClips.begin();iter != audioClips.end();iter++){
//                    delete *iter;
//                }
//                
//                audioClips.clear();
//            }
            uri.clear();
            outputVideoFile.clear();
            themeId.clear();
            filterId.clear();
        }
        
         volatile int progress;
        // volatile
        string processedUri;
         volatile bool isDone	;
         volatile bool isSynthesis ;		//结束符
         volatile bool isPreview  ; 		//是否预览
         volatile bool isSaveFile ; 		//保存文件
         const  int FrameRate = 40 ;
   
        /**
         * 视频文件地址
         */
         string	uri;
        
        //输出文件地址
        string outputVideoFile;
        //	/**
        //	 * 处理类型ex：主题，滤镜
        //	 */
        //	 int	type;
        //	/**
        //	 * type 对应的id
        //	 */
        //	 int	id;
        /**
         * 是否消音
         */
         volatile bool	isMute;
        
         // 主题
         string themeId;
        
        // 滤镜
         string filterId;
        
        // 装饰
         Filter* decorateFilter;
        
        // 字幕
         list<Tittle*> titlles;
        
        // 配音
         list<AudioClip*> audioClips;
        
        // 配乐
         AudioClip* music;
    };
    typedef struct VideoTaskData VideoTaskData;
}
#endif
