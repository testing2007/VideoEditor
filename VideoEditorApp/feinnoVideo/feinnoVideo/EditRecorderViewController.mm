//
//  EditRecorderViewController.m
//  FVideo
//
//  Created by coCo on 14-8-20.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import "EditRecorderViewController.h"
#import "NavigationBar.h"
#import "MenuButton.h"

@interface EditRecorderViewController (){

    NavigationBar *_navBar;
    UIScrollView *_scroll;
    UIView *_menuView;
    NSArray *_menuTitleArr;
    NSArray *_menuImageArr;
    NSMutableArray *_menuButton;
}

//@property (nonatomic ,retain) NavigationBar *navBar;
//@property (nonatomic ,retain) UIScrollView *scroll;
//@property (nonatomic ,retain) UIView *menuView;
//@property (nonatomic ,retain) NSArray *menuTitleArr;
//@property (nonatomic ,retain) NSArray *menuImageArr;
//@property (nonatomic ,retain) NSMutableArray *menuButton;

@end

@implementation EditRecorderViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _vcID = VC_EDIT_RECORD;
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
    _menuTitleArr = [NSArray arrayWithObjects:@"原音",@"一休",@"小丸子",@"美少女",@"蜡笔小新",@"奥特曼",@"打怪兽", nil];
    _menuImageArr = [NSArray arrayWithObjects:@"原音", nil];
    _menuButton = [[NSMutableArray alloc] init];
    [self layout];
}
-(void) layout
{
#pragma mark - 导航栏
//    _navBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 51) titleText:@"预览" leftButtonTarget:self leftButtonAction:@selector(clickBackButton) leftButtonImage:[UIImage imageNamed:@"上一步_normal.png"] leftSelectedButtonImage:[UIImage imageNamed:@"上一步_down.png"] rightButtonTarget:self rightButtonAction:@selector(clickSureButton) rightButtonImage:nil rightSelectedButtonImage:nil];
//    [self.view addSubview:_navBar];
#pragma mark - 视频播放器
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"movie" ofType:@".mp4"];
//    _videoPlayer = [[PlayView alloc] initWithPlayViewFrame:CGRectMake(0, 0, 320, 320) playAddress:path showProgressLabel:YES showPlayBtn:YES showProSlider:YES showProgress:YES showOriginnalSoundBtn:YES target:self];
//    _videoPlayer.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:_videoPlayer];
#pragma mark - 菜单布局
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _menuTitleArr.count *(19 +52) +19, 109)];
    _menuView.backgroundColor = [UIColor colorWithRed:14.0/255 green:14.0/255 blue:14.0/255 alpha:1.0];
    
    _scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 109, self.view.frame.size.width, 109)];
    _scroll.backgroundColor = [UIColor redColor];
    _scroll.showsHorizontalScrollIndicator = YES;
    _scroll.contentSize = _menuView.frame.size;
    _scroll.bounces = NO;
    [self creatMenuButton];
    [_scroll addSubview:_menuView];
    [self.view addSubview:_scroll];
    
    [self.view bringSubviewToFront:_navBar];
}
#pragma mark - 创建button
-(void) creatMenuButton
{
    for (int i = 0; i<_menuTitleArr.count; i++) {
        MenuButton *btn = [[MenuButton alloc] initWithButtonFrame:CGRectMake(19 +(52 +19)*i, _menuView.frame.origin.y+30, 52, 52) buttonImageFrame:CGRectMake(1, 1, 50, 50) buttonTitleFrame:CGRectMake(1, 37, 50, 15) buttonImage:[UIImage imageNamed:@"无滤镜"] buttonTitle:[_menuTitleArr objectAtIndex:i] titleFont:11 buttonTag:i buttonSelected:YES buttonBackgroundImage:[UIImage imageNamed:@"滤镜_缩略图选中框黑色.png"] clickButtonTarget:self clickButtonTarget:@selector(buttonAction:)buttonCornerRadius:3.0 device:NO];
        NSLog(@"%f",btn.frame.origin.y);
        if (btn.tag == 0) {
            btn.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框.png"];
        }
        [_menuView addSubview:btn];
        [_menuButton addObject:btn];
    }
}

-(void) buttonAction:(id)sender
{
    MenuButton *btn = (MenuButton *)[sender view];
    for (MenuButton *allButton in _menuButton) {
        allButton.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框黑色"];
    }
    btn.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框.png"];
    switch (btn.tag) {
        case 0:
            NSLog(@"我是删除");
            break;
        case 1:
            break;
        default:
            break;
    }
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

-(void) clickBackButton
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_EDITED" object:self];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) clickSureButton
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
