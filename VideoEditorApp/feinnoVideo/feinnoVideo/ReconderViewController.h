//
//  ReconderViewController.h
//  libFeinnoVideo
//
//  Created by coCo on 14-9-9.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "MediaViewController.h"
#import "base/Common.h"

@interface ReconderViewController : MediaViewController<AVAudioPlayerDelegate>
{
    BOOL _bMute;
    float* _oldVolumeValue;
    VC_ID _vcID;
}
@property(nonatomic, assign) VC_ID vcID;

-(void) getAudioPlay;

@end
