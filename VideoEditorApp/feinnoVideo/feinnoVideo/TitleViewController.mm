//
//  TitleViewController.m
//  libFeinnoVideo
//
//  Created by coCo on 14-9-4.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "TitleViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "playerView.h"
#import "AddTitleViewController.h"
#import "NavigationBar.h"
#import "MenuButton.h"
#import "base/FeinnoVideoState.h"
#import "base/SynthesisParameterInfo.h"
#import "SynthesisParamterInstance.h"

@interface TitleViewController ()
{
    NavigationBar *_navBar;
    UIView *_titleView;
    MenuButton *_titleBtn;
    UIButton *_playBtn;
    int _flag;
    UIImageView *_firImageView;
}
@end

@implementation TitleViewController


- (id)init
{
    self = [super init];
    if (self) {
        _vcID = VC_SUBTITLE;
    }
    return self;
}
//-(void)viewWillAppear:(BOOL)animated
//{
//
//    [super viewWillAppear:animated];
//    [self setNeedsStatusBarAppearanceUpdate];
//    [self.navigationController setNavigationBarHidden:YES animated:YES]; // 隐藏导航栏
//}
- (void)viewDidLoad
{
    _flag = 0;
    [super viewDidLoad];
    [self checkStatusHidden];
    [self isshowSlider:YES];
    [self isshowRecorderView:YES];
    [self playerSliderLabelHidden:YES];
    //[self checkPlayerViewHidden:YES];
    [self layout];
    self.view.backgroundColor = [UIColor blackColor];
}

-(void) layout
{
#pragma mark - 导航栏
//    _navBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 51) titleText:@"字幕" leftButtonTarget:self leftButtonAction:@selector(clickBackButton) leftButtonImage:[UIImage imageNamed:@"顶部导航栏_返回normal.png"] leftSelectedButtonImage:[UIImage imageNamed:@"顶部导航栏_返回down.png"] rightButtonTarget:self rightButtonAction:@selector(clickSureButton) rightButtonImage:[UIImage imageNamed:@"顶部导航栏_确定normal.png"] rightSelectedButtonImage:[UIImage imageNamed:@"顶部导航栏_确定down.png"]];
//    [self.view addSubview:_navBar];
#pragma mark - 视频播放控件
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"movie" ofType:@".mp4"];
//    _titlePlayView = [[PlayView alloc] initWithPlayViewFrame:CGRectMake(0, 0, 320, 300) playAddress:path showProgressLabel:YES showPlayBtn:NO showProSlider:YES showProgress:YES showOriginnalSoundBtn:NO target:self];
//    [self.view addSubview:_titlePlayView];
#pragma mark - 菜单控件
    //菜单栏
    _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -109, self.view.frame.size.width, 109)];
    _titleView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_titleView];
    //添加字体button
    //    _titleBtn = [[MenuButton alloc] initWithButtonFrame:CGRectMake(_titleView.frame.size.width/2 -90, _titleView.frame.size.height/2 -27, 180, 54) buttonImageFrame:CGRectMake(25, 12, 27, 27) buttonTitleFrame:CGRectMake(67, 25/2 +15-9, 80, 18) buttonImage:[UIImage imageNamed:@"配音_normal.png"] buttonTitle:@"添加字幕" buttonTag:99 buttonSelected:NO buttonBackgroundImage:nil clickButtonTarget:self clickButtonTarget:@selector(cheakToAddTitle) buttonCornerRadius:27.0];
    _titleBtn = [[MenuButton alloc] initWithButtonFrame:CGRectMake(_titleView.frame.size.width/2 -90, _titleView.frame.size.height/2 -27, 183, 47) buttonImageFrame:CGRectMake(10, 47/2 -31/2, 31, 31) buttonTitleFrame:CGRectMake((183 -22 -31)/2 , 47/2 -18/2, 80, 18) buttonImage:[UIImage imageNamed:@"添加字幕按钮_图标_normal.png"] buttonTitle:@"添加字幕" titleFont:18 buttonTag:99 buttonSelected:NO buttonBackgroundImage:nil clickButtonTarget:self clickButtonTarget:@selector(cheakToAddTitle) buttonCornerRadius:47/2 device:nil];
    [_titleView addSubview:_titleBtn];
    
    [self.view bringSubviewToFront:_navBar];
}
// 添加字幕按钮响应事件
-(void) cheakToAddTitle
{
    AddTitleViewController *addtitle = [[AddTitleViewController alloc] init];
    //addtitle.srcVideoPath = self.srcVideoPath;//NODE: 需要调整
    [self.navigationController pushViewController:addtitle animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}
//返回按钮响应事件
-(void) clickBackButton
{
    UIAlertView *cancelAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"真的要放弃本次修改？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
    cancelAlert.tag = 1;
    [cancelAlert addButtonWithTitle:@"确定"];
    [cancelAlert show];

}
//导航栏右侧确定按钮响应事件
-(void) clickSureButton
{
    UIAlertView *sureAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定后没法修改了" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
    sureAlert.tag = 2;
    [sureAlert addButtonWithTitle:@"确定"];
    [sureAlert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        NSLog(@"clickButtonAtIndex:%d",buttonIndex);
        if (buttonIndex == 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (alertView.tag ==2){
        if (buttonIndex == 2) {
            NSLog(@"完成所有编辑");
//            SynthesisParamterInstance& synParaInstance = SynthesisParamterInstance::instance();
//            synParaInstance.setSubtitleStartTime([Common getTitleStartTimeInMillSec]);
//            synParaInstance.setSubtitileEndTime([Common getTitleStopTimeInMillSec]);
//            std::string subTitleImagePath = std::string([[Common getSubtitleImagePath] UTF8String]);
//            synParaInstance.setSubtitileImgPath(subTitleImagePath);
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_EDITED" object:self];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
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

@end
