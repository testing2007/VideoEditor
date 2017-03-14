//
//  ReconderViewController.m
//  libFeinnoVideo
//
//  Created by coCo on 14-9-9.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "ReconderViewController.h"
#import <AVFoundation/AVFoundation.h>

//zhiqiang-- #import "Recorder.h"
#include <captureAudio/AudioCaptureImpl.h>

#import "NavigationBar.h"
#import "EditRecorderViewController.h"
#import "MySlider.h"
#import "MediaViewController.h"
#import "base/Common.h"
#import "base/SynthesisParameterInfo.h"
#import "SynthesisParamterInstance.h"
#import "ReconderViewController.h"

@interface ReconderViewController ()<AVAudioRecorderDelegate>
{
    NSMutableArray *arr;
    NSMutableArray *array;
    NSMutableArray *array1;
    NavigationBar *_navBar;
    NSURL *_urlPlay;
    UIButton *_recordBtn;
    AVAudioRecorder *_audioRecorder;
    //zhiqiang-- Recorder *_record;
    IAudioCapture* _record;
    BOOL _flag;
    UIView *_recordProgress;
    AVAudioPlayer *_audioPlayer;
}
@end

@implementation ReconderViewController


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _vcID =VC_RECORD;
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.playerView.player.volume = *_oldVolumeValue;
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // 隐藏导航栏
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _oldVolumeValue = (float*)malloc(sizeof(float));
    *_oldVolumeValue = self.playerView.player.volume;
    //[self checkPlayerViewHidden:YES];
    [self playerButtonHidden:YES];
    [self soundBtnHidden:NO];
    [self mediaTimeShow:YES];
    [self isshowMySaVideo:YES];
    self.view.backgroundColor = [UIColor blackColor];
    [self checkStatusHidden];
    //    arr = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6", nil];
    //    array = [NSMutableArray arrayWithObjects:@"q",@"w",@"e",@"r",@"y",@"i", nil];
    //    array1 = [NSMutableArray arrayWithObjects:@"q",@"w",@"e",@"r",@"y",@"i", nil];
#pragma mark - 导航栏
//    _navBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 51) titleText:@"配音" leftButtonTarget:self leftButtonAction:@selector(clickBackButton) leftButtonImage:[UIImage imageNamed:@"上一步_normal.png"] leftSelectedButtonImage:[UIImage imageNamed:@"上一步_down.png"] rightButtonTarget:self rightButtonAction:@selector(clickSure) rightButtonImage:[UIImage imageNamed:@"顶部导航栏_确定normal.png"] rightSelectedButtonImage:[UIImage imageNamed:@"顶部导航栏_确定down.png"]];
//    [self.view addSubview:_navBar];
    
    // 录音配置及初始化录音
    //zhiqiang--_record = [[Recorder alloc] init];
    const char* szRecordSavePath = [[Common getRecordSavePath] UTF8String];
    std::string strRecordSavePath = std::string(szRecordSavePath);
    _record = new AudioCaptureImpl(szRecordSavePath);
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
    [self.recorderProgress addTarget:self action:@selector(deleteRecorder) forControlEvents:UIControlEventTouchUpInside];
    //
    [self.view bringSubviewToFront:_navBar];
    
    NSString *recordPath = [Common getRecorderMusicDirectory];
    NSURL *url = [NSURL URLWithString:recordPath];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _audioPlayer.volume = 1;
    [_audioPlayer prepareToPlay];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAudioPlay) name:@"playSound" object:nil];
}

-(void)dealloc
{
    if(_oldVolumeValue != NULL)
    {
        free(_oldVolumeValue);
        _oldVolumeValue = NULL;
    }
}

-(void) recordStart
{
    [_recordBtn setBackgroundImage:[UIImage imageNamed:@"按住录音_down.png"] forState:UIControlStateNormal];
    [_recordBtn setTitle:@"正在录音" forState:UIControlStateNormal];
    [_recordBtn setTitleColor:[UIColor colorWithRed:224.0/255 green:99.0/255 blue:61.0/255 alpha:1.0] forState:UIControlStateNormal];
    //zhiqiang-- [_record start];
    _record->start();
    [self playBtnTouched];
}
-(void) recordStop
{
    [_recordBtn setBackgroundImage:[UIImage imageNamed:@"按住录音_down.png"] forState:UIControlStateNormal];
    [_recordBtn setTitle:@"按住录音" forState:UIControlStateNormal];
    [_recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_recordBtn setEnabled:NO];
    [self buttonStop];
    self.playBtn.hidden = YES;
    //zhiqiang-- [_record stop];
    _record->stop();
    
    SynthesisParamterInstance& synParaInstance = SynthesisParamterInstance::instance();
    std::string recordSavePath = std::string([[Common getRecordSavePath] UTF8String]);
    synParaInstance.setRecordPath(recordSavePath);
    //synParaInstance.setRecordStartTime([Common getRecordStartTimeInMillSec]);
    //synParaInstance.setRecordAudioDuration([Common getRecordLengthInMillSec]/1000);
}
//删除录音
-(void) deleteRecorder
{
    NSLog(@"删除录音");
    self.recorderProgress.frame = self.sliderView.pointView.frame;
    [_recordBtn setBackgroundImage:[UIImage imageNamed:@"按住录音_normal.png"] forState:UIControlStateNormal];
    [_recordBtn setEnabled:YES];
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
//播放录音
-(void) getAudioPlay
{
    [_audioPlayer play];
}
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
    //TODO:判断是否产生录音动作，如果没有，就不发送, 目前声音没有合成，所以不发送合成消息
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_EDITED" object:self];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) clickSure
{
    EditRecorderViewController *edit = [[EditRecorderViewController alloc] init];
    [self.navigationController pushViewController:edit animated:YES];
}

-(void)switchMute:(id)target
{
    _bMute = !_bMute;
    [super record:&_oldVolumeValue isMute:_bMute];
}
//-(void)getRecordStartTime
//{
//    float start = self.sliderValue *1000;
//    
//}
//-(float)getRecordlength
//{
//    float length = (self.currentSecond - self.sliderValue) *1000;
//    return length;
//}



@end
