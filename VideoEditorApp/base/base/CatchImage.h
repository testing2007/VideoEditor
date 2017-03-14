//
//  CatchImage.h
//  libFeinnoVideo
//
//  Created by coCo on 14-9-10.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CatchImage : NSObject

+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

@end
