//
//  TitleViewController.h
//  libFeinnoVideo
//
//  Created by coCo on 14-9-4.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "MediaViewController.h"
#import "base/Common.h"

@interface TitleViewController : MediaViewController<UITextFieldDelegate>
{
    VC_ID _vcID;
}
@property(nonatomic, assign) VC_ID vcID;

@end
