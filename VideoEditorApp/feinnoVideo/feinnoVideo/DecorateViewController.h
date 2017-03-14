//
//  DecorateViewController.h
//  libFeinnoVideo
//
//  Created by coCo on 14-9-10.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "MediaViewController.h"
#import "base/Common.h"

@interface DecorateViewController : MediaViewController<UIAlertViewDelegate>
//@interface DecorateViewController : UIViewController<UIAlertViewDelegate>
{
    VC_ID _vcID;
}
@property(nonatomic, assign) VC_ID vcID;

@end
