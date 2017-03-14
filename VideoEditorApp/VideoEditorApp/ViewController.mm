//
//  ViewController.m
//  FeinnoVideoApp
//
//  Created by wzq on 14-9-2.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "ViewController.h"
#import <feinnoVideo/IFeinnoVideoCallback.h>
#import <feinnoVideo/FVideoViewController.h>
#import <feinnoVideo/FVAudioPlayer.h>
#import <base/Common.h>
#import <feinnoVideo/FeinnoVideoImpl.h>

@interface ViewController ()
{
    UIButton* _enterBtn;
    //FeinnoVideo* _fv;
}

@property(nonatomic, retain) UIButton* enterBtn;
@property (nonatomic ,retain) AVAudioPlayer *audioPlayer;
//@property(nonatomic, retain) FeinnoVideo* fv;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSString *path = [Common get]
//    NSURL *url = [NSURL fileURLWithPath:path];
//    //self.audioPlayer = nil;
//    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
//    _audioPlayer.volume = 3.0;
//    [_audioPlayer prepareToPlay];
//    [_audioPlayer play];

    // NSLog(@"the document's path=%@", [Common getDocumentDirectory] stringByAppendingString:<#(NSString *)#>);
	// Do any additional setup after loading the view, typically from a nib.
    
//    NSString* path = @"/var/mobile/Applications/863D3E19-97D8-4D79-8FE7-35A41043C035/Documents/assets/bgmusic/1/a.mp3";
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//    
//    FVAudioPlayer* fv = [[FVAudioPlayer alloc]init];
//    [fv start:path];
}

-(void) viewWillAppear:(BOOL)animated
{
    self.enterBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    self.enterBtn.frame = CGRectMake(40,100, 80, 20);
    [self.enterBtn addTarget:self action:@selector(enterFeinnoVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.enterBtn setBackgroundColor:[UIColor blackColor]];
    [self.enterBtn setTitle:@"Launch" forState:UIControlStateNormal];
    [self.enterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:self.enterBtn];
    
//    FVAudioPlayer* ap = [[FVAudioPlayer alloc]init];
//    [ap start:@"/var/mobile/Applications/B39A4663-0478-4AB6-AE37-D4A1F9FA7652/Documents/assets/bgMusic/4/Aimlessly Through The Streets.mp3"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)enterFeinnoVideo
{
    NSString *srcVideoPath = [[NSBundle mainBundle] pathForResource:@"VID_20140630_183434" ofType:@"mp4"];
    NSString* pathExt = [srcVideoPath pathExtension];
    NSString* editorVideoPath = [[Common getDocumentDirectory] stringByAppendingString:[NSString stringWithFormat:@"/VID_20140630_183434_e.%@",pathExt]];

    FeinnoVideoImpl* fvi = [[FeinnoVideoImpl alloc]init];
    UIViewController* fv =  [fvi initialize:self withMediaPath:[srcVideoPath copy] withSavePath:editorVideoPath withPrevEditInfo:nil];
    
//    FVideoViewController* fv = [[FVideoViewController alloc] init];
//    [fv initialize:self withMediaPath:srcVideoPath withSavePath:editorVideoPath withPrevEditInfo:NULL];
//    NSLog(@"self.parentViewController=%p", self.parentViewController);
    [(UINavigationController*)(self.parentViewController) pushViewController:fv animated:YES];
}

-(void) finishEdit:(NSString*)savePath withEditParameter:(NSString*)editParameter
{
    NSLog(@"finish edit is called,=%@", editParameter);
}

@end
