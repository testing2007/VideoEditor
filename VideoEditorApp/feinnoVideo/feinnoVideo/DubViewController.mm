//
//  DubViewController.m
//  VideoShow
//
//  Created by coCo on 14-7-9.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import "DubViewController.h"
#import "PlayView.h"
#import <AVFoundation/AVFoundation.h>

//zhiqiang-- #import "Recorder.h"
#include <captureAudio/AudioCaptureImpl.h>

#import "NavigationBar.h"
#import "EditRecorderViewController.h"

@interface DubViewController ()<AVAudioRecorderDelegate>
{
    NSMutableArray *arr;
    NSMutableArray *array;
    NSMutableArray *array1;
    PlayView *_recordPlayView;
    NavigationBar *_navBar;
    NSURL *_urlPlay;
    UIButton *_recordBtn;
    AVAudioRecorder *_audioRecorder;
    
    //zhiqiang-- Recorder *_record;
    IAudioCapture* _record;

    BOOL _flag;
}
@end

@implementation DubViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor blackColor];
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // 隐藏导航栏
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self checkStatusHidden];
//    arr = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6", nil];
//    array = [NSMutableArray arrayWithObjects:@"q",@"w",@"e",@"r",@"y",@"i", nil];
//    array1 = [NSMutableArray arrayWithObjects:@"q",@"w",@"e",@"r",@"y",@"i", nil];
#pragma mark - 导航栏
    _navBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 51) titleText:@"配音" leftButtonTarget:self leftButtonAction:@selector(clickBackButton) leftButtonImage:[UIImage imageNamed:@"上一步_normal.png"] leftSelectedButtonImage:[UIImage imageNamed:@"上一步_down.png"] rightButtonTarget:self rightButtonAction:@selector(clickSure) rightButtonImage:[UIImage imageNamed:@"顶部导航栏_确定normal.png"] rightSelectedButtonImage:[UIImage imageNamed:@"顶部导航栏_确定down.png"]];
    [self.view addSubview:_navBar];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"movie" ofType:@".mp4"];
    _recordPlayView = [[PlayView alloc] initWithPlayViewFrame:CGRectMake(0, 0, 320, self.view.frame.size.height/3*2) playAddress:path showProgressLabel:YES showPlayBtn:YES showProSlider:YES showProgress:YES showOriginnalSoundBtn:YES target:self];
    [self.view addSubview:_recordPlayView];
    // 录音配置及初始化录音
    
    //zhiqiang--_record = [[Recorder alloc] init];
    _record = new AudioCaptureImpl(_getTestFilePath());
    
    //[self audio];
    // 录音按钮
    _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];//143*47
    _recordBtn.frame = CGRectMake(self.view.frame.size.width/2 -143/2, self.view.frame.size.height -109/2 -47/2, 143, 47);
    _recordBtn.backgroundColor = [UIColor clearColor];
    [_recordBtn setTitle:@"按住录音" forState:UIControlStateNormal];
    _recordBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    _recordBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 40, 0, 10);
    [_recordBtn setBackgroundImage:[UIImage imageNamed:@"按住录音_normal.png"] forState:UIControlStateNormal];
    [_recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _recordBtn.layer.masksToBounds = YES;
    _recordBtn.layer.cornerRadius = 23.5;
    [self.view addSubview:_recordBtn];
    
    [_recordBtn addTarget:self action:@selector(recordStart) forControlEvents:UIControlEventTouchDown];
    [_recordBtn addTarget:self action:@selector(recordStop) forControlEvents:UIControlEventTouchUpInside];
 
    [self.view bringSubviewToFront:_navBar];
}

-(void) recordStart
{
    [_recordBtn setBackgroundImage:[UIImage imageNamed:@"按住录音_down.png"] forState:UIControlStateNormal];
    [_recordBtn setTitle:@"正在录音" forState:UIControlStateNormal];
    [_recordBtn setTitleColor:[UIColor colorWithRed:224.0/255 green:99.0/255 blue:61.0/255 alpha:1.0] forState:UIControlStateNormal];
    //zhiqiang-- [_record start];
    _record->start();
}
-(void) recordStop
{
    [_recordBtn setBackgroundImage:[UIImage imageNamed:@"按住录音_normal.png"] forState:UIControlStateNormal];
    [_recordBtn setTitle:@"按住录音" forState:UIControlStateNormal];
    [_recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //zhiqiang-- [_record stop];
    _record->stop();
}
//-(void) audio
//{
//    //录音设置
//    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
//    //设置录音格式  
//    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
//    //设置录音采样率
//    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
//    //录音通道数
//    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
//    //线性采样位数
//    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
//    //录音的质量
////    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
//    
//    NSString *strUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/myrecord", strUrl]];
//    NSData *data = [NSData dataWithContentsOfURL:url];
//    NSLog(@"%lu",(unsigned long)data.length);
//    NSLog(@"%@",data);
//    NSLog(@"%@",strUrl);
//    _urlPlay = url;
//    NSError *error;
//    //初始化
//    _audioRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
//    //开启音量检测
//    _audioRecorder.meteringEnabled = YES;
//    _audioRecorder.delegate = self;
//}
//
//-(void) recordDown:(id)sender
//{
//    //创建录音文件，准备录音
//    if ([_audioRecorder prepareToRecord]) {
//        //开始
//        [_audioRecorder record];
//        NSLog(@"开始录音");
//    }
//}
//-(void) recordUp:(id)sender
//{
//    double cTime = _audioRecorder.currentTime;
//    if (cTime > 10) {//如果录制时间>10秒 不发送
//        //删除记录的文件
//        [_audioRecorder deleteRecording];
//        //删除存储的
//    }else {
//        NSLog(@"发出去");
//    }
//    [_audioRecorder stop];
//}
//-(void) recordDragUp:(id)sender
//{
//    [_audioRecorder stop];
//    NSLog(@"录音结束");
//
//}
//-(void) pan:(UIGestureRecognizer *)sender
//{
//    [self.view bringSubviewToFront:imageView];
//    CGPoint location = [sender locationInView:self.view];
//    sender.view.center = CGPointMake(location.x,  location.y);
//}
//隐藏状态栏
-(void) checkStatusHidden
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        // iOS 7
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}
- (BOOL)prefersStatusBarHidden
{
    return YES;//隐藏为YES，显示为NO
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) clickBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) clickSure
{
    EditRecorderViewController *edit = [[EditRecorderViewController alloc] init];
    [self.navigationController pushViewController:edit animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

const char* _getTestFilePath()
{
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    NSString* testAACFilePath = [docPath stringByAppendingString:@"/test.wav"];
    return [testAACFilePath UTF8String];
}

@end
