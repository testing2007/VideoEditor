//
//  AddTitleViewController.h
//  libFeinnoVideo
//
//  Created by coCo on 14-9-11.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "MediaViewController.h"
#import "PanImageView/ZDStickerView.h"
#import "base/Common.h"

@interface AddTitleViewController : MediaViewController<labelDelegate>
//@interface AddTitleViewController : UIViewController<labelDelegate>
{
    VC_ID _vcID;
}
@property(nonatomic, assign) VC_ID vcID;

@end
