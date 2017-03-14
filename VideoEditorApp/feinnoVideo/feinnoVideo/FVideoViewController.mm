//
//  FVideoViewController.m
//  FVideo
//
//  Created by coCo on 14-9-1.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import "FVideoViewController.h"
#import "TitleViewController.h"
#import "ReconderViewController.h"
#import "playerView.h"
#import "Menu.h"
#import "DecorateViewController.h"
#import "MenuButton.h"
#import "NavigationBar.h"
#import "SecButtonStatus.h"
#import "MySlider.h"
#import "base/Common.h"
#import "PluginInterfaceInfo.h"
#import <base/typedef.h>
#import <base/thread_wrapper.h>
#import "Render.h"
#import "base/SynthesisParameterInfo.h"
#import "SynthesisParamterInstance.h"
#import <base/cMessageQueue.h>
#import "MBProgressHUD.h"
#import "base/FeinnoVideoState.h"
#import "AddTitleViewController.h"
#import <synthesis/video_template_audioeffect.h>
//#import "GDataXMLNode/GDataXMLNode.h"
#import "FVAudioPlayer.h"
#import <AssetsLibrary/AssetsLibrary.h>

//#import <ObjcClass.h>
//OBJC_CLASS(GPUImageView);

#ifndef kCFCoreFoundationVersionNumber_iOS_8_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.20
#endif

@interface FVideoViewController ()
{
    NavigationBar *_navBar;                 //导航栏
    UIScrollView *_menu;                    //一级菜单ScrollView
    UIView *_menuView;                      //一级菜单View
    UIView *_secMenuView;                   //二级菜单View
    NSArray *_firArr;
    NSArray *_imageArr;
    NSMutableArray *_subjectImageArr;              //主题菜单的image
    NSMutableArray *_musicImageArr;         //音乐菜单的image
    NSArray *_subjectTitleArr;              //主题菜单的title
    NSMutableArray *_filterImageArr;               //滤镜菜单的image
    NSMutableArray *_firButton;             //一级菜单的的buttonArr
    NSMutableArray *_secBottomButton;       //二级菜单中下层菜单Arr,若只有二级菜单的下层菜单则为下层菜单的Arr
    NSMutableArray *_secTopButton;          //二级菜单中上层菜单Arr,若只有一级菜带则为空
    SecButtonStatus *_secButtonStatus;      //二级button选中状态标示
    Menu *_videoMenu;
    MBProgressHUD *_hudProgess;
    UILabel *_hudCurrentProgess;
    UIImageView *_firImageView;             //视频的第一帧图片
    BOOL _device;                           //判断设备屏幕大小.yes为518,NO为480.
    UIButton *_saveBtn;                      //保存视频到相簿的button
    //zhiqiang-- UIImageView *_decorate;                  //装饰图片显示
    int _firTag;                            //一级菜单tag, 默认值为－1, 表示什么也没选中
    int _secTag;                            //二级菜单tag, 默认值为－1, 表示什么也没选中
    MBProgressHUD *_hudSwitchVideo;         //切换视频时的指示层
    UIImageView *_hudSwitchImage;
    MBProgressHUD *_hudSoundseach;
    UILabel *_soundShow;
    UIButton *_soundBtn;                     //关闭原音button
    BOOL _bShowSound;
    int _saveTag;
    NSString *_currentTime;
    
    UIButton* _playBtn;
    PlayerView* _playerView;
    
    
    Render* _render;
    GPUImageView* _gpuImageView;
    
    NSString* _preferenceAuxMusicFilePath;  //首选辅助播放的音乐
    
//    feinnovideotemplate::AudioEffect* _audioPlayer; //声音播放器
    FVAudioPlayer* _audioPlayer;
    // BOOL _bPlayingBgMusic;                  //是否正在播放声音
    // float _srcVideoVolumeValue;                 //原视频声音大小
      dispatch_semaphore_t _enterBackground;
    
}
@property(nonatomic, retain) PlayerView* playerView;

@end

@implementation FVideoViewController

- (id)init
{
    self = [super init];
    if (self) {
        _enterBackground = dispatch_semaphore_create(0);
        _preferenceAuxMusicFilePath = nil;
        _bEnableSrcSound = YES;
        _firTag = -1;
        _secTag = -1;
        // _bPlayingBgMusic = NO;
        _audioPlayer = [[FVAudioPlayer alloc] init];
        // _vcID =  VC_MAIN;
        _render = new Render(self);
        _gpuImageView = [[GPUImageView alloc] init];
        SynthesisParamterInstance::instance().setGPUImageView(_gpuImageView);
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"[FVideoViewController dealloc] is called");
    //*zhiqiang--
    if(_render!=NULL)
    {
        delete _render;
        _render = NULL;
    }
    //*/
    SynthesisParamterInstance::instance().setGPUImageView(nil);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initialize:(id)delegate withMediaPath:(NSString *)mediaPath withSavePath:(NSString*)savePath withPrevEditInfo:(NSString*)prevEditInfo
{
    NSLog(@"nav=%p, delegate=%p", self.navigationController, delegate);
    //检查资源是否存在
    NSString* srcPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/assets.zip"];
    NSString* dstPath = [Common getUnzipSynElementDirectory];
    NSLog(@"the destnation path = %@", dstPath);
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    if(![fileMgr fileExistsAtPath:dstPath])//TODO:这样做不方便迭代更新,因为没有自升级机制
    {
        [Common unzip:dstPath :srcPath];
    }
    
    [[PluginInterfaceInfo instance] input:delegate withMediaPath:mediaPath withSavePath:savePath withPrevEditInfo:prevEditInfo];
    [Common getEditDataInfo:(NSDictionary*)prevEditInfo];
    std::string _srcPath = std::string([mediaPath UTF8String]);
    SynthesisParamterInstance& instance = SynthesisParamterInstance::instance();
    instance.setSrcVideoPath(_srcPath);
    std::string _savepath = std::string([savePath UTF8String]);
    instance.setSaveVideoPath(_savepath);
}

- (void)viewWillDisappear:(BOOL)animated{
    if(_render != NULL){
        _render->Stop();
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    //zhiqiang--begin
//    if ([state.cartoonTag isEqualToString:@""] && [state.borderTag isEqualToString:@""]) {
//        _decorate.hidden = YES;
//    }else{
//        _decorate.image = [UIImage imageWithContentsOfFile:[Common getDecorateImagePath]];
//        NSLog(@"%@",[Common getDecorateImagePath]);
//    }
    //zhiqiang--end
    if (state.fVideoTag == 0) {
        [self getBackToCurrent:1];
    }else{
        [self getBackToCurrent:state.fVideoTag];
    }
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // 隐藏导航栏
//    _firButton
    //[self createSecView:[_firButton objectAtIndex:1]];
}

-(void)notifyEdited:(id)target
{
    [self isEnableSrcSound:YES];
    [self isHidePlayBtn:YES];
    if(_preferenceAuxMusicFilePath!=nil)
    {
        [self isEnableAuxSound:YES withMusicFilePath:_preferenceAuxMusicFilePath];
    }
    [self pushSynthesisMsg:SYN_MSG_PREVIEW];
}

-(void)enterBackgroup:(id)target
{
    NSLog(@"enterBackgroup");
    if(_render!=NULL)
    {
        _render->Pause();
      
        if (dispatch_semaphore_wait(_enterBackground, DISPATCH_TIME_NOW) != 0)
        {
            return;
        }
    }
}

-(void)enterForeground:(id)target
{
    _render->Resume();
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self generateLocalSavePath];
    //zhiqiang-- move from here to loadView method  _device = [Common getDeviceSize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyEdited:) name:@"NOTIFY_EDITED" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroup:) name:@"FVL_ENTER_BACKGROUD" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground:) name:@"FVL_ENTER_FOREGROUND" object:nil];
    
    self.view.userInteractionEnabled = YES;
    self.view.backgroundColor = [UIColor blackColor];
    /*zhiqiang--字幕功能不稳定 
        _firArr = [NSArray arrayWithObjects:@"主题",@"滤镜",@"配乐",@"装饰",@"字幕", nil];
        _imageArr = [NSArray arrayWithObjects:@"主题_normal.png",@"滤镜_normal.png",@"配乐_normal.png",@"装饰_normal.png",@"字幕_normal.png", nil];
        /*
        无主题-0, 梦境-1, 飘雪-3, 阳光-2, 音乐达人-5, 怀旧-8, 老电影-9, 雨-10
        无滤镜-0, 淡雅-3, 重彩-11 ,美白-6, 聚焦-7, 黑白-2, 浮雕-8, 描边-12, 漫画－1，移焦－4
        //*/
    _firArr = [NSArray arrayWithObjects:@"主题",@"滤镜",@"配乐",@"装饰", nil];
    _imageArr = [NSArray arrayWithObjects:@"主题_normal.png",@"滤镜_normal.png",@"配乐_normal.png",@"装饰_normal.png", nil];
    NSMutableArray* arrSubjectID = [NSMutableArray arrayWithObjects:@"0", @"1", @"3", @"2", @"5", @"8", @"9", @"10", nil];
//    NSMutableArray* _subjectImageArr1 = nil;
    _subjectImageArr = [[NSMutableArray alloc]init];
    int indexID = -1;
    NSString* folderID = nil;
    NSString* path = nil;
    for(NSInteger i=0; i<[arrSubjectID count]; ++i)
    {
        indexID = [(NSString*)([arrSubjectID objectAtIndex:i]) intValue];
        folderID = [Common getSynElementFolderPath:SYN_THEME withEleID:indexID];
        path = [NSString stringWithFormat:@"%@/icon.png", folderID];
        [_subjectImageArr addObject:path];
    }
    
    _filterImageArr=[[NSMutableArray alloc]init];
    NSMutableArray* arrFilterID = [NSMutableArray arrayWithObjects:@"0", @"3", @"11", @"6", @"7", @"2", @"8", @"12", @"1", @"4", nil];
    for(NSInteger i=0; i<[arrFilterID count]; ++i)
    {
        indexID = [(NSString*)([arrFilterID objectAtIndex:i]) intValue];
        folderID = [Common getSynElementFolderPath:SYN_FILTER withEleID:indexID];
        path = [NSString stringWithFormat:@"%@/icon.png", folderID];
        [_filterImageArr addObject:path];
    }
    _musicImageArr = [[NSMutableArray alloc] init];
    NSMutableArray *arrMusicID = [NSMutableArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9", nil];
    for(NSInteger i=0; i<[arrMusicID count]; ++i)
    {
        indexID = [(NSString*)([arrMusicID objectAtIndex:i]) intValue];
        folderID = [Common getSynElementFolderPath:SYN_BGMUSIC withEleID:indexID];
        path = [NSString stringWithFormat:@"%@/icon.png", folderID];
        [_musicImageArr addObject:path];
    }
    NSLog(@"%@",_musicImageArr);
    //[Common getSynElementFolderPath:synEleType withEleID:nID];
  //*/
    //_subjectImageArr = [NSArray arrayWithObjects:@"无滤镜.png",@"梦境.png",@"下雨.png",@"大话王.png",@"时间停止.png",@"电影预告.png",@"音乐达人.png",@"胶片.png",@"老电影", nil];
    // _filterImageArr = [NSArray arrayWithObjects:@"无滤镜.png",@"梦境.png",@"下雨.png",@"大话王.png",@"时间停止.png",@"电影预告.png",@"音乐达人.png",@"胶片.png",@"老电影",@"梦境.png",@"下雨.png",@"大话王.png",@"时间停止.png",nil];
    _subjectTitleArr = [NSArray arrayWithObjects:@"无滤镜",@"梦境",@"花语",@"大话王",@"静止",@"片头",@"音乐达人",@"胶片",@"老相框",nil];
    _firButton = [[NSMutableArray alloc] init];
    _secBottomButton = [[NSMutableArray alloc] init];
    _secTopButton = [[NSMutableArray alloc] init];
    _secButtonStatus = [[SecButtonStatus alloc] init];
    _videoMenu = [[Menu alloc] init];
    // _isShowSound = YES;
    [self layout];
    //[self getBackToCurrent:1];
}

-(void) pushSynthesisMsg:(int)msgID
{
    assert(msgID==SYN_MSG_SAVE || msgID==SYN_MSG_PREVIEW);
    [self isHidePlayBtn:YES];
   SynthesisParamterInstance& instance = SynthesisParamterInstance::instance();
//    MessageData* msgData = new TypedMessageData<SynthesisParameterInfo>(instance.allParamters());
    // _render->push(SYN_MSG_PREVIEW, msgData);
    //    delete msgData;
    //zhiqiang--
    //  instance.setSynthesisMessageID((SYN_MESSAGE_ID)msgID);
    RenderMessage* renderMsg = new RenderMessage();
    
    renderMsg->message_id = msgID;
    renderMsg->data = &instance;
    _render->push(renderMsg);
}

-(void) startPlay
{
    PluginInterfaceInfo* plugin = [PluginInterfaceInfo instance];
    NSLog(@"src media file name = %@", [plugin srcVideoPath]);
    NSLog(@"startPlay");
    [self pushSynthesisMsg:SYN_MSG_PREVIEW];
}

-(void) stopPlay
{
    if(_render!=NULL)
    {
        _render->Stop();
    }
    [self isEnableSrcSound:NO];
    [self isEnableAuxSound:NO withMusicFilePath:_preferenceAuxMusicFilePath];
    [self isHidePlayBtn:NO];
    NSLog(@"stopPlay");
}

-(void) loadView
{
    [super loadView];
     _device = [Common getDeviceSize];
    if (_device == YES) {
        //   self.navigationController.navigationBar
        _navBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 61)
                                             titleText:@"预览"
                                      leftButtonTarget:self
                                      leftButtonAction:@selector(clickBackButton)
                                       leftButtonImage:[UIImage imageNamed:@"上一步_normal.png"]
                               leftSelectedButtonImage:[UIImage imageNamed:@"上一步_down.png"]
                                     rightButtonTarget:self
                                     rightButtonAction:@selector(clickSureButton)
                                      rightButtonImage:nil
                              rightSelectedButtonImage:nil
                                           rightBtnTag:900];
    }else{
        _navBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 51) titleText:@"预览"
                                      leftButtonTarget:self
                                      leftButtonAction:@selector(clickBackButton)
                                       leftButtonImage:[UIImage imageNamed:@"上一步_normal.png"]
                               leftSelectedButtonImage:[UIImage imageNamed:@"上一步_down.png"]
                                     rightButtonTarget:self
                                     rightButtonAction:@selector(clickSureButton)
                                      rightButtonImage:nil
                              rightSelectedButtonImage:nil
                                           rightBtnTag:900];
    }
}

-(void) layout
{
#pragma mark - 导航栏
    [self.view addSubview:_navBar];
  
    [_navBar.titleLabel removeFromSuperview];

    _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveBtn.frame = CGRectMake(_navBar.frame.size.width/2 -15, _navBar.frame.size.height/2 -15, 30, 30);
    [_saveBtn setImage:[UIImage imageNamed:@"btn_save_normal@2x.png"] forState:UIControlStateNormal];
    [_saveBtn setImage:[UIImage imageNamed:@"btn_save_hover@2x.png"] forState:UIControlStateHighlighted];
    _saveBtn.backgroundColor = [UIColor clearColor];
    _saveBtn.tag = 999;
    [_saveBtn addTarget:self action:@selector(saveVideo:) forControlEvents:UIControlEventTouchUpInside];
    [_navBar addSubview:_saveBtn];
    
    
#pragma mark - 视频播放器

    _firImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _navBar.frame.size.height, 320, 320)];
    _firImageView.image = [Common firstVideoFrameImage:[[PluginInterfaceInfo instance] srcVideoPath]];
    [self.view addSubview:_firImageView];
    //zhiqiang-- 合成模块会负责处理，这里无需处理
//    if ([Common getDecorateImagePath] != nil) {
//        _decorate = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
//        _decorate.image = [UIImage imageWithContentsOfFile:[Common getDecorateImagePath]];
//        [_firImageView addSubview:_decorate];
//    }
    //*/
    
#pragma mark - 菜单布局
    // 第一级菜单的滚动视图
    if (_device == YES) {
        _menu = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -54, self.view.frame.size.width, 54)];
    }else{
        _menu = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -38, self.view.frame.size.width, 38)];
    }
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80 *_firArr.count, _menu.frame.size.height)];
    //NSLog(@"%f",_menu.frame.origin.y);
    _menu.backgroundColor = [UIColor darkGrayColor];
    _menu.showsHorizontalScrollIndicator = NO;
    _menu.contentSize = _menuView.frame.size;
    _menu.bounces = YES;
    
    // 第二级菜单的View
    [self.view addSubview:_menu];
    [self createMenuButtonTitleArr:_firArr imageArr:_imageArr];
    [_menu addSubview:_menuView];
    [self.view bringSubviewToFront:_navBar];
    
     _gpuImageView.userInteractionEnabled = YES;
    _gpuImageView.frame = CGRectMake(0, _navBar.frame.size.height, 320, 320);
    PluginInterfaceInfo* plugin = [PluginInterfaceInfo instance];
    self.playerView = [[PlayerView alloc] initAudioPlayer:_gpuImageView withMediatPath:[plugin srcVideoPath] withInteractionEnable:YES withEventFeedback:self];
    [self.view addSubview:_gpuImageView];
    _soundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _soundBtn.frame = CGRectMake(self.view.frame.size.width -24 -12, self.view.frame.origin.x +_navBar.frame.size.height +_gpuImageView.frame.size.height -34, 24, 24);
    [_soundBtn setBackgroundColor:[UIColor redColor]];
    _soundBtn.layer.masksToBounds = YES;
    _soundBtn.layer.cornerRadius = 12;
    [_soundBtn addTarget:self action:@selector(setPlayerSound:) forControlEvents:UIControlEventTouchUpInside];
    [_soundBtn setImage:[UIImage imageNamed:@"消除原音_unselected.png"] forState:UIControlStateNormal];
    _soundBtn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_soundBtn];
    [self.view bringSubviewToFront:_soundBtn];
}
#pragma mark - 创建按钮视图----------------------------------------------------------------
// 创建一级菜单的button
-(void) createMenuButtonTitleArr:(NSArray *)titleArray imageArr:(NSArray *)imageArr
{
    for (int i = 0; i < titleArray.count; i++){
        MenuButton *btn = [[MenuButton alloc] initWithButtonFrame:CGRectMake(80 *i, 0, self.view.frame.size.width/3, _menu.frame.size.height)
                                                 buttonImageFrame:CGRectMake(12, _menu.frame.size.height/2 -10.5, 21, 21)
                                                 buttonTitleFrame:CGRectMake(39, _menu.frame.size.height/2 -10.5, 30, 21)
                                                 buttonImage:[UIImage imageNamed:[imageArr objectAtIndex:i]]
                                                 buttonTitle:[titleArray objectAtIndex:i] titleFont:13 buttonTag:i+1
                                                 buttonSelected:NO buttonBackgroundImage:nil clickButtonTarget:self
                                                 clickButtonTarget:@selector(createSecView:) buttonCornerRadius:0 device:nil];
        //        if (i == 0) {
        //            btn.imageView.image = [UIImage imageNamed:@"主题_selected.png"];
        //            btn.titleView.textColor = [UIColor colorWithRed:238.0/255 green:104.0/255 blue:62.0/255 alpha:1];
        //        }
        [_firButton addObject:btn];
        [_menuView addSubview:btn];
    }
}
// 一级菜单的点击事件
-(void) createSecView:(id)sender
{
    MenuButton *btn = (MenuButton *)[sender view];
    if (btn.tag == _firTag) {
        NSLog(@"当前的button已经显示");
        return;
    }
    [_secMenuView removeFromSuperview];
    for (MenuButton *allButton in _firButton) {
        allButton.selected = NO;
        allButton.titleView.textColor = [UIColor whiteColor];
        NSLog(@"%d",allButton.tag);
        allButton.imageView.image = [UIImage imageNamed:[_imageArr objectAtIndex:allButton.tag -1]];
        allButton.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:41.0/255.0 blue:41.0/255.0 alpha:1.0];
    }
    NSLog(@"btn.tag:%d",btn.tag);
    //重新加载所需的控件
    if (btn.tag == 1) {
//        [self isshowSliderView:NO];
//        [self isshowSlider:NO];
        FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
        state.fVideoTag = btn.tag;
        btn.selected = YES;
        _firTag = btn.tag;
        btn.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:1.0];
        [btn.titleView setTextColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1]];
        btn.imageView.image = [UIImage imageNamed:@"主题_selected.png"];
        //btn.backgroundColor = [UIColor colorWithRed:30.0/255 green:30.0/255 blue:30.0/255 alpha:1];
        //NSArray *titleArr = [NSArray arrayWithObjects:@"无滤镜",@"梦境",@"花语",@"大话王",@"静止",@"片头",@"音乐达人",@"胶片",@"老相框",nil];
        NSArray *titleArr = [NSArray arrayWithObjects:@"无主题",@"梦境",@"飘雪",@"阳光",@"音乐达人",@"怀旧",@"老电影",@"雨",nil];
        int tag = btn.tag *100;
        [Common MoveView:_secMenuView To:CGRectMake(_secMenuView.frame.origin.x, _secMenuView.frame.origin.y +((self.view.frame.size.height -_menuView.frame.size.height -_navBar.frame.size.height - 320 -71)/2) +_menuView.frame.size.height, _secMenuView.frame.size.width,_secMenuView.frame.size.height) During:0.5];
        [_secBottomButton removeAllObjects];
        _videoMenu.firMenuButtonTag = btn.tag;
        [self createSecendMenuBottomViewArr:titleArr
                           secondTopViewArr:nil
                           secMenuButtonTag:tag
                              secMenuTopTag:0
                             secBottomLabel:nil
                                secTopLabel:nil
                         menuBottomImageArr:_subjectImageArr];
         if (_device == YES){
             [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_menu.frame.size.height -_secMenuView.frame.size.height -16, self.view.frame.size.width, _secMenuView.frame.size.height) During:0.5];
         }else{
             [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_menu.frame.size.height -71 -((self.view.frame.size.height -_menu.frame.size.height -_navBar.frame.size.height - 320 -71)/2), self.view.frame.size.width, 71) During:0.5];
         }
        NSLog(@"%f",((self.view.frame.size.height -_menu.frame.size.height -_navBar.frame.size.height - self.playerView.frame.size.height -71)/2));
    }else if (btn.tag == 2){
        FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
        state.fVideoTag = btn.tag;
        btn.selected = YES;
        _firTag = btn.tag;
        btn.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:1.0];
        [btn.titleView setTextColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1]];
        btn.imageView.image = [UIImage imageNamed:@"滤镜_selected.png"];
        // NSArray *titleArr = [NSArray arrayWithObjects:@"默认",@"曝光",@"马赛克",@"饱和",@"边缘",@"黑白",@"业余",@"怀旧",@"蓝调",@"美白",@"聚焦",@"浮雕",@"色相", nil];
        NSArray *titleArr = [NSArray arrayWithObjects:@"无滤镜", @"淡雅", @"重彩", @"美白", @"聚焦", @"黑白", @"浮雕", @"描边",  @"漫画", @"移焦", nil];
        int tag = btn.tag *100;
        [Common MoveView:_secMenuView To:CGRectMake(_secMenuView.frame.origin.x, _secMenuView.frame.origin.y +((self.view.frame.size.height -_menu.frame.size.height -_navBar.frame.size.height - 320 -71)/2) +_menu.frame.size.height, _secMenuView.frame.size.width,_secMenuView.frame.size.height) During:0.5];
        [_secBottomButton removeAllObjects];
        _videoMenu.firMenuButtonTag = btn.tag;
        [self createSecendMenuBottomViewArr:titleArr
                           secondTopViewArr:nil
                           secMenuButtonTag:tag
                              secMenuTopTag:0
                             secBottomLabel:nil
                                secTopLabel:nil
                         menuBottomImageArr:_filterImageArr];
        if (_device == YES) {
           [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_menu.frame.size.height -_secMenuView.frame.size.height -16, self.view.frame.size.width, _secMenuView.frame.size.height) During:0.5];
        }else{
            [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_menu.frame.size.height -71 -((self.view.frame.size.height -_menu.frame.size.height -_navBar.frame.size.height - 320 -71)/2), self.view.frame.size.width, 71) During:0.5];
        }
        NSLog(@"%f",((self.view.frame.size.height -_menuView.frame.size.height -_navBar.frame.size.height - self.playerView.frame.size.height -71)/2));
    }else if (btn.tag == 3){
        FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
        state.fVideoTag = btn.tag;
//        [self isshowSliderView:NO];
//        [self isshowSlider:NO];
//        [self soundBtnHidden:NO];
        btn.selected = YES;
        _firTag = btn.tag;
        btn.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:1.0];
        [btn.titleView setTextColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1]];
        btn.imageView.image = [UIImage imageNamed:@"配乐_selected.png"];
        NSArray *titleArr = [NSArray arrayWithObjects:@"无配乐",@"中国风",@"乡村风",@"动感",@"壮阔自然",@"快乐颂",@"时尚科技",@"浪漫",@"爱情恋曲",@"轻松诙谐", nil];
        int tag = btn.tag *100;
        [Common MoveView:_secMenuView To:CGRectMake(_secMenuView.frame.origin.x, _secMenuView.frame.origin.y +((self.view.frame.size.height -_menuView.frame.size.height -_navBar.frame.size.height - 320 -71)/2) +_menuView.frame.size.height, _secMenuView.frame.size.width,_secMenuView.frame.size.height) During:0.5];
        [_secBottomButton removeAllObjects];
        _videoMenu.firMenuButtonTag = btn.tag;
        [self createSecendMenuBottomViewArr:titleArr
                           secondTopViewArr:nil
                           secMenuButtonTag:tag
                              secMenuTopTag:0
                             secBottomLabel:nil
                                secTopLabel:nil
                         menuBottomImageArr:_musicImageArr];
        if (_device == YES) {
            [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_menu.frame.size.height -_secMenuView.frame.size.height -16, self.view.frame.size.width, _secMenuView.frame.size.height) During:0.5];
        }else{
            [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_menu.frame.size.height -71 -((self.view.frame.size.height -_menu.frame.size.height -_navBar.frame.size.height - 320 -71)/2), self.view.frame.size.width, 71) During:0.5];
        }
    }else if (btn.tag == 4){
        //        btn.selected = YES;
        //        [btn.titleLabel setTextColor:[UIColor blackColor]];
        //        int bottomTag = btn.tag *100;
        //        int topTag = btn.tag *10;
        //        NSString *bottomText = [NSString stringWithFormat:@"卡通"];
        //        NSString *topText = [NSString stringWithFormat:@"边框"];
        //        NSArray *musicArr = [NSArray arrayWithObjects:@"默认",@"帽子",@"丝带",@"白云",@"汪星人",@"黑土", nil];
        //        NSArray *laloArr = [NSArray arrayWithObjects:@"无卡通",@"",@"",@"",@"",@"", nil];
        //        [self createSecendMenuBottomViewArr:musicArr
        //                           secondTopViewArr:laloArr
        //                           secMenuButtonTag:bottomTag
        //                              secMenuTopTag:topTag
        //                             secBottomLabel:bottomText
        //                                secTopLabel:topText];
        _firTag = 5;
        DecorateViewController *decorate = [[DecorateViewController alloc] init];
        [self.navigationController pushViewController:decorate animated:YES];
    }else if (btn.tag == 5){
        TitleViewController *title = [[TitleViewController alloc] init];
        [self.navigationController pushViewController:title animated:YES];
    }else if (btn.tag == 6){
        ReconderViewController *dub = [[ReconderViewController alloc] init];
        [self.navigationController pushViewController:dub animated:YES];
        //    }
        //    [UIView animateWithDuration:0.5 animations:^{
        //        CGRect frame = _secMenuView.frame;
        //        frame.origin.y -= 120;
        //        _secMenuView.frame = frame;
        //    }];
        //NSLog(@"_secMenuView:%f",_secMenuView.frame.origin.y);
        //[btn setEnabled:YES];
    }
    if(4==btn.tag || 5==btn.tag || 6==btn.tag)
    {
        [self closeAllSound];
        _render->Stop();
    }
}

//创建二级View
-(void) createSecendMenuBottomViewArr:(NSArray *)secBottomArr
                     secondTopViewArr:(NSArray *)secTopArr
                     secMenuButtonTag:(int)bottomButtonTag
                        secMenuTopTag:(int)topButtonTag
                       secBottomLabel:(NSString *)bottomButtonText
                          secTopLabel:(NSString *)topButtonText
                   menuBottomImageArr:(NSArray *)bottomImageArray
{
//    _secMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -_menuView.frame.size.height -71 -((self.view.frame.size.height -_menuView.frame.size.height -_navBar.frame.size.height - _firImageView.frame.size.height -71)/2), self.view.frame.size.width, 71)];
    if (_device == YES) {
        _secMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 87)];
    }else{
        _secMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -_menu.frame.size.height, self.view.frame.size.width, 71)];
    }
    _secMenuView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_secMenuView];
    [self.view bringSubviewToFront:_menu];
    if (secTopArr != nil) {
        
        //拥有两个二级菜单
        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 189 +(52 +19) *(secBottomArr.count -2), 71)];
        bottom.backgroundColor = [UIColor darkGrayColor];
        
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        bottomLabel.text = bottomButtonText;
        bottomLabel.textAlignment = NSTextAlignmentCenter;
        bottomLabel.backgroundColor = [UIColor darkGrayColor];
        [_secMenuView addSubview:bottomLabel];
        
        UIScrollView *bottomScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(60, 0, 260, 60)];
        bottomScroll.backgroundColor = [UIColor blackColor];
        bottomScroll.contentSize = bottom.frame.size;
        bottomScroll.showsHorizontalScrollIndicator = NO;
        bottomScroll.bounces = NO;
        [bottomScroll addSubview:bottom];
        [_secMenuView addSubview:bottomScroll];
        
        UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (60 +5) *secTopArr.count +5, 60)];
        top.backgroundColor = [UIColor darkGrayColor];
        
        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, 60, 60)];
        topLabel.text = topButtonText;
        topLabel.textAlignment = NSTextAlignmentCenter;
        topLabel.backgroundColor = [UIColor darkGrayColor];
        [_secMenuView addSubview:topLabel];
        
        UIScrollView *topScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(60, 60, 260, 60)];
        topScroll.backgroundColor = [UIColor darkGrayColor];
        topScroll.contentSize = top.frame.size;
        topScroll.showsHorizontalScrollIndicator = NO;
        topScroll.bounces = NO;
        [topScroll addSubview:top];
        [_secMenuView addSubview:topScroll];
        
        Menu *secMenu = [[Menu alloc] init];
        secMenu.bottomArr = secBottomArr;
        secMenu.topArr = secTopArr;
        secMenu.bottomTag = bottomButtonTag;
        secMenu.topTag = topButtonTag;
        secMenu.bottomView = bottom;
        secMenu.topView = top;
        [self createMenuBottomButtonArr:secMenu.bottomArr
                       menuTopButtonArr:secMenu.topArr
                      secMenuBottomView:secMenu.bottomView
                         secMenuTopView:secMenu.topView
                 secMenuButtonBottomTag:secMenu.bottomTag
                          secMenuTopTag:secMenu.topTag
                     menuBottomImageArr:bottomImageArray];
    }else{
        //只有一个二级菜单
        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 0,(52+16) *(secBottomArr.count) +11, _secMenuView.frame.size.height)];
        NSLog(@"%f",bottom.frame.size.width);
        bottom.backgroundColor = [UIColor blackColor];
        
        UIScrollView *bottomScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, _secMenuView.frame.size.height)];
        bottomScroll.backgroundColor = [UIColor blackColor];
        bottomScroll.contentSize = bottom.frame.size;
        bottomScroll.showsHorizontalScrollIndicator = NO;
        bottomScroll.bounces = YES;
        [bottomScroll addSubview:bottom];
        [_secMenuView addSubview:bottomScroll];
        [self createMenuBottomButtonArr:secBottomArr
                       menuTopButtonArr:nil
                      secMenuBottomView:bottom
                         secMenuTopView:nil
                 secMenuButtonBottomTag:bottomButtonTag
                          secMenuTopTag:0
                     menuBottomImageArr:bottomImageArray];
    }
}

// 创建二级菜单的button
-(void) createMenuBottomButtonArr:(NSArray *)bottomArray
                 menuTopButtonArr:(NSArray *)topArray
                secMenuBottomView:(UIView *)bottomView
                   secMenuTopView:(UIView *)topView
           secMenuButtonBottomTag:(int)secBottomBtnTag
                    secMenuTopTag:(int)secTopBtnTag
               menuBottomImageArr:(NSArray *)bottomImageArray
{
    NSLog(@"........%d",secBottomBtnTag);
    if (topArray == nil) {
        //bottomView.backgroundColor = [UIColor colorWithRed:15.0/255 green:15.0/255 blue:15.0/255 alpha:1];
        bottomView.backgroundColor = [UIColor blackColor];
        for (int i = 0; i < bottomArray.count; i++){
            if (i == 0) {
                if (_device == YES) {
                    MenuButton *btn = [[MenuButton alloc] initWithButtonFrame:CGRectMake(9, _secMenuView.frame.size.height/2 - 52/2 -17, 52, 52 +25) buttonImageFrame:CGRectMake(1, 1, 50, 50) buttonTitleFrame:CGRectMake(0, 62, 52, 15) buttonImage:[UIImage imageWithContentsOfFile:[bottomImageArray objectAtIndex:i]] buttonTitle:[bottomArray objectAtIndex:i] titleFont:11 buttonTag:secBottomBtnTag +i buttonSelected:NO buttonBackgroundImage:[UIImage imageNamed:@"滤镜_缩略图选中框黑色.png"] clickButtonTarget:self clickButtonTarget:@selector(tapAction:) buttonCornerRadius:3.0 device:_device];
                    btn.titleView.textColor = [UIColor whiteColor];
                    [_secBottomButton addObject:btn];
                    [bottomView addSubview:btn];

                }else{
                    MenuButton *btn = [[MenuButton alloc] initWithButtonFrame:CGRectMake(9, _secMenuView.frame.size.height/2 - 52/2, 52, 52) buttonImageFrame:CGRectMake(1, 1, 50, 50) buttonTitleFrame:CGRectMake(5, 72, 52, 15) buttonImage:[UIImage imageWithContentsOfFile:[bottomImageArray objectAtIndex:i]] buttonTitle:[bottomArray objectAtIndex:i] titleFont:11 buttonTag:secBottomBtnTag +i buttonSelected:NO buttonBackgroundImage:[UIImage imageNamed:@"滤镜_缩略图选中框黑色.png"] clickButtonTarget:self clickButtonTarget:@selector(tapAction:) buttonCornerRadius:3.0 device:_device];
                    [_secBottomButton addObject:btn];
                    [bottomView addSubview:btn];
                }
            }else{
                NSLog(@"2222222%@",[bottomImageArray objectAtIndex:i]);
                if (_device == YES) {
                    MenuButton *btn = [[MenuButton alloc] initWithButtonFrame:CGRectMake(52*i +18*i +1, _secMenuView.frame.size.height/2 -52/2 -17, 52, 52 +25) buttonImageFrame:CGRectMake(1, 1, 50, 50) buttonTitleFrame:CGRectMake(0, 62, 52, 15) buttonImage:[UIImage imageWithContentsOfFile:[bottomImageArray objectAtIndex:i]] buttonTitle:[bottomArray objectAtIndex:i] titleFont:11 buttonTag:secBottomBtnTag +i buttonSelected:NO buttonBackgroundImage:[UIImage imageNamed:@"滤镜_缩略图选中框黑色.png"] clickButtonTarget:self clickButtonTarget:@selector(tapAction:) buttonCornerRadius:3.0 device:_device];
                    [_secBottomButton addObject:btn];
                    [bottomView addSubview:btn];

                }else{
                    MenuButton *btn = [[MenuButton alloc] initWithButtonFrame:CGRectMake(52*i +18*i +1, _secMenuView.frame.size.height/2 -52/2, 52, 52) buttonImageFrame:CGRectMake(1, 1, 50, 50) buttonTitleFrame:CGRectMake(7, 37, 40, 15) buttonImage:[UIImage imageWithContentsOfFile:[bottomImageArray objectAtIndex:i]] buttonTitle:[bottomArray objectAtIndex:i] titleFont:11 buttonTag:secBottomBtnTag +i buttonSelected:NO buttonBackgroundImage:[UIImage imageNamed:@"滤镜_缩略图选中框黑色.png"] clickButtonTarget:self clickButtonTarget:@selector(tapAction:) buttonCornerRadius:3.0 device:_device];
                    [_secBottomButton addObject:btn];
                    [bottomView addSubview:btn];
                }
            }
        }
        switch (_videoMenu.firMenuButtonTag) {
            case 1:
                if (_secButtonStatus.selectedSubjectTag != 0) {
                    //NSLog(@"设置选中");
                    MenuButton *btn = [_secBottomButton objectAtIndex:_secButtonStatus.selectedSubjectTag-100];
                    btn.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框.png"];
                }else{
                    MenuButton *btn = [_secBottomButton objectAtIndex:0];
                    btn.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框.png"];
                }
                break;
            case 2:
                if (_secButtonStatus.selectedFilterTag != 0) {
                    //NSLog(@"设置选中");
                    NSLog(@"%d",_secButtonStatus.selectedFilterTag);
                    MenuButton *btn = [_secBottomButton objectAtIndex:_secButtonStatus.selectedFilterTag-200];
                    btn.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框.png"];
                }else{
                    MenuButton *btn = [_secBottomButton objectAtIndex:0];
                    btn.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框.png"];
                }
                break;
                
            default:
                if (_secButtonStatus.selectedMusicTag != 0) {
                    //NSLog(@"设置选中");
                    MenuButton *btn = [_secBottomButton objectAtIndex:_secButtonStatus.selectedMusicTag-300];
                    btn.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框.png"];
                }else{
                    MenuButton *btn = [_secBottomButton objectAtIndex:0];
                    btn.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框.png"];
                }
                break;
        }
        
    }else{
        Menu *menuBtn = [[Menu alloc] init];
        menuBtn.bottomArr = bottomArray;
        menuBtn.topArr = topArray;
        menuBtn.bottomView = bottomView;
        menuBtn.topView = topView;
        menuBtn.bottomTag = secBottomBtnTag;
        menuBtn.topTag = secTopBtnTag;
        
        float bottomWidth = menuBtn.bottomView.frame.size.width / menuBtn.bottomArr.count;
        for (int i = 0; i < menuBtn.bottomArr.count; i++){
            UIButton *btn = [[UIButton alloc] init];
            [btn setTitle:[menuBtn.bottomArr objectAtIndex:i] forState:UIControlStateNormal];
            [btn setFrame:CGRectMake(bottomWidth *i +5, bottomView.frame.size.height - 45, bottomWidth -25, bottomWidth-25)];
            //NSLog(@"%f",width);
            btn.backgroundColor = [UIColor yellowColor];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            //[btn.titleLabel setTextColor:[UIColor blackColor]];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 20.0;
            [btn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = menuBtn.bottomTag +i;
            if (btn.tag == 400) {
                btn.layer.borderWidth = 1.0;
                btn.layer.borderColor = [[UIColor redColor]CGColor];
            }
            [_secBottomButton addObject:btn];
            //NSLog(@"两个二级菜单的TopButton:%@",_secBottomButton);
            [menuBtn.bottomView addSubview:btn];
        }
        float topWidth =  menuBtn.topView.frame.size.width / menuBtn.topArr.count;
        for (int i = 0; i < menuBtn.topArr.count; i++){
            UIButton *btn = [[UIButton alloc] init];
            [btn setTitle:[menuBtn.topArr objectAtIndex:i] forState:UIControlStateNormal];
            [btn setFrame:CGRectMake(topWidth *i +5, topView.frame.size.height - 45, topWidth -25, topWidth-25)];
            //NSLog(@"%f",width);
            btn.backgroundColor = [UIColor yellowColor];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            //[btn.titleLabel setTextColor:[UIColor blackColor]];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 20.0;
            [btn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = menuBtn.topTag +i;
            if (btn.tag == 40) {
                btn.layer.borderWidth = 1.0;
                btn.layer.borderColor = [[UIColor redColor]CGColor];
            }
            [_secTopButton addObject:btn];
            //NSLog(@"两个二级菜单的BottomButton:%@",_secTopButton);
            [menuBtn.topView addSubview:btn];
        }
    }
}
// 点击二级button的响应事件
-(void) tapAction:(id) sender
{
    MenuButton *btn = (MenuButton *)[sender view];
    if (btn.tag == _secTag) {
        return;
    }
    //NSLog(@"我的Tag值是:%d",btn.tag);
    //NSLog(@"我的Title是:%@",btn.titleView);
    for (MenuButton *allButton in _secBottomButton) {
        //NSLog(@"%@",_secBottomButton);
        allButton.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框黑色.png"];
        //NSLog(@"%hhd",allButton.selected);
        allButton.titleView.textColor = [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
    }
    [self switchVideoResult];
    
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    NSLog(@"选中的二级button的tag:%d",btn.tag);
    if (btn.tag <200 && btn.tag >=100) {
        _secButtonStatus.selectedSubjectTag = btn.tag;
        _secTag = btn.tag;
        state.subTag = btn.tag;
        [self launchTheme:btn.tag];
        //NSLog(@"主题:%d",_secButtonStatus.selectedSubjectTag);
    }else if (btn.tag < 300 && btn.tag >=200){
        _secButtonStatus.selectedFilterTag = btn.tag;
        _secTag = btn.tag;
        state.filterTag = btn.tag;
        [self launchFilter:btn.tag];
        //NSLog(@"滤镜:%d",_secButtonStatus.selectedFilterTag);
    }else if (btn.tag < 400 && btn.tag >=300){
        _secButtonStatus.selectedMusicTag = btn.tag;
        _secTag = btn.tag;
        state.bgmusicTag = btn.tag;
        [self launchBgMusic:btn.tag];
        //NSLog(@"配乐:%d",_secButtonStatus.selectedMusicTag);
    }
    
    btn.titleView.textColor = [UIColor whiteColor];
    btn.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框.png"];
}

// 主题
-(void) launchTheme:(int)nId
{
    /*
        无主题-0, 梦境-1, 飘雪-3, 阳光-2, 音乐达人-5, 怀旧-8, 老电影-9, 雨-10
        //*/
    //int sID = 0;
    int fileID = -1;
    NSString* musicFilePath = [self _getMatchFileInfo:SYN_THEME withTagID:nId withReturnFileID:&fileID];
    if(musicFilePath!=nil)
    {
        _preferenceAuxMusicFilePath = musicFilePath;//[musicFilePath copy]
        [self isEnableAuxSound:YES withMusicFilePath:_preferenceAuxMusicFilePath];
    }
    else
    {
        //无主题
        _preferenceAuxMusicFilePath = nil;
        [self isEnableAuxSound:NO withMusicFilePath:nil];
    }
    [self isHidePlayBtn:YES];
    [self isEnableSrcSound:_bEnableSrcSound];
    [self pushSynthesisMsg:SYN_MSG_PREVIEW];
}

// 滤镜
-(void) launchFilter:(int)nId
{
    int fileID = -1;
    NSString* musicFilePath = [self _getMatchFileInfo:SYN_FILTER withTagID:nId withReturnFileID:&fileID];
    if(_preferenceAuxMusicFilePath!=nil)
    {
        [self isEnableAuxSound:YES withMusicFilePath:_preferenceAuxMusicFilePath];
    }
    [self isHidePlayBtn:YES];
    [self isEnableSrcSound:_bEnableSrcSound];
    [self pushSynthesisMsg:SYN_MSG_PREVIEW];
}
// 配乐
-(void) launchBgMusic:(int)nId
{
    int fileID = -1;
    NSString* musicFilePath = [self _getMatchFileInfo:SYN_BGMUSIC withTagID:nId withReturnFileID:&fileID];
    if(musicFilePath!=nil)
    {
        _preferenceAuxMusicFilePath = musicFilePath; //[musicFilePath copy];
        [self isEnableAuxSound:YES withMusicFilePath:_preferenceAuxMusicFilePath];
    }
    else
    {
        //无配乐
        _preferenceAuxMusicFilePath = nil;
        [self isEnableAuxSound:NO withMusicFilePath:nil];
    }
    [self isHidePlayBtn:YES];
    [self isEnableSrcSound:_bEnableSrcSound];
    [self pushSynthesisMsg:SYN_MSG_PREVIEW];
}

/*
 @param1:bEnable: NO--禁用所有声音,如退出，从主页面切换到装饰页面，点击主页面确认，保存或装饰页面确认
                                YES--需要按上述优先级处理
 @param2:audioFilePath:声音播放
//*/
-(void) isEnableAuxSound:(BOOL)bEnable withMusicFilePath:(NSString*)audioFilePath
{
    if(bEnable)
    {
        [_audioPlayer stop];
        if(audioFilePath!=nil)
        {
            [_audioPlayer start:audioFilePath];
        }
    }
    else
    {
        //配乐或主题被关闭
        [_audioPlayer stop];
    }
}

-(void) isEnableSrcSound:(BOOL)bEnable
{
    if(bEnable)
    {
        [self.playerView startPlay:_bEnableSrcSound];
//
//        self.playerView.player.volume = 1.0;
//        [self.playerView.player play];
    }
    else
    {
        [self.playerView stopPlay];
//        self.playerView.player.volume = 0.0;
//        [self.playerView.player pause];
    }
    // [self isHidePlayBtn:bEnable];
}

-(void) isHidePlayBtn:(BOOL)bHide
{
    [self.playerView isHidePlayBtn:bHide];
}

-(void) closeAllSound
{
    [self isEnableSrcSound:NO];
    [self isHidePlayBtn:NO];
    [self isEnableAuxSound:NO withMusicFilePath:nil];
}

-(void) closeRender
{
    if(_render!=NULL)
    {
        delete _render;
        _render = NULL;
    }
}

//返回按钮响应事件
-(void) clickBackButton
{
    [self closeAllSound];//停止配乐播放
    _render->Exit();
    NSLog(@"%p", self.navigationController);
    [self.navigationController popViewControllerAnimated:YES];
    [self closeRender];
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    state = nil;
}

//导航栏确定按钮
-(void) clickSureButton
{
    [self closeAllSound];
    [self pushSynthesisMsg:SYN_MSG_SAVE];
    [self proto_createSynthesisProgressDialog];
}

-(void) proto_createSynthesisProgressDialog
{
    if(_hudProgess!=nil)
    {
        _hudProgess = nil;
    }
    _hudProgess = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:_hudProgess];
    _hudProgess.customView = [[UIView alloc] initWithFrame:CGRectMake(160, self.view.frame.size.height -180, 60, 60)];
    _hudCurrentProgess = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    _hudCurrentProgess.backgroundColor = [UIColor clearColor];
    _hudCurrentProgess.textColor = [UIColor whiteColor];
    _hudCurrentProgess.textAlignment = NSTextAlignmentCenter;
    _hudCurrentProgess.text = @"0%";
    [_hudProgess.customView addSubview:_hudCurrentProgess];
    _hudProgess.customView.backgroundColor = [UIColor clearColor];
    //zhiqiang--todo:  _hudProgess.delegate = self;
    _hudProgess.mode = MBProgressHUDModeCustomView;
    [_hudProgess show:YES];
}

-(void) proto_synProgress:(float)fPercent
{
    NSLog(@"other thread fPercent=%f\n", fPercent);
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_hudProgess!=nil)
        {
            NSLog(@"main thread fPercent=%f\n", fPercent);
            //_hudProgess.progress = fPercent;
            int nPercent = fPercent*100;
            _hudCurrentProgess.text = [NSString stringWithFormat:@"%d%%", nPercent];
        }
    });
   
}
-(void) proto_synSuccess:(SYN_MESSAGE_ID)synMessageID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self closeAllSound];
        _firTag = -1;
        _secTag = -1;
        switch (synMessageID) {
            case SYN_MSG_PREVIEW:
                [self isHidePlayBtn:NO];
                break;
            case SYN_MSG_SAVE:
            {
                if(_hudProgess!=nil)
                {
                    [_hudProgess hide:YES afterDelay:1.0];
                    _hudProgess = nil;
                }
                if(_saveTag == 999)
                {
                    //保存按钮
                    [self saveCurrentVideo:[Common getSysVideoPath:_currentTime]];
                }
                else
                {
                    //点击确定
                    _render->Exit();
                    [[PluginInterfaceInfo instance]output];//将信息保存起来
                    NSLog(@"%p", self.navigationController);
                    [self.navigationController popViewControllerAnimated:YES];
                }
                [self closeRender];
            }
            default:
                break;
        }
    });
}

-(void) proto_synFailure:(const char*)errorReason
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_hudProgess!=nil)
        {
            [_hudProgess hide:YES afterDelay:1.0];
            _hudProgess = nil;
        }
    });
}

-(void) proto_synPause
{
    dispatch_semaphore_signal(_enterBackground);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return  YES;
}

-(void) switchVideoResult
{
    if (_hudSwitchVideo != nil) {
        _hudSwitchVideo = nil;
    }
    _hudSwitchVideo = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hudSwitchVideo];
    _hudSwitchVideo.customView = [[UIView alloc] initWithFrame:CGRectMake(160, self.view.frame.size.height -180, 60, 60)];
    _hudSwitchImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    _hudSwitchImage.backgroundColor = [UIColor clearColor];
    _hudSwitchImage.animationImages = [NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"loading_1.png"],
                                       [UIImage imageNamed:@"loading_2.png"],
                                       [UIImage imageNamed:@"loading_3.png"],
                                       [UIImage imageNamed:@"loading_4.png"],
                                       [UIImage imageNamed:@"loading_5.png"],
                                       [UIImage imageNamed:@"loading_6.png"],
                                       [UIImage imageNamed:@"loading_7.png"],
                                       [UIImage imageNamed:@"loading_8.png"],
                                       [UIImage imageNamed:@"loading_9.png"],
                                       [UIImage imageNamed:@"loading_10.png"],
                                       [UIImage imageNamed:@"loading_11.png"],
                                       [UIImage imageNamed:@"loading_12.png"],
                                       nil];
    _hudSwitchImage.animationDuration = 0.5;
    _hudSwitchImage.animationRepeatCount = 0;
    [_hudSwitchImage startAnimating];
    [_hudSwitchVideo.customView addSubview:_hudSwitchImage];
    _hudSwitchVideo.mode = MBProgressHUDModeCustomView;
    [_hudSwitchVideo show:YES];
    
    NSLog(@"enter _hudSwitchVideo = %p, self=%p", _hudSwitchVideo, self);
}

-(void)removeProgressDialog
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_hudSwitchVideo)
        {
            [_hudSwitchVideo hide:YES];
            [_hudSwitchVideo removeFromSuperview];
        }
    });
}
#pragma mark - 切换到feinnoVideo页面以后检查下状态
-(void) checkVideoState
{
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    if (state.subTag != 0) {
    _secButtonStatus.selectedSubjectTag = state.subTag;
    }
    if (state.filterTag != 0) {
    _secButtonStatus.selectedFilterTag = state.filterTag;
    }
    if (state.bgmusicTag != 0) {
    _secButtonStatus.selectedMusicTag = state.bgmusicTag;
    }
}
#pragma mark - 消除视频原音
-(void) setPlayerSound :(id)sender
{
    if (_bEnableSrcSound == YES) {
        NSLog(@"原音关闭");
        [_soundBtn setImage:[UIImage imageNamed:@"消除原音_selected.png"] forState:UIControlStateNormal];
        [self showHudSoundseach:[NSString stringWithFormat:@"原音关闭"]];
        _playerView.player.volume = 0;
        // [_playerView stopPlay];
        _bEnableSrcSound = NO;
    }else{
        NSLog(@"原音开启");
        [_soundBtn setImage:[UIImage imageNamed:@"消除原音_unselected.png"] forState:UIControlStateNormal];
        [self showHudSoundseach:[NSString stringWithFormat:@"原音关闭"]];
        // [_playerView startPlay];
        _playerView.player.volume = 1;
        _bEnableSrcSound = YES;
    }
}
-(void) showHudSoundseach :(NSString *)title
{
    if(_hudSoundseach!=nil)
    {
        _hudSoundseach = nil;
    }
    _hudSoundseach = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:_hudProgess];
    _hudSoundseach.customView = [[UIView alloc] initWithFrame:CGRectMake(120, self.view.frame.size.height -180, 60, 30)];
    _soundShow = [[UILabel alloc] initWithFrame:CGRectMake(-10, 0, 80, 30)];
    _soundShow.backgroundColor = [UIColor clearColor];
    _soundShow.textColor = [UIColor whiteColor];
    _soundShow.textAlignment = NSTextAlignmentCenter;
    _soundShow.text = title;
    [_hudSoundseach.customView addSubview:_hudCurrentProgess];
    _hudSoundseach.customView.backgroundColor = [UIColor clearColor];
    //zhiqiang--todo:  _hudProgess.delegate = self;
    _hudSoundseach.mode = MBProgressHUDModeCustomView;
    [_hudSoundseach show:YES];
    [_hudSoundseach hide:YES afterDelay:1.0];
}
#pragma mark - 检查二级菜单的状态
-(void) getBackToCurrent:(int)tag
{
    assert(tag>0);
    MenuButton *btn = [_firButton objectAtIndex:(tag -1)];
    NSLog(@"%d",btn.tag);
    if (btn.tag == 1) {
        //        [self isshowSliderView:NO];
        //        [self isshowSlider:NO];
        FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
        state.fVideoTag = btn.tag;
        btn.selected = YES;
        _firTag = btn.tag;
        btn.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:1.0];
        [btn.titleView setTextColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1]];
        btn.imageView.image = [UIImage imageNamed:@"主题_selected.png"];
        //btn.backgroundColor = [UIColor colorWithRed:30.0/255 green:30.0/255 blue:30.0/255 alpha:1];
        //NSArray *titleArr = [NSArray arrayWithObjects:@"无滤镜",@"梦境",@"花语",@"大话王",@"静止",@"片头",@"音乐达人",@"胶片",@"老相框",nil];
        NSArray *titleArr = [NSArray arrayWithObjects:@"无主题",@"梦境",@"飘雪",@"阳光",@"音乐达人",@"怀旧",@"老电影",@"雨",nil];
        int tag = btn.tag *100;
        [Common MoveView:_secMenuView To:CGRectMake(_secMenuView.frame.origin.x, _secMenuView.frame.origin.y +((self.view.frame.size.height -_menuView.frame.size.height -_navBar.frame.size.height - 320 -71)/2) +_menuView.frame.size.height, _secMenuView.frame.size.width,_secMenuView.frame.size.height) During:0.5];
        [_secBottomButton removeAllObjects];
        _videoMenu.firMenuButtonTag = btn.tag;
         [self createSecendMenuBottomViewArr:titleArr
                           secondTopViewArr:nil
                           secMenuButtonTag:tag
                              secMenuTopTag:0
                             secBottomLabel:nil
                                secTopLabel:nil
                         menuBottomImageArr:_subjectImageArr];
         //*/
        if (_device == YES){
            [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_menu.frame.size.height -_secMenuView.frame.size.height -16, self.view.frame.size.width, _secMenuView.frame.size.height) During:0.5];
        }else{
            [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_menu.frame.size.height -71 -((self.view.frame.size.height -_menu.frame.size.height -_navBar.frame.size.height - 320 -71)/2), self.view.frame.size.width, 71) During:0.5];
        }
        NSLog(@"%f",((self.view.frame.size.height -_menu.frame.size.height -_navBar.frame.size.height - self.playerView.frame.size.height -71)/2));
    }else if (btn.tag == 2){
        FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
        state.fVideoTag = btn.tag;
        btn.selected = YES;
        _firTag = btn.tag;
        btn.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:1.0];
        [btn.titleView setTextColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1]];
        btn.imageView.image = [UIImage imageNamed:@"滤镜_selected.png"];
        // NSArray *titleArr = [NSArray arrayWithObjects:@"默认",@"曝光",@"马赛克",@"饱和",@"边缘",@"黑白",@"业余",@"怀旧",@"蓝调",@"美白",@"聚焦",@"浮雕",@"色相", nil];
        NSArray *titleArr = [NSArray arrayWithObjects:@"无滤镜", @"淡雅", @"重彩", @"美白", @"聚焦", @"黑白", @"浮雕", @"描边", @"漫画", @"油画", nil];
        int tag = btn.tag *100;
        [Common MoveView:_secMenuView To:CGRectMake(_secMenuView.frame.origin.x, _secMenuView.frame.origin.y +((self.view.frame.size.height -_menu.frame.size.height -_navBar.frame.size.height - 320 -71)/2) +_menu.frame.size.height, _secMenuView.frame.size.width,_secMenuView.frame.size.height) During:0.5];
        [_secBottomButton removeAllObjects];
        _videoMenu.firMenuButtonTag = btn.tag;
        [self createSecendMenuBottomViewArr:titleArr
                           secondTopViewArr:nil
                           secMenuButtonTag:tag
                              secMenuTopTag:0
                             secBottomLabel:nil
                                secTopLabel:nil
                         menuBottomImageArr:_filterImageArr];
        if (_device == YES) {
            [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_menu.frame.size.height -_secMenuView.frame.size.height -16, self.view.frame.size.width, _secMenuView.frame.size.height) During:0.5];
        }else{
            [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_menu.frame.size.height -71 -((self.view.frame.size.height -_menu.frame.size.height -_navBar.frame.size.height - 320 -71)/2), self.view.frame.size.width, 71) During:0.5];
        }
        NSLog(@"%f",((self.view.frame.size.height -_menuView.frame.size.height -_navBar.frame.size.height - self.playerView.frame.size.height -71)/2));
    }else if (btn.tag == 3){
        //        [self isshowSliderView:NO];
        //        [self isshowSlider:NO];
        //        [self soundBtnHidden:NO];
        FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
        state.fVideoTag = btn.tag;
        btn.selected = YES;
        _firTag = btn.tag;
        btn.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:1.0];
        [btn.titleView setTextColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1]];
        btn.imageView.image = [UIImage imageNamed:@"配乐_selected.png"];
        NSArray *titleArr = [NSArray arrayWithObjects:@"无配乐",@"中国风",@"乡村风",@"动感",@"壮阔自然",@"快乐颂",@"时尚科技",@"浪漫",@"爱情恋曲",@"轻松诙谐", nil];
        int tag = btn.tag *100;
        [Common MoveView:_secMenuView To:CGRectMake(_secMenuView.frame.origin.x, _secMenuView.frame.origin.y +((self.view.frame.size.height -_menuView.frame.size.height -_navBar.frame.size.height - 320 -71)/2) +_menuView.frame.size.height, _secMenuView.frame.size.width,_secMenuView.frame.size.height) During:0.5];
        [_secBottomButton removeAllObjects];
        _videoMenu.firMenuButtonTag = btn.tag;
        [self createSecendMenuBottomViewArr:titleArr
                           secondTopViewArr:nil
                           secMenuButtonTag:tag
                              secMenuTopTag:0
                             secBottomLabel:nil
                                secTopLabel:nil
                         menuBottomImageArr:_musicImageArr];
        if (_device == YES) {
            [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_menu.frame.size.height -_secMenuView.frame.size.height -16, self.view.frame.size.width, _secMenuView.frame.size.height) During:0.5];
        }else{
            [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_menu.frame.size.height -71 -((self.view.frame.size.height -_menu.frame.size.height -_navBar.frame.size.height - 320 -71)/2), self.view.frame.size.width, 71) During:0.5];
        }
    }
}
                                
-(NSString* ) _getMatchFileInfo:(SYN_ELEMENT)synEle withTagID:(int)nTagID withReturnFileID:(int*)nRetFileID
{
    assert(synEle==SYN_THEME || synEle==SYN_FILTER || synEle==SYN_BGMUSIC);
    int fileID = -1;
    NSString* musicFileName = nil;
    switch (synEle)
    {
        case SYN_THEME:
        {
            switch (nTagID) {
                case 100:
                    NSLog(@"无滤镜－－默认");
                    musicFileName = nil;
                    fileID = 0;
                    break;
                case 101:
                    fileID = 1;
                    musicFileName = @"dream.mp4";
                    NSLog(@"梦境");
                    break;
                case 102:
                    musicFileName = @"static.mp4";
                    fileID = 3;
                    NSLog(@"飘雪");
                    break;
                case 103:
                    fileID = 2;
                    musicFileName = @"sun.mp4";
                    NSLog(@"阳光");
                    break;
                case 104:
                    fileID = 5;
                    musicFileName = @"music-master.mp4";
                    NSLog(@"音乐达人");
                    break;
                case 105:
                    fileID = 8;
                    musicFileName = @"vintage.mp4";
                    NSLog(@"怀旧");
                    break;
                case 106:
                    fileID = 9;
                    musicFileName = @"old-movie.mp4";
                    NSLog(@"老电影");
                    break;
                case 107:
                    fileID = 10;
                    musicFileName = @"rain.mp4";
                    NSLog(@"雨");
                    break;
                default:
                {
                    assert(false);
                }
                    break;
            }
        }
            break;
        case SYN_FILTER:
        {
            switch (nTagID)
            {
                case 200:
                    NSLog(@"无滤镜－－默认");
                    fileID = 0;
                    break;
                case 201:
                    fileID = 3;
                    NSLog(@"淡雅");
                    break;
                case 202:
                    fileID = 11;
                    NSLog(@"重彩");
                    break;
                case 203:
                    fileID = 6;
                    NSLog(@"美白");
                    break;
                case 204:
                    fileID = 7;
                    NSLog(@"聚焦");
                    break;
                case 205:
                    fileID = 2;
                    NSLog(@"黑白");
                    break;
                case 206:
                    fileID = 8;
                    NSLog(@"浮雕");
                    break;
                case 207:
                    fileID = 12;
                    NSLog(@"描边");
                    break;
                case 208:
                    fileID = 1;
                    NSLog(@"漫画");
                    break;
                case 209:
                    fileID = 4;
                    NSLog(@"移焦");
                    break;
                default:
                {
                    assert(false);
                }
                    break;
            }
        }//end filter
            break;
        case SYN_BGMUSIC:
        {
            // @"无配乐",@"中国风",@"乡村风",@"动感",@"壮阔自然",@"快乐颂",@"时尚科技",@"浪漫",@"爱情恋曲",@"轻松诙谐",
            switch (nTagID) {
                case 300:
                    musicFileName = nil;
                    fileID = 0;
                    break;
                case 301:
                    musicFileName = @"a.mp3";
                    fileID = 1;
                    break;
                case 302:
                    musicFileName = @"b.mp3";
                    fileID = 2;
                    break;
                case 303:
                    musicFileName = @"c.mp3";
                    fileID = 3;
                    break;
                case 304:
                    musicFileName = @"d.mp3";
                    fileID = 4;
                    break;
                case 305:
                    musicFileName = @"e.mp3";
                    fileID = 5;
                    break;
                case 306:
                    musicFileName = @"f.mp3";
                    fileID = 6;
                    break;
                case 307:
                    musicFileName = @"g.mp3";
                    fileID = 7;
                    break;
                case 308:
                    fileID = 8;
                    musicFileName = @"h.mp3";
                  break;
                case 309:
                    musicFileName = @"i.mp3";
                    fileID = 9;
                    break;
                default:
                {
                    assert(false);
                }
                    break;
            }
        }//end bgmusic
            break;
        default:
            break;
    }//end switch
    
    NSString* retResPath = nil;
    NSString* nsResFolderPath = [Common getSynElementFolderPath:synEle withEleID:fileID];
    std::string synResFolderPath = std::string([nsResFolderPath UTF8String]);
    SynthesisParamterInstance& instance =  SynthesisParamterInstance::instance();
    retResPath = musicFileName==nil? nil : [nsResFolderPath stringByAppendingString:[NSString stringWithFormat:@"/%@", musicFileName]];
    
    std::string empty("");
    switch (synEle) {
        case SYN_THEME:
        {
            if(fileID!=0)
            {
                instance.setThemeVideoPath(synResFolderPath);
            }
            else
            {
                instance.setThemeVideoPath(empty);
            }
        }
            break;
        case SYN_FILTER:
        {
            if(fileID!=0)
            {
                instance.setFilterVideoPath(synResFolderPath);
            }
            else
            {
                instance.setFilterVideoPath(empty);
            }
        }
            break;
        case SYN_BGMUSIC:
        {
            if(fileID!=0)
            {
                std::string musicResPath = std::string([retResPath UTF8String]);
                instance.setBgMusicPath(musicResPath);
            }
            else
            {
                instance.setBgMusicPath(empty);
            }
        }
            break;
    }//end switch
    return retResPath;
}

//#pragma mark - 读取数据
//-(void) readData
//{
//    NSArray *arr = [NSArray arrayWithObjects:@"subTag",@"filterTag",@"bgMusicTag",@"borderTag",@"cartoonTag",@"cartoonX",@"cartoonY",@"cartoonW",@"cartoonH",@"cartRotate",@"subtitleStartTime",@"subtitleStopTime",@"recordStartTime",@"recordLength",@"titleBubbleTag",@"titleFontTag",@"titleShade",@"titleBold",@"titleColorSliderX",@"titleColorSliderY",@"titleBubbleX",@"titleBubbleY",@"titleBubbleW",@"titleBubbleH",@"titleTextX",@"titleTextY",@"titleTextW",@"titleTextH",@"titleText",@"titleRotate", nil];
//    NSDictionary *dic = [Common getEditPropertiesInfo];
//    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
//    for (int i = 0; i< arr.count; i++) {
//        state.
//    }
//}
#pragma mark - 创建xml并保存数据
/*-(void) saveXMLData
 {
 NSString *path = [NSString stringWithFormat:@"%@/state.xml",[Common getDocumentDirectory]];
 //    NSLog(@"%@",path);
 NSDictionary *dic = [Common getEditPropertiesInfo];
 NSLog(@"%@",dic);
 NSArray *arr = [NSArray arrayWithObjects:@"subTag",@"filterTag",@"bgMusicTag",@"borderTag",@"cartoonTag",@"cartoonX",@"cartoonY",@"cartoonW",@"cartoonH",@"cartRotate",@"subtitleStartTime",@"subtitleStopTime",@"recordStartTime",@"recordLength",@"titleBubbleTag",@"titleFontTag",@"titleShade",@"titleBold",@"titleColorSliderX",@"titleColorSliderY",@"titleBubbleX",@"titleBubbleY",@"titleBubbleW",@"titleBubbleH",@"titleTextX",@"titleTextY",@"titleTextW",@"titleTextH",@"titleText",@"titleRotate", nil];
 // 创建标签元素
 GDataXMLElement *element = [GDataXMLNode elementWithName:@"videoName" stringValue:@""];
 // 创建状态属性
 for (int i = 0; i < arr.count; i++) {
 NSString *str = [NSString stringWithFormat:@"%@",[arr objectAtIndex:i]];
 NSLog(@"%@",str);
 NSLog(@"%@",[dic objectForKey:str]);
 GDataXMLElement *ele = [GDataXMLNode attributeWithName:[arr objectAtIndex:i] stringValue:[dic objectForKey:str]];
 [element addAttribute:ele];
 }
 // 创建根标签
 GDataXMLElement *rootElement = [GDataXMLNode elementWithName:@"state"];
 // 把标签与属性添加到根标签中
 
 [rootElement addChild:element];
 // 生成xml文件内容
 GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithRootElement:rootElement];
 NSData *data = [xmlDoc XMLData];
 NSString *xmlString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 NSLog(@"%@", xmlString);
 [data writeToFile:path atomically:YES];
 }*/
#pragma mark - 保存视频到相册
//
-(void) saveVideo:(id) sender
{
    UIButton *btn = (UIButton *)sender;
    _saveTag = (int)btn.tag;
    NSLog(@"%d",_saveTag);
    [self closeAllSound];
    _currentTime = [self generateLocalSavePath];
    SynthesisParamterInstance& instance = SynthesisParamterInstance::instance();
    std::string strPhotoAlbumTempPath = std::string([[NSString stringWithFormat:@"%@.mp4",[Common createSysVideoPath:_currentTime]] UTF8String]);
    instance.setPhotoAlbumTempPath(strPhotoAlbumTempPath);
    [self pushSynthesisMsg:SYN_MSG_SAVE];
    [self proto_createSynthesisProgressDialog];
//    std::string strCurrentPhotoAlbumTempPath = std::string(NULL);
//    instance.setPhotoAlbumTempPath(strCurrentPhotoAlbumTempPath);
    //[[NSFileManager defaultManager] removeItemAtPath:[Common getSysVideoPath:currentTime] error:nil];
//    /var/mobile/Applications/16481659-725F-427C-8514-54F76626D7A8/Documents/VID_20140630_183434
    
//    NSLog(@"%@",[NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%@/VID_20140630_183434.mp4",[Common getDocumentDirectory]]]);
}
// 获取当前时间
-(NSString*)generateLocalSavePath
{
    NSDate *date=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd-HH:mm"];
    NSString *locationString=[dateformatter stringFromDate:date];
    NSLog(@"%@",locationString);
    return locationString;
}
// 保存到相册
-(void)saveCurrentVideo:(NSString*)urlString
{
    UISaveVideoAtPathToSavedPhotosAlbum(urlString, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    NSLog(@"urlString:%@",urlString);
//    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:urlString]
//                                completionBlock:^(NSURL *assetURL, NSError *error) {
//                                    if (error) {
//                                        NSLog(@"Save video fail:%@",error);
//                                    } else {
//                                        NSLog(@"Save video succeed.");
//                                    }
//                                }];
}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo
{
    
    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",[Common getDocumentDirectory],_currentTime] error:nil];
    _currentTime = nil;
    NSLog(@"%@",videoPath);
    
    NSLog(@"%@",error);
    
}
@end
