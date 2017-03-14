//
//  DecorateViewController.m
//  FVideo
//
//  Created by coCo on 14-8-6.
//  Copyright (c) 2014年 coCo. All rights reserved.
//

#import "DecorateViewController.h"
#import "Menu.h"
#import "TextStatus.h"
#import "MenuButton.h"
#import "NavigationBar.h"
#import "SecButtonStatus.h"
#import "base/CatchImage.h"
#import "PanImageView/ZDStickerView.h"
#import "PluginInterfaceInfo.h"
#import "base/Common.h"
#import "base/FeinnoVideoState.h"
#import "base/SynthesisParameterInfo.h"
#import "SynthesisParamterInstance.h"
#import "FVideoViewController.h"
#import "SSImageView.h"
#import "SSEditView.h"


@interface DecorateViewController ()
{
    NavigationBar *_navBar;                  //导航栏
    UIImageView *_DecorateView;
    UIView *_firMenuView;                   //一级菜单
    UIScrollView *_firScrollView;           //一级菜单的滚动视图
    UIView *_secMenuView;                   //二级菜单
    Menu *_menu;
    NSMutableArray *_firButton;             //一级菜单的的buttonArr
    NSArray *_firButtonImage;               //一级菜单的button
    NSMutableArray *_secBottomButton;       //二级菜单中下层菜单Arr,若只有二级菜单的下层菜单则为下层菜单的Arr
    NSMutableArray *_secTopButton;          //二级菜单中上层菜单Arr,若只有一级菜带则为空
    UIImageView *_selectView;               //选中button的标示
    TextStatus *_currentlyStatus;           //当前状态
    SecButtonStatus *_secButtonStatus;      //二级button选中状态标示
    SSImageView *_borderView;                //边框图片
    SSImageView *_cartView;                  //动画图片
    ZDStickerView *_cartImageView;
    UIImageView *_compileView;               //进行编辑的View
    UIImage *_cutOutImage;                  //截取到的图片
    
    NSMutableArray *_cartoonImageArr;
    NSMutableArray *_frameImageArr;
    NSMutableArray *_cartArr;
    NSMutableArray *_frameArr;
    BOOL _device;
}
@end

@implementation DecorateViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _vcID = VC_DECORATE;
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"decorate view controller is called");
}

-(void)viewWillAppear:(BOOL)animated
{
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    if (state.decorateTag != 0) {
        [self getBackToLastCurrent:state.decorateTag];
    }else{
        [self getBackToLastCurrent:1];
    }
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
    [self.navigationController setNavigationBarHidden:YES animated:YES]; // 隐藏导航栏
    //    _firButton
    //[self createSecView:[_firButton objectAtIndex:1]];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
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
                                           rightBtnTag:0];
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
                                           rightBtnTag:0];
    }
    [self.view addSubview:_navBar];
    [self mediaTimeShow:YES];
    _firButton = [[NSMutableArray alloc] init];
    _firButtonImage = [[NSArray alloc] initWithObjects:@"装饰_边框_normal.png",@"装饰_卡通_normal.png", nil];
    _secBottomButton = [[NSMutableArray alloc] init];
    _secTopButton = [[NSMutableArray alloc] init];
    _currentlyStatus = [[TextStatus alloc] init];
    _currentlyStatus.boldfaced = NO;
    _currentlyStatus.shadow = NO;
    NSMutableArray* arrFrameID = [NSMutableArray arrayWithObjects: @"1",@"2", @"3", @"4", @"5", @"6", @"7",nil];
    _frameImageArr = [[NSMutableArray alloc]init];
    _frameArr = [[NSMutableArray alloc] init];
    int indexID = -1;
    NSString* folderID = nil;
    NSString* path = nil;
    NSString* bPath = nil;
    for(NSInteger i=0; i<[arrFrameID count]; ++i)
    {
        indexID = [(NSString*)([arrFrameID objectAtIndex:i]) intValue];
        folderID = [Common getSynElementFolderPath:SYN_FRAME withEleID:indexID];
        path = [NSString stringWithFormat:@"%@/icon.png", folderID];
        bPath = [NSString stringWithFormat:@"%@/frame.png",folderID];
        [_frameArr addObject:bPath];
        [_frameImageArr addObject:path];
    }
    NSLog(@"%@",_frameImageArr);

    NSMutableArray* arrCartoonID = [NSMutableArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7",@"8",@"9",@"10",nil];
    _cartoonImageArr = [[NSMutableArray alloc]init];
    _cartArr = [[NSMutableArray alloc] init];
    for(NSInteger i=0; i<[arrCartoonID count]; ++i)
    {
        indexID = [(NSString*)([arrCartoonID objectAtIndex:i]) intValue];
        folderID = [Common getSynElementFolderPath:SYN_CARTOON withEleID:indexID];
        path = [NSString stringWithFormat:@"%@/icon.png", folderID];
        bPath = [NSString stringWithFormat:@"%@/cartoon.png",folderID];
        [_cartArr addObject:bPath];
        [_cartoonImageArr addObject:path];
    }
    NSLog(@"%@",_cartoonImageArr);

    _menu = [[Menu alloc] init];
    _secButtonStatus = [[SecButtonStatus alloc] init];
    [self isshowSliderView:YES];
    [self soundBtnHidden:YES];
    self.view.userInteractionEnabled = YES;
    [self layout];
    [self checkDecorateState];
}

-(void) loadView
{
    [super loadView];
}

-(void) layout
{
#pragma mark - 导航栏
    
#pragma mark - 截取到的图片-----------------------------------------------------------------------------------------------
    _compileView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    _compileView.backgroundColor = [UIColor clearColor];
    _compileView.userInteractionEnabled = YES;
    //zhiqiang-- [self.playerView addSubview:_compileView];
    [self.stageView addSubview:_compileView];
    
    _borderView = [[SSImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    _borderView.backgroundColor = [UIColor clearColor];
    _borderView.userInteractionEnabled = YES;
    [_compileView addSubview:_borderView];
    
    _cartView = [[SSImageView alloc] initWithFrame:CGRectMake(80, 150, 150, 150)];
    [_compileView addSubview:_cartView];
    
//    _cartImageView = [[ZDStickerView alloc] initWithFrame:_cartView.frame];
//    _cartImageView.userInteractionEnabled = YES;
//    _cartImageView.contentView = _cartView;
//    _cartImageView.preventsPositionOutsideSuperview = NO;
//    _cartImageView.resizingControl.hidden = YES;
//    [_compileView addSubview:_cartImageView];
    

#pragma mark - 菜单布局----------------------------------------------------------------------------------------------------
    if (_device == YES) {
        _firScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -54, self.view.frame.size.width, 54)];
    }else{
        _firScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -38, self.view.frame.size.width, 38)];
    }
    _firScrollView.backgroundColor = [UIColor clearColor];
    _firScrollView.showsHorizontalScrollIndicator = NO;
    _firScrollView.contentSize = _firMenuView.frame.size;
    _firScrollView.bounces = YES;
    
    NSArray *firMenuArr = [NSArray arrayWithObjects:@"边框",@"卡通", nil];
    _firMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _firScrollView.frame.size.height)];
    _firMenuView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:_firScrollView];
    [_firScrollView addSubview:_firMenuView];
    [self createMenuButtonArr:firMenuArr];
    //[self.view addSubview:_secMenuView];
    
    [self.view bringSubviewToFront:_navBar];
    [self.playerView bringSubviewToFront:self.playBtn];
    if (_device == YES) {
        [self mediaTimeShow:NO];
    }else{
        [self mediaTimeShow:YES];
    }
    NSLog(@"%f,%f,%f,%f",_cartImageView.frame.origin.x,_cartImageView.frame.origin.y,_cartImageView.frame.size.width,_cartImageView.frame.size.height);
}
#pragma mark - 创建按钮视图-----------------------------------------------------------------------------------------------
// 创建一级菜单的button
-(void) createMenuButtonArr:(NSArray *)array
{
    //float width = _firMenuView.frame.size.width / array.count;
    for (int i = 0; i < array.count; i++){
        MenuButton *btn = [[MenuButton alloc] initWithButtonFrame:CGRectMake(self.view.frame.size.width/2 *i, _firMenuView.frame.size.height -_firMenuView.frame.size.height,self.view.frame.size.width/2 , _firMenuView.frame.size.height) buttonImageFrame:CGRectMake(self.view.frame.size.width/2 -120, _firMenuView.frame.size.height/2 -10.5, 21, 21) buttonTitleFrame:CGRectMake(self.view.frame.size.width/2 -80, _firMenuView.frame.size.height/2 -10, 30, 21) buttonImage:[UIImage imageNamed:[_firButtonImage objectAtIndex:i]] buttonTitle:[array objectAtIndex:i] titleFont:13 buttonTag:i+1 buttonSelected:NO buttonBackgroundImage:nil clickButtonTarget:self clickButtonTarget:@selector(createSecView:) buttonCornerRadius:0 device:nil];
        NSLog(@"%f",btn.frame.origin.y);
        [_firButton addObject:btn];
        [_firMenuView addSubview:btn];
    }
}
-(void) createSecView:(id)sender
{
    MenuButton *btn = (MenuButton *)[sender view];
    [_secMenuView removeFromSuperview];
    for (MenuButton *allButton in _firButton) {
        allButton.selected = NO;
        allButton.titleView.textColor = [UIColor whiteColor];
        //NSLog(@"%d",allButton.tag);
        allButton.imageView.image = [UIImage imageNamed:[_firButtonImage objectAtIndex:allButton.tag -1]];
        allButton.backgroundColor = [UIColor colorWithRed:41.0/255.0 green:41.0/255.0 blue:41.0/255.0 alpha:1.0];
    }

    [self loadSecondMenuBtn:btn];
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    state.decorateTag = btn.tag;
}

-(void)loadSecondMenuBtn:(MenuButton*)btn
{
    //重新加载所需的控件
    if (btn.tag == 1) {
        FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
        state.decorateTag = btn.tag;
        btn.selected = YES;
        btn.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:1.0];
        [btn.titleView setTextColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1]];
        btn.imageView.image = [UIImage imageNamed:@"装饰_边框_down.png"];
        // NSArray *musicArr = [NSArray arrayWithObjects:@"默认",@"帽子",@"丝带",@"白云",@"汪星人",@"黑土", nil];
        NSArray *musicArr = [NSArray arrayWithObjects:@"无边框",@"蓝色枫叶",@"传情", @"橘色梦幻",@"粉色奥运",@"复古阿狸",@"酷炫红色", @"五彩世界", nil];
        int tag = btn.tag *100;
        _menu.firMenuButtonTag = 1;
        [Common MoveView:_secMenuView To:CGRectMake(_secMenuView.frame.origin.x, _secMenuView.frame.origin.y +((self.view.frame.size.height -_firMenuView.frame.size.height -_navBar.frame.size.height - self.playerView.frame.size.height -71)/2) +_firMenuView.frame.size.height, _secMenuView.frame.size.width,_secMenuView.frame.size.height) During:0.5];
        [_selectView removeFromSuperview];
        [_secBottomButton removeAllObjects];
        [self createSecendMenuBottomViewArr:musicArr
                           secondTopViewArr:nil
                           secMenuButtonTag:tag
                              secMenuTopTag:0
                             secBottomLabel:nil
                                secTopLabel:nil
                                secImageArr:_frameImageArr];
        [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_firMenuView.frame.size.height -71 -((self.view.frame.size.height -_firMenuView.frame.size.height -_navBar.frame.size.height - self.playerView.frame.size.height -71)/2) +5, self.view.frame.size.width, 71) During:0.5];
    }else if (btn.tag == 2){
        FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
        state.decorateTag = btn.tag;
        btn.selected = YES;
        btn.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:1.0];
        [btn.titleView setTextColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1]];
        btn.imageView.image = [UIImage imageNamed:@"装饰_卡通_down.png"];
        // NSArray *musicArr = [NSArray arrayWithObjects:@"默认",@"帽子",@"丝带",@"白云",@"汪星人",@"黑土", nil];
        NSArray *musicArr = [NSArray arrayWithObjects:@"无卡通", @"草莓帽子",@"欧巴眼镜",@"2小",@"锤子",@"loveyou",@"太阳",@"kiss",@"猫鱼",@"灰起来",@"兔子", nil];
        int tag = btn.tag *100;
        _menu.firMenuButtonTag = 2;
        [Common MoveView:_secMenuView To:CGRectMake(_secMenuView.frame.origin.x, _secMenuView.frame.origin.y +((self.view.frame.size.height -_firMenuView.frame.size.height -_navBar.frame.size.height - self.playerView.frame.size.height -71)/2) +_firMenuView.frame.size.height, _secMenuView.frame.size.width,_secMenuView.frame.size.height) During:1.0];
        [_selectView removeFromSuperview];
        [_secBottomButton removeAllObjects];
        [self createSecendMenuBottomViewArr:musicArr
                           secondTopViewArr:nil
                           secMenuButtonTag:tag
                              secMenuTopTag:0
                             secBottomLabel:nil
                                secTopLabel:nil
                                secImageArr:_cartoonImageArr];
        [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_firMenuView.frame.size.height -71 -((self.view.frame.size.height -_firMenuView.frame.size.height -_navBar.frame.size.height - self.playerView.frame.size.height -71)/2), self.view.frame.size.width, 71) During:0.5];
    }
}

//创建二级View
-(void) createSecendMenuBottomViewArr:(NSArray *)secBottomArr
                     secondTopViewArr:(NSArray *)secTopArr
                     secMenuButtonTag:(int)bottomButtonTag
                        secMenuTopTag:(int)topButtonTag
                       secBottomLabel:(NSString *)bottomButtonText
                          secTopLabel:(NSString *)topButtonText
                          secImageArr:(NSArray *)secImageArr
{
    
//    _secMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -_firMenuView.frame.size.height -71 -((self.view.frame.size.height -_firMenuView.frame.size.height -_navBar.frame.size.height - self.playerView.frame.size.height -71)/2), self.view.frame.size.width, 71)];
    //_secMenuView.backgroundColor = [UIColor redColor];
    if (_device == YES) {
        _secMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 87)];
    }else{
        _secMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -_firMenuView.frame.size.height, self.view.frame.size.width, 71)];
    }

    _secMenuView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_secMenuView];
    [self.view bringSubviewToFront:_firScrollView];

    
    if (secTopArr != nil) {
        //拥有两个二级菜单
        UIView *bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (60 +5) *secBottomArr.count +5, 60)];
        bottom.backgroundColor = [UIColor darkGrayColor];
        
        UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        bottomLabel.text = bottomButtonText;
        bottomLabel.textAlignment = NSTextAlignmentCenter;
        bottomLabel.backgroundColor = [UIColor darkGrayColor];
        [_secMenuView addSubview:bottomLabel];
        
        UIScrollView *bottomScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(60, 0, 260, 60)];
        bottomScroll.backgroundColor = [UIColor darkGrayColor];
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
                            secImageArr:nil];
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
//        _menu.bottomView = bottom;
//        _menu.bottomArr = secBottomArr;
        NSLog(@"%@",_menu.bottomView);
        NSLog(@"111%@",_menu.bottomArr);
        [self createMenuBottomButtonArr:secBottomArr
                       menuTopButtonArr:nil
                      secMenuBottomView:bottom
                         secMenuTopView:nil
                 secMenuButtonBottomTag:bottomButtonTag
                          secMenuTopTag:0
                            secImageArr:secImageArr];
    }
}

// 创建二级菜单的button
-(void) createMenuBottomButtonArr:(NSArray *)bottomArray
                 menuTopButtonArr:(NSArray *)topArray
                secMenuBottomView:(UIView *)bottomView
                   secMenuTopView:(UIView *)topView
           secMenuButtonBottomTag:(int)secBottomBtnTag
                    secMenuTopTag:(int)secTopBtnTag
                      secImageArr:(NSArray *)secImageArr
{
        if (topArray == nil) {
            //bottomView.backgroundColor = [UIColor colorWithRed:15.0/255 green:15.0/255 blue:15.0/255 alpha:1];
            //bottomView.backgroundColor  = [UIColor blackColor];
            for (int i = 0; i < bottomArray.count; i++){
                if (i == 0) {
                    if (_device == YES) {
                        MenuButton *btn = [[MenuButton alloc] initWithButtonFrame:CGRectMake(9, _secMenuView.frame.size.height/2 - 52/2 -17, 52, 52 +25) buttonImageFrame:CGRectMake(1, 1, 50, 50) buttonTitleFrame:CGRectMake(1, 62, 50, 15) buttonImage:[UIImage imageNamed:@"无滤镜.png"] buttonTitle:[bottomArray objectAtIndex:i] titleFont:11 buttonTag:secBottomBtnTag +i buttonSelected:NO buttonBackgroundImage:[UIImage imageNamed:@"滤镜_缩略图选中框黑色.png"] clickButtonTarget:self clickButtonTarget:@selector(tapAction:) buttonCornerRadius:3.0 device:_device];
                        btn.titleView.textColor = [UIColor whiteColor];
                        [_secBottomButton addObject:btn];
                        [bottomView addSubview:btn];
                    }else{
                        MenuButton *btn = [[MenuButton alloc] initWithButtonFrame:CGRectMake(9, _secMenuView.frame.size.height/2 - 52/2 , 52, 52) buttonImageFrame:CGRectMake(1, 1, 50, 50) buttonTitleFrame:CGRectMake(1, 37, 50, 15) buttonImage:[UIImage imageNamed:@"无滤镜.png"] buttonTitle:[bottomArray objectAtIndex:i] titleFont:11 buttonTag:secBottomBtnTag +i buttonSelected:NO buttonBackgroundImage:[UIImage imageNamed:@"滤镜_缩略图选中框黑色.png"] clickButtonTarget:self clickButtonTarget:@selector(tapAction:) buttonCornerRadius:3.0 device:_device];
                        [_secBottomButton addObject:btn];
                        [bottomView addSubview:btn];
                    }
                }else{
                    NSString *str = [NSString stringWithFormat:@"%@",[secImageArr objectAtIndex:(i -1)]];
                    if (_device == YES) {
                        MenuButton *btn = [[MenuButton alloc] initWithButtonFrame:CGRectMake(52*i +18*i +1, _secMenuView.frame.size.height/2 -52/2 -17, 52, 52 +25) buttonImageFrame:CGRectMake(1, 1, 50, 50) buttonTitleFrame:CGRectMake(0, 62, 52, 15) buttonImage:[UIImage imageWithContentsOfFile:str] buttonTitle:[bottomArray objectAtIndex:i] titleFont:11 buttonTag:secBottomBtnTag +i buttonSelected:NO buttonBackgroundImage:[UIImage imageNamed:@"滤镜_缩略图选中框黑色.png"] clickButtonTarget:self clickButtonTarget:@selector(tapAction:) buttonCornerRadius:3.0 device:_device];
                        [_secBottomButton addObject:btn];
                        [bottomView addSubview:btn];
                        
                    }else{
                        MenuButton *btn = [[MenuButton alloc] initWithButtonFrame:CGRectMake(52*i +18*i +1, _secMenuView.frame.size.height/2 -52/2, 52, 52) buttonImageFrame:CGRectMake(1, 1, 50, 50) buttonTitleFrame:CGRectMake(1, 37, 50, 15) buttonImage:[UIImage imageWithContentsOfFile:str] buttonTitle:[bottomArray objectAtIndex:i] titleFont:11 buttonTag:secBottomBtnTag +i buttonSelected:NO buttonBackgroundImage:[UIImage imageNamed:@"滤镜_缩略图选中框黑色.png"] clickButtonTarget:self clickButtonTarget:@selector(tapAction:) buttonCornerRadius:3.0 device:_device];
                        [_secBottomButton addObject:btn];
                        [bottomView addSubview:btn];
                    }
                }
            }
            switch (_menu.firMenuButtonTag) {
                case 1:
                    if (_secButtonStatus.selectedBorderTag != 0) {
                        //NSLog(@"设置选中");
                        MenuButton *btn = [_secBottomButton objectAtIndex:_secButtonStatus.selectedBorderTag -100];
                        btn.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框.png"];
                    }else{
                        MenuButton *btn = [_secBottomButton objectAtIndex:0];
                        btn.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框.png"];
                    }
                    break;
                default:
                    if (_secButtonStatus.selectedCarterTag != 0) {
                        //NSLog(@"设置选中");
                        MenuButton *btn = [_secBottomButton objectAtIndex:_secButtonStatus.selectedCarterTag -200];
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
            btn.backgroundColor = [UIColor clearColor];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            [btn.titleLabel setTextColor:[UIColor blackColor]];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 20.0;
            [btn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = menuBtn.bottomTag +i;
            [menuBtn.bottomView addSubview:btn];
        }
        float topWidth =  menuBtn.topView.frame.size.width / menuBtn.topArr.count;
        for (int i = 0; i < menuBtn.topArr.count; i++){
            UIButton *btn = [[UIButton alloc] init];
            [btn setTitle:[menuBtn.topArr objectAtIndex:i] forState:UIControlStateNormal];
            [btn setFrame:CGRectMake(topWidth *i +5, topView.frame.size.height - 45, topWidth -25, topWidth-25)];
            //NSLog(@"%f",width);
            btn.backgroundColor = [UIColor clearColor];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            [btn.titleLabel setTextColor:[UIColor blackColor]];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 20.0;
            [btn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = menuBtn.topTag +i;
            [menuBtn.topView addSubview:btn];
        }
    }
}
// 二级菜单button响应事件
-(void) tapAction:(id) sender
{
    NSLog(@"%@",sender);
    [_selectView removeFromSuperview];
    MenuButton *btn = (MenuButton *)[sender view];
    for (MenuButton *allButton in _secBottomButton) {
        allButton.titleView.textColor = [UIColor colorWithRed:106.0/255.0 green:106.0/255.0 blue:106.0/255.0 alpha:1.0];
        allButton.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框黑色.png"];
    }
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    NSLog(@"选中的二级Button的tag:%d",btn.tag);
    if (btn.tag <200 && btn.tag >=100) {
        _secButtonStatus.selectedBorderTag = btn.tag;
        state.borderTag = btn.tag;
        NSLog(@"%d",_secButtonStatus.selectedBorderTag);
    }else if (btn.tag < 300 && btn.tag >=200){
        _secButtonStatus.selectedCarterTag = btn.tag;
        state.cartoonTag = btn.tag;
        NSLog(@"%d",_secButtonStatus.selectedCarterTag);
    }
    btn.titleView.textColor = [UIColor whiteColor];
    btn.backgroundImageView.image = [UIImage imageNamed:@"滤镜_缩略图选中框.png"];
    UIImage* image = [self actionTakeImage:btn.tag];
    
    if(btn.tag<300 && btn.tag>=200)
    {
        CGRect rcTextView = CGRectMake(80, 80, 80, 80);
        SSImageView *imageView = [[SSImageView alloc]initWithFrame:rcTextView];
        [imageView setImage:image];
        [self.stageView addSubview:imageView];
        
        [[SSEditView shareInstance]initLayout:imageView];
    }
}

-(UIImage*) actionTakeImage :(int) tag
{
    UIImage* image = nil;
    switch (tag) {
        case 100:
            _borderView.image = nil;
            NSLog(@"我是帽子");
            break;
        case 101:
            NSLog(@"%@",[_frameArr objectAtIndex:0]);
            _borderView.image = [UIImage imageWithContentsOfFile:[_frameArr objectAtIndex:0]];
            NSLog(@"我是第一个边框");
            break;
        case 102:
            _borderView.image = [UIImage imageWithContentsOfFile:[_frameArr objectAtIndex:1]];
            NSLog(@"我是第二个边框");
            break;
        case 103:
            _borderView.image = [UIImage imageWithContentsOfFile:[_frameArr objectAtIndex:2]];
            NSLog(@"我是第三个边框");
            break;
        case 104:
            _borderView.image = [UIImage imageWithContentsOfFile:[_frameArr objectAtIndex:3]];
            NSLog(@"我是第四个边框");
            break;
        case 105:
            _borderView.image = [UIImage imageWithContentsOfFile:[_frameArr objectAtIndex:4]];
            break;
        case 106:
            _borderView.image = [UIImage imageWithContentsOfFile:[_frameArr objectAtIndex:5]];
            break;
        case 107:
            _borderView.image = [UIImage imageWithContentsOfFile:[_frameArr objectAtIndex:6]];
        case 200:
            _cartImageView.hidden = YES;
            NSLog(@"我是帽子");
            break;
        case 201:
            _cartImageView.hidden = NO;
            _cartImageView.resizingControl.hidden = NO;
            // _cartView.image =
            image = [UIImage imageWithContentsOfFile:[_cartArr objectAtIndex:0]];
            NSLog(@"我是帽子");
            break;
        case 202:
            _cartImageView.hidden = NO;
            _cartImageView.resizingControl.hidden = NO;
            // _cartView.image =
            image = [UIImage imageWithContentsOfFile:[_cartArr objectAtIndex:1]];
            NSLog(@"我是帽子");
            break;
        case 203:
            _cartImageView.hidden = NO;
            _cartImageView.resizingControl.hidden = NO;
            // _cartView.image =
            image = [UIImage imageWithContentsOfFile:[_cartArr objectAtIndex:2]];
            NSLog(@"我是帽子");
            break;
        case 204:
            _cartImageView.hidden = NO;
            _cartImageView.resizingControl.hidden = NO;
            // _cartView.image =
            image = [UIImage imageWithContentsOfFile:[_cartArr objectAtIndex:3]];
            NSLog(@"我是帽子");
            break;
        case 205:
            _cartImageView.hidden = NO;
            _cartImageView.resizingControl.hidden = NO;
            // _cartView.image =
            image = [UIImage imageWithContentsOfFile:[_cartArr objectAtIndex:4]];
            NSLog(@"我是帽子");
            break;
        case 206:
            _cartImageView.hidden = NO;
            _cartImageView.resizingControl.hidden = NO;
            // _cartView.image =
            image = [UIImage imageWithContentsOfFile:[_cartArr objectAtIndex:5]];
            NSLog(@"我是帽子");
            break;
        case 207:
            _cartImageView.hidden = NO;
            _cartImageView.resizingControl.hidden = NO;
            // _cartView.image =
            image = [UIImage imageWithContentsOfFile:[_cartArr objectAtIndex:6]];
            NSLog(@"我是帽子");
            break;
        case 208:
            _cartImageView.hidden = NO;
            _cartImageView.resizingControl.hidden = NO;
            // _cartView.image =
            image = [UIImage imageWithContentsOfFile:[_cartArr objectAtIndex:7]];
            NSLog(@"我是帽子");
            break;
        case 209:
            _cartImageView.hidden = NO;
            _cartImageView.resizingControl.hidden = NO;
            // _cartView.image =
            image = [UIImage imageWithContentsOfFile:[_cartArr objectAtIndex:8]];
            NSLog(@"我是帽子");
            break;
        case 210:
            _cartImageView.hidden = NO;
            _cartImageView.resizingControl.hidden = NO;
            // _cartView.image =
            image = [UIImage imageWithContentsOfFile:[_cartArr objectAtIndex:9]];
            NSLog(@"我是帽子");
            break;
        case 211:
            _cartImageView.hidden = NO;
            _cartImageView.resizingControl.hidden = NO;
            // _cartView.image =
            image = [UIImage imageWithContentsOfFile:[_cartArr objectAtIndex:10]];
            NSLog(@"我是帽子");
            break;
        default:
            break;
    }
    return image;
}

//返回按钮响应事件
-(void) clickBackButton
{
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    state.cartoonX = _cartImageView.frame.origin.x;
    state.cartoonY = _cartImageView.frame.origin.y;
    state.cartoonW = _cartImageView.frame.size.width;
    state.cartoonH = _cartImageView.frame.size.height;
    state.cartRotate = _cartImageView.angleDiff;

    [self backToPrevWindow];
}

//导航栏确定按钮
-(void) clickSureButton
{
    [[SSEditView shareInstance]removeLayout];
    
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    state.cartoonX = _cartImageView.frame.origin.x;
    state.cartoonY = _cartImageView.frame.origin.y;
    state.cartoonW = _cartImageView.frame.size.width;
    state.cartoonH = _cartImageView.frame.size.height;
    //state.cartoonRect = [NSValue valueWithCGRect:_cartImageView.frame];
    //NSLog(@"%f,%f,%f,%f",[state.cartoonRect CGRectValue].origin.x,[state.cartoonRect CGRectValue].origin.y,[state.cartoonRect CGRectValue].size.width,[state.cartoonRect CGRectValue].size.height);
    state.cartRotate = _cartImageView.angleDiff;
    
    // _cartImageView.resizingControl.hidden = YES;
    UIImage* scaleImage = [Common convertViewToImageBySize:_stageView withFitSize:CGSizeMake(480,480)];
    NSString* decorateImagePath = [Common getDecorateImagePath];
    [Common writeImageIntoPath:scaleImage withTargetPath:decorateImagePath];
    std::string szDecorateImagePath = std::string([decorateImagePath UTF8String]);
    SynthesisParamterInstance::instance().setDecorateImgPath(szDecorateImagePath);
    /*
    _cutOutImage = [self transformToImage];
    CGSize size = CGSizeMake(480, 480);
    _cutOutImage = [Common OriginImage:_cutOutImage scaleToSize:size];
    NSLog(@"%f,%f",_cutOutImage.size.width,_cutOutImage.size.height);
    NSData *imagedata = UIImagePNGRepresentation(_cutOutImage);

    NSString *savedImagePath =[Common getDecorateImagePath];
    NSLog(@"%@",savedImagePath);
    [imagedata writeToFile:savedImagePath atomically:YES];
    
    SynthesisParamterInstance& synParaInstance = SynthesisParamterInstance::instance();
    std::string decorateImagePath = std::string([[Common getDecorateImagePath] UTF8String]);
    synParaInstance.setDecorateImgPath(decorateImagePath);
    //*/
//  [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_EDITED" object:self];
//  [self.navigationController popViewControllerAnimated:YES];
  [self backToPrevWindow];
  NSLog(@"完成所有编辑");
}

-(void)backToPrevWindow
{
    self.playerView.player.volume = 0;
    [self.playerView.player pause];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_EDITED" object:self];
    [self.navigationController popViewControllerAnimated:YES];
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
-(void) checkDecorateState
{
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    if (state.borderTag != -1) {
        _secButtonStatus.selectedBorderTag = state.borderTag;
        [self actionTakeImage:state.borderTag];
    }
    if (state.cartoonTag != -1) {
        _secButtonStatus.selectedCarterTag = state.cartoonTag;
        [self actionTakeImage:state.cartoonTag];
       // NSLog(@"%f,%f,%f,%f",[state.cartoonRect CGRectValue].origin.x,[state.cartoonRect CGRectValue].origin.y,[state.cartoonRect CGRectValue].size.width,[state.cartoonRect CGRectValue].size.height);
//        _cartImageView.frame = CGRectMake(state.cartoonX, state.cartoonY, state.cartoonW, state.cartoonH);
//        //_cartImageView.frame = [state.cartoonRect CGRectValue];
//        _cartImageView.transform = CGAffineTransformMakeRotation(-state.cartRotate);
//        _cartImageView.angleDiff = state.cartRotate;
    }
    if (state.cartoonX != 0 || state.cartoonY != 0 || state.cartoonW != 0 || state.cartoonH != 0) {
        _cartImageView.frame = CGRectMake(state.cartoonX, state.cartoonY, state.cartoonW, state.cartoonH);
    }
    if (state.cartRotate != 0) {
        _cartImageView.transform = CGAffineTransformMakeRotation(-state.cartRotate);
    }
}

-(void) getBackToLastCurrent :(int)tag
{
    assert(tag>0);
    MenuButton *btn = [_firButton objectAtIndex:(tag -1)];
    [self loadSecondMenuBtn:btn];
//
//    if (btn.tag == 1) {
//        btn.selected = YES;
//        btn.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:1.0];
//        [btn.titleView setTextColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1]];
//        btn.imageView.image = [UIImage imageNamed:@"装饰_边框_down.png"];
//        // NSArray *musicArr = [NSArray arrayWithObjects:@"默认",@"帽子",@"丝带",@"白云",@"汪星人",@"黑土", nil];
//        NSArray *musicArr = [NSArray arrayWithObjects:@"无边框",@"蓝色枫叶",@"传情", @"橘色梦幻",@"粉色奥运",@"复古阿狸",@"酷炫红色", @"五彩世界", nil];
//        int tag = btn.tag *10;
//        _menu.firMenuButtonTag = 1;
//        [Common MoveView:_secMenuView To:CGRectMake(_secMenuView.frame.origin.x, _secMenuView.frame.origin.y +((self.view.frame.size.height -_firMenuView.frame.size.height -_navBar.frame.size.height - self.playerView.frame.size.height -71)/2) +_firMenuView.frame.size.height, _secMenuView.frame.size.width,_secMenuView.frame.size.height) During:0.5];
//        [_selectView removeFromSuperview];
//        [_secBottomButton removeAllObjects];
//        [self createSecendMenuBottomViewArr:musicArr
//                           secondTopViewArr:nil
//                           secMenuButtonTag:tag
//                              secMenuTopTag:0
//                             secBottomLabel:nil
//                                secTopLabel:nil
//                                secImageArr:_frameImageArr];
//        [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_firMenuView.frame.size.height -71 -((self.view.frame.size.height -_firMenuView.frame.size.height -_navBar.frame.size.height - self.playerView.frame.size.height -71)/2) +5, self.view.frame.size.width, 71) During:0.5];
//    }else if (btn.tag == 2){
//        btn.selected = YES;
//        btn.backgroundColor = [UIColor colorWithRed:16.0/255.0 green:16.0/255.0 blue:16.0/255.0 alpha:1.0];
//        [btn.titleView setTextColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1]];
//        btn.imageView.image = [UIImage imageNamed:@"装饰_卡通_down.png"];
//        // NSArray *musicArr = [NSArray arrayWithObjects:@"默认",@"帽子",@"丝带",@"白云",@"汪星人",@"黑土", nil];
//        NSArray *musicArr = [NSArray arrayWithObjects:@"无卡通", @"卡通",@"红脸蛋",@"蝴蝶结",@"荷叶帽",@"眼镜", nil];
//        int tag = btn.tag *10;
//        _menu.firMenuButtonTag = 2;
//        [Common MoveView:_secMenuView To:CGRectMake(_secMenuView.frame.origin.x, _secMenuView.frame.origin.y +((self.view.frame.size.height -_firMenuView.frame.size.height -_navBar.frame.size.height - self.playerView.frame.size.height -71)/2) +_firMenuView.frame.size.height, _secMenuView.frame.size.width,_secMenuView.frame.size.height) During:1.0];
//        [_selectView removeFromSuperview];
//        [_secBottomButton removeAllObjects];
//        [self createSecendMenuBottomViewArr:musicArr
//                           secondTopViewArr:nil
//                           secMenuButtonTag:tag
//                              secMenuTopTag:0
//                             secBottomLabel:nil
//                                secTopLabel:nil
//                                secImageArr:_cartoonImageArr];
//        [Common MoveView:_secMenuView To:CGRectMake(0, self.view.frame.size.height -_firMenuView.frame.size.height -71 -((self.view.frame.size.height -_firMenuView.frame.size.height -_navBar.frame.size.height - self.playerView.frame.size.height -71)/2), self.view.frame.size.width, 71) During:0.5];
//    }
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
