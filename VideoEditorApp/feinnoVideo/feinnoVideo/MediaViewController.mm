//
//  MediaViewController.m
//  FVideo
//
//  Created by coCo on 14-8-26.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import "MediaViewController.h"
#import "VideoRangeSlider/SAVideoRangeSlider.h"
#import "base/CatchImage.h"
#import "PluginInterfaceInfo.h"
#import "ReconderViewController.h"
#import "base/FeinnoVideoState.h"
#import "base/SynthesisParameterInfo.h"
#import "SynthesisParamterInstance.h"

@interface MediaViewController (){
    NSString *_totalTime;
    float _totalSecond;
    UIControl *_control;
    AVPlayer *_player;
    id _playbackTimeObserver;
    UISlider *_slider;
    UIButton *_soundBtn;
    UILabel *_soundLabel;
    UILabel *_totalTimeLabel;
    UILabel *_leftTimeLabel;
    UILabel *_rightTimeLabel;
    BOOL _timeLabel;
    SAVideoRangeSlider *_mySAVideoRangeSlider;
    UIImage *_movieImage;
    NSURL *_url;
    int _tag;
    int _flag;
    BOOL _device;
}

@property (nonatomic ,retain) AVPlayerItem *playerItem;
@property (nonatomic ,retain) UILabel *currentTimeLabel;
@property (nonatomic, retain) AVPlayer *player;
@end

@implementation MediaViewController

-(void)loadVideo:(NSString *)videoPath
{
    self.srcVideoPath = videoPath;
}

- (id)init
{
    self = [super init];
    if (self) {
        _flag = 1;
        _sliderValue = 0;
    }
    return self;
}

-(void) dealloc
{
    NSLog(@"Media View controller is called");
}

-(void)viewDidDisappear:(BOOL)animated
{
    [_playerItem removeObserver:self forKeyPath:@"status"];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _device = [Common getDeviceSize];
    _url = [NSURL fileURLWithPath:[[PluginInterfaceInfo instance] srcVideoPath]];
    _playerItem = [AVPlayerItem playerItemWithURL:_url];
    [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    if (_device == YES) {
        self.playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 61, 320, 320)];
    }else{
        self.playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0, 51, 320, 320)];
    }
    
    // CGRect rcStageView = CGRectMake(0, 0, self.playerView.)sms = _secMenuView.frame.size;
    _stageView = [[SSStageView alloc]init:self.playerView.bounds withWarnRect:self.playerView.bounds];
    [_playerView addSubview:_stageView];
    
     _playerView.userInteractionEnabled = YES;
    //_playerView.frame = CGRectMake(0, 51, 320, 320);
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerView.player = _player;
    
    _playerView.player.volume = 1;
     //*/
    [self.view addSubview:_playerView];
    // _gpuImageView=[[GPUImageView alloc]initWithFrame:_playerView.bounds];
    //[_playerView addSubview:_gpuImageView];
    
    //视频播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
#warning 图片
    NSArray *arr = [NSArray arrayWithObjects:@"40.png",@"40.png",@"40.png",@"40.png", nil];
    _sliderView = [[MySlider alloc] initWithImageArray:arr time:_totalSecond frame:CGRectMake(self.view.frame.origin.x, _playerView.frame.size.height -62 +51, self.view.frame.size.width, 62)];
    _sliderView.delegate = self;
    _sliderView.userInteractionEnabled = YES;
    [self.view addSubview:_sliderView];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(self.view.frame.origin.x +5, _sliderView.frame.size.height -26 +7, self.view.frame.size.width -8, 10)];
    [_slider setThumbImage:[UIImage imageNamed:@"锚点_normal.png"] forState:UIControlStateNormal];
    [_slider trackRectForBounds:CGRectMake(0, 0, 10, 10)];
    _slider.value = 0;
    _slider.tintColor = [UIColor clearColor];
    _slider.maximumTrackTintColor = [UIColor clearColor];
    [_slider addTarget:self action:@selector(videoSlierChangeValue:) forControlEvents:UIControlEventValueChanged];
    [_sliderView addSubview:_slider];
    
    _currentTimeLabel = [[UILabel alloc] init];
    _currentTimeLabel.font = [UIFont systemFontOfSize:9];
    _currentTimeLabel.textColor = [UIColor whiteColor];
    _currentTimeLabel.text = @"00:00";
    _currentTimeLabel.backgroundColor = [UIColor clearColor];
    _currentTimeLabel.frame = CGRectMake(12, 0, 24, 16);
    [_sliderView addSubview:_currentTimeLabel];

    _totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width -12 -24, 0, 24, 16)];
    _totalTimeLabel.font = [UIFont systemFontOfSize:9];
    _totalTimeLabel.textColor = [UIColor whiteColor];
    _totalTimeLabel.backgroundColor = [UIColor clearColor];
    _totalTimeLabel.frame = CGRectMake(self.view.frame.size.width -12 -24, 0, 24, 16);
    [_sliderView addSubview:_totalTimeLabel];
    

    _recorderProgress = [UIButton buttonWithType:UIButtonTypeCustom];
    _recorderProgress.frame = self.sliderView.pointView.frame;
    //_recorderProgress.backgroundColor = [UIColor blackColor];
    _recorderProgress.backgroundColor = [UIColor colorWithRed:238.0/255 green:104.0/255 blue:62.0/255 alpha:0.6];
    [self.sliderView.imageView addSubview:_recorderProgress];

    _mySAVideoRangeSlider = [[SAVideoRangeSlider alloc] initWithFrame:CGRectMake(12,_sliderView.frame.size.height -26 -20,_sliderView.frame.size.width -24 ,20) videoUrl:_url ];
    UIImageView *liftimage = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 5, 16)];
    liftimage.image = [UIImage imageNamed:@"左箭头.png"];
    liftimage.backgroundColor = [UIColor clearColor];
    [_mySAVideoRangeSlider.leftThumb addSubview:liftimage];
    UIImageView *rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 5, 16)];
    rightImage.image = [UIImage imageNamed:@"右箭头.png"];
    rightImage.backgroundColor = [UIColor clearColor];
            
    [_mySAVideoRangeSlider.rightThumb addSubview:rightImage];
    _mySAVideoRangeSlider.bubleText.font = [UIFont systemFontOfSize:12];
    [_mySAVideoRangeSlider setPopoverBubbleSize:120 height:60];
    // Yellow
    _mySAVideoRangeSlider.topBorder.backgroundColor = [UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1];
    _mySAVideoRangeSlider.bottomBorder.backgroundColor = [UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1];
    _mySAVideoRangeSlider.delegate = self;
            
    [_sliderView addSubview:_mySAVideoRangeSlider];

    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _playBtn.frame = CGRectMake(125, 125, 50, 50);
    [_playBtn setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    _playBtn.layer.masksToBounds = YES;
    _playBtn.layer.cornerRadius = 25;
    [_playBtn addTarget:self action:@selector(playBtnTouched) forControlEvents:UIControlEventTouchUpInside];
    _playBtn.backgroundColor = [UIColor clearColor];
    [_playerView addSubview:_playBtn];
    
    _soundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _soundBtn.frame = CGRectMake(self.view.frame.size.width -11 -24,_playerView.frame.size.height -_sliderView.frame.size.height -11 -24, 24, 24);
    [_soundBtn setBackgroundImage:[UIImage imageNamed:@"消除原音_unselected.png"] forState:UIControlStateNormal];
    [_soundBtn addTarget:self action:@selector(switchMute:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView addSubview:_soundBtn];
    

//    _leftTimeLabel = [[UILabel alloc] init];
//    _leftTimeLabel.font = [UIFont systemFontOfSize:9];
//    _leftTimeLabel.textColor = [UIColor whiteColor];
//    _leftTimeLabel.text = @"00:00";
//    _leftTimeLabel.backgroundColor = [UIColor clearColor];
//    _leftTimeLabel.frame = CGRectMake(5, _playerView.frame.size.height +5 +2, 24, 16);
//    [_playerView addSubview:_leftTimeLabel];
//    
//    _rightTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width -12 -24, 0, 24, 16)];
//    _rightTimeLabel.font = [UIFont systemFontOfSize:9];
//    _rightTimeLabel.textColor = [UIColor whiteColor];
//    _rightTimeLabel.backgroundColor = [UIColor clearColor];
//    _rightTimeLabel.frame = CGRectMake(self.view.frame.size.width -19 -12, _playerView.frame.size.height +5 +2, 24, 16);
//    [_playerView addSubview:_rightTimeLabel];
//
//    
//    _playerProView = [[UIProgressView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, _playerView.frame.size.height, 320, 2)];
//    _playerProView.progressTintColor = [UIColor colorWithRed:238.0/255 green:104.0/255 blue:62.0/255 alpha:1];
//    _playerProView.backgroundColor = [UIColor grayColor];
//    _playerProView.progress = 0;
//    [_playerView addSubview:_playerProView];
    
    //[self setLastFrame];
}
- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    __block MediaViewController *media = self;
    _playbackTimeObserver = [_playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 10000) queue:NULL usingBlock:^(CMTime time) {
//        NSLog(@"%lld",media.playerItem.currentTime.value);
//        NSLog(@"%d",media.playerItem.currentTime.timescale);
        media.currentSecond = ((float)media.playerItem.currentTime.value/media.playerItem.currentTime.timescale);// 计算当前在第几秒
//        if (media.currentSecond >= media.sliderValue && media.sliderValue != 0) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"playSound" object:nil];
//        }
        NSLog(@"当前的秒%f",media.currentSecond);
        [media updateVideoSlider:media.currentSecond];
        //[self updateVideoSlider:currentSecond];
        NSString *timeString = [media convertTime:media.currentSecond];
        //NSLog(@"%@",timeString);
        media.currentTimeLabel.text = [NSString stringWithFormat:@"%@",timeString];
    }];
}

//监听播放状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            //self.stateButton.enabled = YES;
            CMTime duration = _playerItem.duration;// 获取视频总长度
            _totalSecond = playerItem.duration.value / playerItem.duration.timescale;// 转换成秒
            NSLog(@"%lld",playerItem.duration.value);
            NSLog(@"%d",playerItem.duration.timescale);
            _totalTime = [self convertTime:_totalSecond];// 转换成播放时间
            NSLog(@"总时间:%@",_totalTime);
            _rightTimeLabel.text = [NSString stringWithFormat:@"%@",_totalTime];
            _totalTimeLabel.text = [NSString stringWithFormat:@"%@",_totalTime];
            //_totalTimeLabel.text = [NSString stringWithFormat:@"%@",_totalTime];
            [self customVideoSlider:duration];
            NSLog(@"movie total duration:%f",CMTimeGetSeconds(duration));
            [self monitoringPlayback:_playerItem];// 监听播放状态
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        }
    }
}
//获取视频总长度
- (void)customVideoSlider:(CMTime)duration
{
    _slider.maximumValue = CMTimeGetSeconds(duration);
    NSLog(@"视频总长度%f",_slider.maximumValue);
}
//视频播放完成后跳回视频开始处
- (void)moviePlayDidEnd:(NSNotification *)notification {
    NSLog(@"Play end");
    [_playerView.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [self updateVideoSlider:0.0];
        _playBtn.hidden = NO;
        _played = NO;
    }];
}

//转换时间为字符串
- (NSString *)convertTime:(CGFloat)second{
    NSLog(@"second:%f",second);
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"00:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:date];
    return showtimeNew;
}
//拖动进度条
-(void) videoSlierChangeValue:(id)sender
{
    UISlider *slider = (UISlider *)sender;
    _sliderValue = _slider.value;
    //FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    //state.recordStartTime = [NSString stringWithFormat:@"%f",_sliderValue];
    //NSLog(@"recordStartTime:%@",state.recordStartTime);
    //NSLog(@"slider.value:%f",_slider.value);
    float i = slider.value/(_slider.maximumValue *1000);
    //NSLog(@"i:%f",i);
    _sliderView.pointView.frame = CGRectMake((_sliderView.frame.size.width -24)*i *1000, _sliderView.pointView.frame.origin.y, _sliderView.pointView.frame.size.width, _sliderView.pointView.frame.size.height);
    _recorderProgress.frame = _sliderView.pointView.frame;
    CMTime changedTime = CMTimeMake(_slider.value,1);
    //NSLog(@"%lld",changedTime.value);
    //NSLog(@"%d",changedTime.timescale);
    [_playerView.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        if (_played == YES) {
            [_playerView.player play];
        }else{
            [_playerView.player pause];
        }
        //[self.stateButton setTitle:@"Stop" forState:UIControlStateNormal];
    }];
// UILongPressGestureRecognizer
}


//-(void) selectTheme:(int)nSelID
//{
//    if(_themeID==-1 && _themeID==nSelID)
//    {
//        return ; // do nothing
//    }
//    _themeID = nSelID;
//    _bNeedInitGPUBlendFilter = YES;
//    //_synthesis->init((GPUImageView *)_gpuImageView, [_srcVideoPath UTF8String], _themeID);
//}

-(void) selectFilter:(int)nSelID
{
//    if(_filterID==-1 && _filterID==nSelID)
//    {
//        return ; // do nothing
//    }
//    if(_filterID!=-1)
//    {
//         //将前一个播放停止，NOTE：目前视频没有播放完，不能中间停止
//        [self moviePlayDidEnd:nil];
//    }
//    _filterID = nSelID;
//    _bNeedInitGPUBlendFilter = YES;
//    // _synthesis->init((GPUImageView *)_gpuImageView, [_srcVideoPath UTF8String], _filterID);
}

//播放视频
-(void) playBtnTouched
{
    NSLog(@"视频播放中。。。");
    _played = YES;
    [_playerView.player play];
    _playBtn.hidden = YES;
    UITapGestureRecognizer  *recognizer;
    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonStop)];
    recognizer.numberOfTouchesRequired = 1;
    [_playerView addGestureRecognizer:recognizer];
    recognizer = nil;//zhiqiang++##release momory
}

//暂停视频
-(void) buttonStop
{
    NSLog(@"视频暂停");
    _played = NO;
    
    [_playerView.player pause];
    
    for (UISwipeGestureRecognizer *recognizer in [_playerView gestureRecognizers]) {
        [_playerView removeGestureRecognizer:recognizer];
    }
    _playBtn.hidden = NO;
}

//进度条
-(void) updateVideoSlider:(float)currentSecond
{
    //*zhiqiang-- for testing memory allocation
    [_slider setValue:currentSecond animated:YES];
    NSLog(@"11111,cur:%f",currentSecond);
    //FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    //state.recordLength = [NSString stringWithFormat:@"%f",(currentSecond - _sliderValue)];
    //NSLog(@"recordLength:%@",state.recordLength);
    float cur = currentSecond/CMTimeGetSeconds(_playerItem.duration);
    [_playerProView setProgress:cur];
    //
    float i = currentSecond/_slider.maximumValue;
    //NSLog(@"i:%f",i);
    _sliderView.pointView.frame = CGRectMake((_sliderView.frame.size.width -24)*i, _sliderView.pointView.frame.origin.y, _sliderView.pointView.frame.size.width, _sliderView.pointView.frame.size.height);
    _recorderProgress.frame = CGRectMake(_recorderProgress.frame.origin.x, _recorderProgress.frame.origin.y, _sliderView.pointView.frame.origin.x -_recorderProgress.frame.origin.x, _recorderProgress.frame.size.height);
     //*/
}
//视频起始时间和结束时间
-(NSMutableArray *)achieveCurrentTime
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSString *currstr = [NSString stringWithFormat:@"1%f",_mySAVideoRangeSlider.leftPosition];
    NSString *totalStr = [NSString stringWithFormat:@"2%f",_mySAVideoRangeSlider.rightPosition];
    [arr addObject:currstr];
    [arr addObject:totalStr];
    return arr;
}
-(void) checkSliderHidden:(BOOL) isshow
{
    if (isshow == YES) {
        _slider.hidden = YES;
    }else{
        _mySAVideoRangeSlider.hidden = YES;
    }
}
//设置播放器消失
-(void) checkPlayerViewHidden :(BOOL)isShow
{
    if (isShow == YES) {
        _playerView.hidden = YES;
    }else{
        _playerView.hidden = NO;
    }
}

// 消除原音
-(void) record:(float**)oldVolumeValue isMute:(BOOL)bMute
{
    if(bMute)
    {
        [_soundBtn setBackgroundImage:[UIImage imageNamed:@"消除原音_selected.png"] forState:UIControlStateNormal];
        _soundLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, _sliderView.frame.size.height -30, 80, 40)];
        _soundLabel.backgroundColor = [UIColor colorWithRed:15.0/255 green:15.0/255 blue:15.0/255 alpha:0.6];
        _soundLabel.textAlignment = NSTextAlignmentCenter;
        _soundLabel.font = [UIFont systemFontOfSize:14];
        _soundLabel.textColor = [UIColor whiteColor];
        _soundLabel.text = @"原音消除";
        [_sliderView addSubview:_soundLabel];
        [UIView animateWithDuration:1.0 animations:^{
        } completion:^(BOOL finished){
        }];
        NSTimer *timer;
        [timer invalidate];
        timer = nil;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(disPopView)
                                               userInfo:nil repeats:NO];
        **oldVolumeValue = _playerView.player.volume;
        _playerView.player.volume = 0;
        SynthesisParamterInstance::instance().setMute(YES);
        NSLog(@"消除原音");
    }
    else
    {
        [_soundBtn setBackgroundImage:[UIImage imageNamed:@"消除原音_unselected.png"] forState:UIControlStateNormal];
        _soundLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, _sliderView.frame.size.height -30, 80, 40)];
        _soundLabel.backgroundColor = [UIColor colorWithRed:15.0/255 green:15.0/255 blue:15.0/255 alpha:0.2];
        _soundLabel.textAlignment = NSTextAlignmentCenter;
        _soundLabel.font = [UIFont systemFontOfSize:14];
        _soundLabel.textColor = [UIColor whiteColor];
        _soundLabel.text = @"恢复原音";
        [_sliderView addSubview:_soundLabel];
        [UIView animateWithDuration:1.0 animations:^{
        } completion:^(BOOL finished){
        }];
        NSTimer *timer;
        [timer invalidate];
        timer = nil;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(disPopView)
                                               userInfo:nil repeats:NO];
        _flag = 1;
        _playerView.player.volume = **oldVolumeValue;
        // _playerView.player.volume = 0.5;
        SynthesisParamterInstance::instance().setMute(NO);
        NSLog(@"恢复原音");
    }
}
/*
-(void) clearSound:(float**)oldVolumeValue
{
    if (_flag) {
       
        _flag = 0;
    }else{
        [_soundBtn setBackgroundImage:[UIImage imageNamed:@"消除原音_unselected.png"] forState:UIControlStateNormal];
        _soundLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, _sliderView.frame.size.height -30, 80, 40)];
        _soundLabel.backgroundColor = [UIColor colorWithRed:15.0/255 green:15.0/255 blue:15.0/255 alpha:0.2];
        _soundLabel.textAlignment = NSTextAlignmentCenter;
        _soundLabel.font = [UIFont systemFontOfSize:14];
        _soundLabel.textColor = [UIColor whiteColor];
        _soundLabel.text = @"恢复原音";
        [_sliderView addSubview:_soundLabel];
        [UIView animateWithDuration:1.0 animations:^{
        } completion:^(BOOL finished){
        }];
        NSTimer *timer;
        [timer invalidate];
        timer = nil;
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(disPopView)
                                               userInfo:nil repeats:NO];
        _flag = 1;
        _playerView.player.volume = **oldVolumeValue;
        // _playerView.player.volume = 0.5;
        SynthesisParamterInstance::instance().setMute(NO);
        NSLog(@"恢复原音");
    }
}
 //*/
-(void) disPopView
{
    [_soundLabel removeFromSuperview];
}
// 是否显示soundBtn
-(void) soundBtnHidden: (BOOL)isshow
{
    if (isshow == YES) {
        _soundBtn.hidden = YES;
    }else{
        _soundBtn.hidden = NO;
    }
}
//选择是否显示pregess
-(void) mediaTimeShow :(BOOL)isShow
{
    if (isShow == YES) {
        _playerProView.hidden = YES;
        _leftTimeLabel.hidden = YES;
        _rightTimeLabel.hidden = YES;
    }else{
        _playerProView.hidden = NO;
        _leftTimeLabel.hidden = NO;
        _rightTimeLabel.hidden = NO;
    }
    
}
//设置进度条浮层消失
-(void) isshowSliderView :(BOOL) isShow
{
    if (isShow == YES) {
        _sliderView.hidden = YES;
    }else{
        _sliderView.hidden = NO;
    }
}
//设置滑动进度条消失
-(void) isshowSlider :(BOOL) isShow
{
    if (isShow == YES) {
        _slider.hidden = YES;
        _sliderView.pointView.hidden = YES;
    }else{
        _slider.hidden = NO;
        _sliderView.pointView.hidden = NO;
    }
}
//是否显示选择进度的进度条
-(void) isshowMySaVideo :(BOOL) isShow
{
    if (isShow == YES) {
        _mySAVideoRangeSlider.hidden = YES;
    }else{
        _mySAVideoRangeSlider.hidden = NO;
    }
}
//是否显示录音进度条
-(void) isshowRecorderView:(BOOL) isShow
{
    if (isShow == YES) {
        _recorderProgress.hidden = YES;
    }else{
        _recorderProgress.hidden = NO;
    }
}
//播放按钮消失
-(void) playerButtonHidden:(BOOL)isShowPlayerBtn
{
    if (isShowPlayerBtn == YES) {
        _playBtn.hidden = YES;
    }else{
        _playBtn.hidden = NO;
    }
}
// 透明进度条上的时间Label
-(void) playerSliderLabelHidden: (BOOL) isShowSliderLabel
{
    if (isShowSliderLabel == YES) {
        _currentTimeLabel.hidden = YES;
        _totalTimeLabel.hidden = YES;
    }else{
        _currentTimeLabel.hidden = NO;
        _currentTimeLabel.hidden = NO;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//-(void) setLastFrame
//{
//    //    CGFloat inset = _leftThumb.frame.size.width / 2;
//    //
//    //    _leftThumb.center = CGPointMake(_leftPosition+inset, _leftThumb.frame.size.height/2);
//    //    NSLog(@"%f",_leftThumb.frame.origin.x);
//    //    _rightThumb.center = CGPointMake(_rightPosition-inset, _rightThumb.frame.size.height/2);
//    //
//    //    _topBorder.frame = CGRectMake(_leftThumb.frame.origin.x + _leftThumb.frame.size.width, 0, _rightThumb.frame.origin.x - _leftThumb.frame.origin.x - _leftThumb.frame.size.width/2 -5, 3);
//    //
//    //    _bottomBorder.frame = CGRectMake(_leftThumb.frame.origin.x + _leftThumb.frame.size.width, _bgView.frame.size.height-3, _rightThumb.frame.origin.x - _leftThumb.frame.origin.x - _leftThumb.frame.size.width/2 -5, 3);
//    //
//    //
//    //    _centerView.frame = CGRectMake(_leftThumb.frame.origin.x + _leftThumb.frame.size.width, _centerView.frame.origin.y, _rightThumb.frame.origin.x - _leftThumb.frame.origin.x - _leftThumb.frame.size.width, _centerView.frame.size.height);
//    //
//    //
//    //    CGRect frame = _popoverBubble.frame;
//    //    frame.origin.x = _centerView.frame.origin.x+_centerView.frame.size.width/2-frame.size.width/2;
//    //    _popoverBubble.frame = frame;
//    
//    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
//    CGFloat inset = [state.leftThumbRect CGRectValue].size.width/2;
//    
//    _mySAVideoRangeSlider.leftThumb.center = CGPointMake([state.subtitleStartTime floatValue] +inset, [state.leftThumbRect CGRectValue].size.height/2);
//    _mySAVideoRangeSlider.rightThumb.center = CGPointMake([state.stopTime floatValue] +inset, [state.rightThumbRect CGRectValue].size.height/2);
//    
//    _mySAVideoRangeSlider.topBorder.frame = CGRectMake([state.leftThumbRect CGRectValue].origin.x +[state.leftThumbRect CGRectValue].size.width, 0, [state.rightThumbRect CGRectValue].origin.x -[state.leftThumbRect CGRectValue].origin.x -[state.leftThumbRect CGRectValue].size.width/2 -5,3);
//    _mySAVideoRangeSlider.bottomBorder.frame = CGRectMake([state.leftThumbRect CGRectValue].origin.x +[state.leftThumbRect CGRectValue].size.width, [state.sliderBGViewRect CGRectValue].size.height -3, [state.rightThumbRect CGRectValue].origin.x -[state.leftThumbRect CGRectValue].origin.x -[state.leftThumbRect CGRectValue].size.width/2 -5, 3);
//    _mySAVideoRangeSlider.centerView.frame = CGRectMake([state.leftThumbRect CGRectValue].origin.x +[state.leftThumbRect CGRectValue].size.width, _mySAVideoRangeSlider.centerView.frame.origin.y, [state.rightThumbRect CGRectValue].origin.x -[state.leftThumbRect CGRectValue].origin.x -[state.leftThumbRect CGRectValue].size.width, _mySAVideoRangeSlider.centerView.frame.size.height);
//    CGRect frame = [state.popViewRect CGRectValue];
//    frame.origin.x = _mySAVideoRangeSlider.centerView.frame.origin.x +_mySAVideoRangeSlider.centerView.frame.size.width/2 -frame.size.width/2;
//    _mySAVideoRangeSlider.popoverBubble.frame = frame;
//}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
