//
//  AddTitleViewController.m
//  libFeinnoVideo
//
//  Created by coCo on 14-9-11.
//  Copyright (c) 2014年 wzq. All rights reserved.
//

#import "AddTitleViewController.h"
#import "Menu.h"
#import "TextStatus.h"
#import "NavigationBar.h"
#import "MenuButton.h"
#import "PanImageView/ZDStickerView.h"
#import "PluginInterfaceInfo.h"
#import "base/Common.h"
#import "base/FeinnoVideoState.h"

#define kMaxNum  8
@interface AddTitleViewController ()<UIGestureRecognizerDelegate, UITextFieldDelegate>
{
    NavigationBar *_navBar;                 //导航栏
    UIImageView *_addTitleImage;            //从视频中抽取出的某一帧的图片
    UIView *_firMenuView;                   //一级菜单
    UIScrollView *_firScrollView;           //一级菜单的滚动视图
    UIScrollView *_bottomScrollView;        //二级菜单滚动视图
    UIView *_bottomView;                    //二级菜单的下层菜单
    UIView *_secMenuView;                   //二级菜单
    Menu *_menu;
    NSMutableArray *_firButton;             //一级菜单的的buttonArr
    NSMutableArray *_secBottomButton;       //二级菜单中下层菜单Arr,若只有二级菜单的下层菜单则为下层菜单的Arr
    NSMutableArray *_secTopButton;          //二级菜单中上层菜单Arr,若只有一级菜带则为空
    UIImageView *_lucencyView;              //字幕背景框
    UITextField *_textField;                //输入的文本框
    UIImageView *_colorView;                //控制文本颜色
    UIView *_slider;                        //滑块
    UIImageView *_currentColorView;         //当前选择颜色显示框
    UIImageView *_currentColor;             //当前显示的颜色
    UIImageView *_currentLabelColor;        //显示框显示当前的颜色
    CGFloat _lastColorWidth;                //上一次slider的width
    CGFloat _lastScale;
    CGRect _oldFrame;                       //原来图片的大小
    CGRect _largeFrame;                     //图片放大最大程度
    TextStatus *_currentlyStatus;           //当前状态
    UIImageView *_selectView;               //选中button的标示
    UIImageView *_clarityView;              //截取透明的View给视频进行编辑
    // UIImage *_cutOutImage;
    NSArray *_firImageArr;                 //一级菜单的图片Arr
    float r;
    float g;
    float b;
    NSTimer *_timer;                        //显示颜色框计时
    ZDStickerView *_panImageView;           //可移动的图片
    ZDStickerView *_panTextView;            //添加的文字
    NSArray *bubbleImageArr;                //气泡二级菜单的缩略图数组
    NSArray *fontImageArr;                  //字体二级菜单的image数组
}
@property(nonatomic, retain) UIImageView *addTitleImage;
@end

@implementation AddTitleViewController

- (id)init
{
    self = [super init];
    if (self) {
        _vcID = VC_ADD_SUBTITLE;
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
    _firButton = [[NSMutableArray alloc] init];
    _secBottomButton = [[NSMutableArray alloc] init];
    _secTopButton = [[NSMutableArray alloc] init];
    _currentlyStatus = [[TextStatus alloc] init];
    _currentlyStatus.boldfaced = NO;
    _currentlyStatus.shadow = NO;
    _menu = [[Menu alloc] init];
    _firImageArr = [NSArray arrayWithObjects:@"气泡_normal.png",@"字体_normal.png",@"样式_normal.png", nil];
    bubbleImageArr = [NSArray arrayWithObjects:@"",@"bubble10.png",@"bubble11.png",@"bubble3.png",@"bubble4.png",@"bubble5.png", nil];
    self.view.backgroundColor = [UIColor blackColor];
    _lastColorWidth = 0;
    [self checkStatusHidden];
    [self checkPlayerViewHidden:YES];
    [self mediaTimeShow:YES];
//    [self isshowSliderView :YES];
//    [self mediaTimeShow :YES];
//    [self checkPlayerViewHidden :YES];
    //[self checkTitleState];
    [self layout];
    
}


-(void) layout
{
#pragma mark - 导航栏
//    _navBar = [[NavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 51) titleText:@"添加字幕" leftButtonTarget:self leftButtonAction:@selector(clickBackButton) leftButtonImage:[UIImage imageNamed:@"上一步_normal.png"] leftSelectedButtonImage:[UIImage imageNamed:@"上一步_down.png"] rightButtonTarget:self rightButtonAction:@selector(clickSureButton) rightButtonImage:[UIImage imageNamed:@"顶部导航栏_确定_normal.png"] rightSelectedButtonImage:[UIImage imageNamed:@"顶部导航栏_确定_down.png"]];
//    [self.view addSubview:_navBar];
#pragma mark - 截取到的图片------------------------------------------------------------------------------------------------
    self.addTitleImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 51, 320, 320)];
    _addTitleImage.userInteractionEnabled = YES;
    _addTitleImage.image = [Common firstVideoFrameImage:[[PluginInterfaceInfo instance] srcVideoPath]];
    [self.view addSubview:_addTitleImage];
#pragma mark - 编辑框
    //透明的View
    _clarityView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    _clarityView.userInteractionEnabled = YES;
    _clarityView.backgroundColor = [UIColor clearColor];
    [_addTitleImage addSubview:_clarityView];
    
    //添加的图片
    _lucencyView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 120, 150, 100)];
    _lucencyView.image = [UIImage imageNamed:@"添加字幕_默认.png"];
    _lucencyView.userInteractionEnabled = YES;
    _lucencyView.backgroundColor = [UIColor clearColor];
    [_clarityView addSubview:_lucencyView];
    
    _panImageView = [[ZDStickerView alloc] initWithFrame:_lucencyView.frame];
    _panImageView.userInteractionEnabled = YES;
    _panImageView.labelDelegate = self;
    _panImageView.contentView = _lucencyView;
    _panImageView.preventsPositionOutsideSuperview = NO;
    _panImageView.resizingControl.hidden = NO;
    //[_panImageView  showEditingHandles];
    [_clarityView addSubview:_panImageView];
    
#pragma mark - 菜单布局----------------------------------------------------------------------------------------------------
    NSArray *firMenuArr = [NSArray arrayWithObjects:@"气泡",@"字体",@"样式", nil];
    // 第一级菜单的View
    _firMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 38)];
    // 第一级菜单的滚动视图
    _firScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -38, self.view.frame.size.width, 38)];
    _firScrollView.backgroundColor = [UIColor darkGrayColor];
    _firScrollView.showsHorizontalScrollIndicator = NO;
    _firScrollView.contentSize = _firMenuView.frame.size;
    _firScrollView.bounces = NO;
    
    [self.view addSubview:_firScrollView];
    [self createMenuButtonArr:firMenuArr];
    [_firScrollView addSubview:_firMenuView];
//    @property (nonatomic ) NSValue *bubbleRect;
//    @property (nonatomic ) NSValue *textRect;
//    @property (nonatomic ,retain) NSString *titleText;
//    @property (nonatomic ) float rotate;

    if (_currentlyStatus.bubbleX != 0 || _currentlyStatus.bubbleY != 0 || _currentlyStatus.bubbleW != 0 || _currentlyStatus.bubbleH != 0) {
        _panImageView.frame = CGRectMake(_currentlyStatus.bubbleX, _currentlyStatus.bubbleY, _currentlyStatus.bubbleW, _currentlyStatus.bubbleH);
//        _panImageView.resizingControl.frame = CGRectMake(_currentlyStatus.bubbleX, _currentlyStatus.bubbleY, _currentlyStatus.bubbleW, _currentlyStatus.bubbleH);
    }
    if (_currentlyStatus.textX != 0 || _currentlyStatus.textY != 0 || _currentlyStatus.textW != 0 || _currentlyStatus.textH != 0) {
        _panImageView.label.frame = CGRectMake(_currentlyStatus.textX, _currentlyStatus.textX, _currentlyStatus.textW, _currentlyStatus.textH);
    }
    if (_currentlyStatus.titleText != NULL) {
        _panImageView.label.text = _currentlyStatus.titleText;
    }
    if (_currentlyStatus.rotate != 0) {
        _panImageView.transform = CGAffineTransformMakeRotation(-_currentlyStatus.rotate);
    }
    [self.view bringSubviewToFront:_navBar];
}

#pragma mark - 创建按钮视图-----------------------------------------------------------------------------------------------
// 创建一级菜单的button
-(void) createMenuButtonArr:(NSArray *)array
{
    for (int i = 0; i < array.count; i++){
        MenuButton *btn = [[MenuButton alloc] initWithButtonFrame:CGRectMake(self.view.frame.size.width/3 *i, 0, self.view.frame.size.width/3, 38) buttonImageFrame:CGRectMake(18, 10, 21, 21) buttonTitleFrame:CGRectMake(47, 9, 30, 21) buttonImage:[UIImage imageNamed:[_firImageArr objectAtIndex:i]] buttonTitle:[array objectAtIndex:i] titleFont:13 buttonTag:i+1 buttonSelected:NO buttonBackgroundImage:nil clickButtonTarget:self clickButtonTarget:@selector(createSecView:) buttonCornerRadius:0 device:nil];
        //        if (i == 0) {
        //            btn.imageView.image = [UIImage imageNamed:@"主题_selected.png"];
        //            btn.titleView.textColor = [UIColor colorWithRed:238.0/255 green:104.0/255 blue:62.0/255 alpha:1];
        //        }
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
        NSString *title = [NSString stringWithFormat:@"%@_normal.png",allButton.titleView.text];
        [allButton.titleView setTextColor:[UIColor colorWithRed:226.0/255 green:216.0/255 blue:194.0/255 alpha:1]];
        allButton.imageView.image = [UIImage imageNamed:title];
        //NSLog(@"%hhd",allButton.selected);
    }
    //重新加载所需的控件
    if (btn.tag == 1) {
        btn.selected = YES;
        btn.imageView.image = [UIImage imageNamed:@"气泡_down.png"];
        [btn.titleView setTextColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1]];
        NSArray *musicArr = [NSArray arrayWithObjects:@"默认",@"帽子",@"丝带",@"白云",@"汪星人",@"黑土", nil];
        int tag = btn.tag *10;
        _menu.firMenuButtonTag = 1;
        [_selectView removeFromSuperview];
        [self createSecendMenuBottomViewArr:musicArr
                           secondTopViewArr:nil
                           secMenuButtonTag:tag
                              secMenuTopTag:0
                             secBottomLabel:nil
                                secTopLabel:nil
                             bottomImageArr:bubbleImageArr];
    }else if (btn.tag == 2){
        btn.selected = YES;
        btn.imageView.image = [UIImage imageNamed:@"字体_down.png"];
        [btn.titleView setTextColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1]];
        NSArray *musicArr = [NSArray arrayWithObjects:@"默认",@"帽子",@"丝带",@"白云",@"汪星人",@"黑土", nil];
        int tag = btn.tag *10;
        _menu.firMenuButtonTag = 2;
        [_selectView removeFromSuperview];
        [self createSecendMenuBottomViewArr:musicArr
                           secondTopViewArr:nil
                           secMenuButtonTag:tag
                              secMenuTopTag:0
                             secBottomLabel:nil
                                secTopLabel:nil
                             bottomImageArr:fontImageArr];
    }else if (btn.tag == 3){
        btn.selected = YES;
        btn.imageView.image = [UIImage imageNamed:@"样式_down.png"];
        [btn.titleView setTextColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:170.0/255 alpha:1]];
        //样式
        _secMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -154, self.view.frame.size.width, 71 +45)];
        _secMenuView.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.6];
        [self.view addSubview:_secMenuView];
        UIView *typeView = [[UIView alloc] initWithFrame:CGRectMake(0, _secMenuView.frame.size.height -71, self.view.frame.size.width, 71)];
        typeView.backgroundColor = [UIColor blackColor];
        [_secMenuView addSubview:typeView];
        //粗体
        UILabel *font = [[UILabel alloc] initWithFrame:CGRectMake(50, typeView.frame.size.height/2 -15, 30, 30)];
        [font setText:@"粗体"];
        font.font = [UIFont systemFontOfSize:14.0];
        [font setTextColor:[UIColor colorWithRed:209.0/255 green:200.0/255 blue:180.0/255 alpha:1]];
        font.backgroundColor = [UIColor clearColor];
        [typeView addSubview:font];
        
        UISwitch *fontSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(50 +30 +9, typeView.frame.size.height/2 -15, 51, 30)];
        fontSwitch.backgroundColor = [UIColor whiteColor];
        fontSwitch.layer.masksToBounds = YES;
        fontSwitch.layer.cornerRadius = 15;
        if (_currentlyStatus.boldfaced == 1) {
            fontSwitch.on = YES;
        }else{
            fontSwitch.on = NO;
        }
        [fontSwitch addTarget:self action:@selector(changeFont:) forControlEvents:UIControlEventValueChanged];
        [typeView addSubview:fontSwitch];
        //阴影
        UILabel *shade = [[UILabel alloc] initWithFrame:CGRectMake(180, typeView.frame.size.height/2 -15, 30, 30)];
        [shade setText:@"阴影"];
        shade.font = [UIFont systemFontOfSize:14.0];
        [shade setTextColor:[UIColor colorWithRed:209.0/255 green:200.0/255 blue:180.0/255 alpha:1]];
        shade.backgroundColor = [UIColor clearColor];
        [typeView addSubview:shade];
        
        UISwitch *shadeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(219, typeView.frame.size.height/2 -15, 51, 30)];
        shadeSwitch.backgroundColor = [UIColor whiteColor];
        shadeSwitch.layer.masksToBounds = YES;
        shadeSwitch.layer.cornerRadius = 15;
        if (_currentlyStatus.shadow == 1) {
            shadeSwitch.on = YES;
        }else{
            shadeSwitch.on = NO;
        }
        [shadeSwitch addTarget:self action:@selector(changeShade:) forControlEvents:UIControlEventValueChanged];
        [typeView addSubview:shadeSwitch];
        //文本颜色
        //        UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, _addTitleImage.frame.size.height -45, 320, 45)];
        //        colorView.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.6];
        //        //colorView.backgroundColor = [UIColor redColor];
        //        [_addTitleImage addSubview:colorView];
        //进度条
        //        UIImageView *colorImage = [[UIImageView alloc] initWithFrame:CGRectMake(40, colorView.frame.size.height/2 -7, 266, 30)];
        //        colorImage.image = [UIImage imageNamed:@"4.png"];
        //        [colorView addSubview:colorImage];
        _colorView = [[UIImageView alloc] initWithFrame:CGRectMake(40, (_secMenuView.frame.size.height -typeView.frame.size.height)/2 -4, 247, 7)];
        _colorView.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1];
        _colorView.userInteractionEnabled = YES;
        [_secMenuView addSubview:_colorView];
        
        _slider = [[UIView alloc] init];
        if (_currentlyStatus.sliderX > 0) {
            _slider.frame = CGRectMake(_currentlyStatus.sliderX, -3, 13, 13);
        }else{
            _slider.frame = CGRectMake(0, -3, 13, 13);
        }
        _slider.backgroundColor = [UIColor whiteColor];
        _slider.layer.masksToBounds = YES;
        _slider.layer.cornerRadius = 6.5;
        [_colorView addSubview:_slider];
        
        UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragSlider:)];
        [_slider addGestureRecognizer:drag];
        
        _currentColorView = [[UIImageView alloc] initWithFrame:CGRectMake(30.5, -27, 32, 37)];
        _currentColorView.image = [UIImage imageNamed:@"颜色条上按下时提示气泡.png"];
        _currentColorView.alpha = 0;
        [_secMenuView addSubview:_currentColorView];
        
        _currentColor = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 28, 28)];
        _currentColor.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:1.0];
        [_currentColorView addSubview:_currentColor];
        
        _currentLabelColor = [[UIImageView alloc] initWithFrame:CGRectMake(14, _secMenuView.frame.size.height -typeView.frame.size.height -14 -17, 17, 17)];
        _currentLabelColor.image = [UIImage imageNamed:@""];
        _currentLabelColor.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
        [_secMenuView addSubview:_currentLabelColor];
        if (_currentlyStatus.lastColorwidth >0) {
            [self checkColor:_currentlyStatus.sliderX moveFrame:(_currentlyStatus.sliderX -_currentlyStatus.lastColorwidth)];
        }
    }
}
//创建二级View
-(void) createSecendMenuBottomViewArr:(NSArray *)secBottomArr
                     secondTopViewArr:(NSArray *)secTopArr
                     secMenuButtonTag:(int)bottomButtonTag
                        secMenuTopTag:(int)topButtonTag
                       secBottomLabel:(NSString *)bottomButtonText
                          secTopLabel:(NSString *)topButtonText
                       bottomImageArr:(NSArray *)bottomImageArr
{
    _secMenuView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -109, self.view.frame.size.width, 71)];
    _secMenuView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_secMenuView];
    
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
                      secBottomImageArr:nil];
    }else{
        //只有一个二级菜单
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,(52+16) *(secBottomArr.count) +11, 71 )];
        _bottomView.backgroundColor = [UIColor blackColor];
        
        _bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 71)];
        _bottomScrollView.backgroundColor = [UIColor darkGrayColor];
        _bottomScrollView.contentSize = _bottomView.frame.size;
        _bottomScrollView.showsHorizontalScrollIndicator = NO;
        _bottomScrollView.bounces = NO;
        [_bottomScrollView addSubview:_bottomView];
        [_secMenuView addSubview:_bottomScrollView];
        _menu.bottomView = _bottomView;
        _menu.bottomArr = secBottomArr;
        NSLog(@"%@",_menu.bottomView);
        NSLog(@"111%@",_menu.bottomArr);
        [self createMenuBottomButtonArr:secBottomArr
                       menuTopButtonArr:nil
                      secMenuBottomView:_bottomView secMenuTopView:nil
                 secMenuButtonBottomTag:bottomButtonTag
                          secMenuTopTag:0
                      secBottomImageArr:bottomImageArr];
    }
}

// 创建二级菜单的button
-(void) createMenuBottomButtonArr:(NSArray *)bottomArray
                 menuTopButtonArr:(NSArray *)topArray
                secMenuBottomView:(UIView *)bottomView
                   secMenuTopView:(UIView *)topView
           secMenuButtonBottomTag:(int)secBottomBtnTag
                    secMenuTopTag:(int)secTopBtnTag
                secBottomImageArr:(NSArray *)secBottomImageArr
{
    if (topArray == nil) {
        float width = bottomView.frame.size.width / bottomArray.count;
        for (int i = 0; i < bottomArray.count; i++){
            if (i == 0) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(11, 11, 50, 50)];
                //NSLog(@"%f",width);
                NSLog(@"%@",[bottomArray objectAtIndex:i]);
                [btn setTitle:[bottomArray objectAtIndex:i] forState:UIControlStateNormal];
                [btn setBackgroundImage:[UIImage imageNamed:[secBottomImageArr objectAtIndex:i]] forState:UIControlStateNormal];
                btn.backgroundColor = [UIColor clearColor];
                //[btn.titleLabel setTextColor:[UIColor blackColor]];
                [btn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = secBottomBtnTag +i;
                [_secBottomButton addObject:btn];
                [bottomView addSubview:btn];
            }else{
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setFrame:CGRectMake(11 +50 +19 +(50 +19)*(i -1), 11, 50, 50)];
                //NSLog(@"%f",width);
                [btn setBackgroundImage:[UIImage imageNamed:[secBottomImageArr objectAtIndex:i]] forState:UIControlStateNormal];
                btn.backgroundColor = [UIColor clearColor];
                //[btn.titleLabel setTextColor:[UIColor blackColor]];
                [btn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = secBottomBtnTag +i;
                [_secBottomButton addObject:btn];
                [bottomView addSubview:btn];
            }
            NSLog(@"当前选中的气泡button的tag:%d",_currentlyStatus.selectBubbleTag);
            NSLog(@"当前选中的字体button的tag:%d",_currentlyStatus.selectFontTag);
            
        }
        switch (_menu.firMenuButtonTag) {
            case 1:
                _selectView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"缩略图选中下划线.png"]];
                if (_currentlyStatus.selectBubbleTag != 0) {
                    //NSLog(@"设置选中");
                    _selectView.frame = CGRectMake(width *(_currentlyStatus.selectBubbleTag-10) +11, _secMenuView.frame.size.height -10, 50, 2);
                    NSLog(@"%f",_secMenuView.frame.size.height -10);
                }else{
                    _selectView.frame = CGRectMake(11, _secMenuView.frame.size.height -10, 50, 2);
                    NSLog(@"%f",_secMenuView.frame.size.height -10);
                }
                [_bottomView addSubview:_selectView];
                break;
                
            default:
                _selectView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"缩略图选中下划线.png"]];
                if (_currentlyStatus.selectFontTag != 0) {
                    //NSLog(@"设置选中");
                    _selectView.frame = CGRectMake(width *(_currentlyStatus.selectBubbleTag-10) +11, _secMenuView.frame.size.height -10, 50, 2);
                }else{
                    _selectView.frame = CGRectMake(11, _secMenuView.frame.size.height -10, 50, 2);
                }
                [_bottomView addSubview:_selectView];
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
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:[menuBtn.bottomArr objectAtIndex:i] forState:UIControlStateNormal];
            [btn setFrame:CGRectMake(bottomWidth *i +5, bottomView.frame.size.height - 45, bottomWidth -25, bottomWidth-25)];
            //NSLog(@"%f",width);
            btn.backgroundColor = [UIColor whiteColor];
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
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:[menuBtn.topArr objectAtIndex:i] forState:UIControlStateNormal];
            [btn setFrame:CGRectMake(topWidth *i +5, topView.frame.size.height - 45, topWidth -25, topWidth-25)];
            //NSLog(@"%f",width);
            btn.backgroundColor = [UIColor whiteColor];
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
    [_selectView removeFromSuperview];
    UIButton *btn = (UIButton *)sender;
    if (btn.tag <20) {
        _currentlyStatus.selectBubbleTag = btn.tag;
        //FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
        //state.titleBubbleTag = [NSString stringWithFormat:@"%d",btn.tag];
        _selectView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"缩略图选中下划线.png"]];
        _selectView.frame = CGRectMake(btn.frame.origin.x,_secMenuView.frame.size.height -10, 50, 2);
        [_bottomView addSubview:_selectView];
    }else{
        _currentlyStatus.selectFontTag = btn.tag;
        //FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
        //state.titleFontTag = [NSString stringWithFormat:@"%d",btn.tag];
        _selectView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"缩略图选中下划线.png"]];
        _selectView.frame = CGRectMake(btn.frame.origin.x,_secMenuView.frame.size.height -10, 50, 2);
        [_bottomView addSubview:_selectView];
    }
    [self actionTakeImage:btn.tag];
}
-(void) actionTakeImage :(int) tag
{
    switch (tag) {
        case 10:
            break;
        case 11:
            _lucencyView.image = [UIImage imageNamed:[bubbleImageArr objectAtIndex:1]];
            NSLog(@"我是帽子 %d",tag);
            break;
        case 12:
            _lucencyView.image = [UIImage imageNamed:[bubbleImageArr objectAtIndex:2]];
            NSLog(@"我是帽子 %d",tag);
            break;
        case 13:
            _lucencyView.image = [UIImage imageNamed:[bubbleImageArr objectAtIndex:3]];
            NSLog(@"我是帽子 %d",tag);
            break;
        case 14:
            _lucencyView.image = [UIImage imageNamed:[bubbleImageArr objectAtIndex:4]];
            NSLog(@"我是帽子 %d",tag);
            break;
        case 15:
            _lucencyView.image = [UIImage imageNamed:[bubbleImageArr objectAtIndex:5]];
            NSLog(@"我是帽子 %d",tag);
            break;
        case 20:
            NSLog(@"我是帽子 %d",tag);
            break;
        case 21:
            NSLog(@"我是帽子 %d",tag);
            break;
        case 22:
            NSLog(@"我是帽子 %d",tag);
            break;
        case 23:
            NSLog(@"我是帽子 %d",tag);
            break;
        default:
            break;
    }
}
#pragma mark - 文字字数限制
//-(void)textFiledEditChanged:(NSNotification *)obj{
//    UITextField *textField = (UITextField *)obj.object;
//    
//    NSString *toBeString = textField.text;
//    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
//    if ([lang isEqualToString:@"zh-Hans"])
//    { // 简体中文输入，包括简体拼音，健体五笔，简体手写
//        UITextRange *selectedRange = [textField markedTextRange];
//        //获取高亮部分
//        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
//        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
//        if (!position) {
//            if (toBeString.length > kMaxNum) {
//                textField.text = [toBeString substringToIndex:kMaxNum];
//            }
//        }
//        // 有高亮选择的字符串，则暂不对文字进行统计和限制
//        else{
//            
//        }
//    }
//    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
//    else{
//        if (toBeString.length > kMaxNum) {
//            textField.text = [toBeString substringToIndex:kMaxNum];
//        }
//    }
//}
//
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string

{
    if ([string isEqualToString:@"\n"])
    {
        return YES;
    }
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (_textField == textField)
    {
        if ([aString length] > 20) {
            textField.text = [aString substringToIndex:20];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"超过最大字数不能输入了"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
    }
    return YES;
}
#pragma mark - 截图处理-------------------------------------------------------------------------------------------
////截图
//- (UIImage*)transformToImage
//{
//    UIGraphicsBeginImageContextWithOptions(_clarityView.frame.size, NO,[UIScreen mainScreen].scale);
//    [_clarityView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}
#pragma mark - 点击输入文字方法----------------------------------------------------------------------------------------------
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _panImageView.label.text = textField.text;
    _panImageView.label.hidden = NO;
    _textField.hidden = YES;
    [textField removeFromSuperview];
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - 字体、阴影开关响应方法-----------------------------------------------------------------------------------------
-(void) changeFont:(id)sender
{
    UISwitch *switchBtn = (UISwitch *)sender;
    BOOL isSwitchBtnOn = [switchBtn isOn];
    //FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    if (isSwitchBtnOn) {
        NSLog(@"粗体打开");
        //Label.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
        _panImageView.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
        _currentlyStatus.boldfaced = 1;
        //state.titleBold = [NSString stringWithFormat:@"%d",_currentlyStatus.boldfaced];
    }else{
        NSLog(@"粗体关闭");
        _panImageView.label.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        _currentlyStatus.boldfaced = NO;
        //state.titleBold = [NSString stringWithFormat:@"%d",_currentlyStatus.boldfaced];
    }
}
-(void) changeShade:(id)sender
{
    UISwitch *switchBtn = (UISwitch *)sender;
    BOOL isSwitchBtnOn = [switchBtn isOn];
    //FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    if (isSwitchBtnOn) {
        NSLog(@"阴影打开");
        _panImageView.label.shadowOffset = CGSizeMake(2, -3);
        _panImageView.label.shadowColor = [UIColor yellowColor];
        _currentlyStatus.shadow = 1;
        //state.titleShade = [NSString stringWithFormat:@"%d",_currentlyStatus.shadow];
    }else{
        NSLog(@"阴影关闭");
        _panImageView.label.shadowOffset = CGSizeMake(0, 0);
        _panImageView.label.shadowColor = [UIColor blackColor];
        _currentlyStatus.shadow = 0;
       // state.titleShade = [NSString stringWithFormat:@"%d",_currentlyStatus.shadow];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 返回上一界面按钮--------------------------------------------------------------------------------------------
-(void) pinLabel
{
    NSLog(@"我要输入");
    _panImageView.label.hidden = YES;
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(_panImageView.label.frame.origin.x, _panImageView.label.frame.origin.y, _panImageView.label.frame.size.width, _panImageView.label.frame.size.height)];
    [_panImageView addSubview:_textField];
    _textField.text = _panImageView.label.text;
    _textField.textAlignment = NSTextAlignmentCenter;
    _textField.backgroundColor = [UIColor clearColor];
    [_textField becomeFirstResponder];
    _textField.delegate = self;
}
-(void) textFieldHidden
{
    _textField.hidden = YES;
    [_textField resignFirstResponder];
}
-(void) backToIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}
//设置addTitleImageView上的所有的View的userInteractionEnabled
-(void) achieveView:(UIImageView *)imageView
{
    imageView.userInteractionEnabled = YES;
    for (id obj in imageView.subviews)  {
        if ([obj isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)obj;
            imageView.userInteractionEnabled = YES;
            for (id obj in imageView.subviews) {
                UIImageView *imageView = (UIImageView *)obj;
                imageView.userInteractionEnabled = YES;
            }
        }
    }
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
            [_lucencyView removeFromSuperview];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (alertView.tag ==2){
        if (buttonIndex == 1) {
            //FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
            //state.titleBubbleRect = [NSValue valueWithCGRect:_panImageView.frame];
//            state.titleBubbleX = _panImageView.frame.origin.x;
//            state.titleBubbleY = _panImageView.frame.origin.y;
//            state.titleBubbleW = _panImageView.frame.size.width;
//            state.titleBubbleH = _panImageView.frame.size.height;
            
            //state.titleTextRect = [NSValue valueWithCGRect:_panImageView.label.frame];
//            state.titleTextX = _panImageView.label.frame.origin.x;
//            state.titleTextY = _panImageView.label.frame.origin.y;
//            state.titleTextW = _panImageView.label.frame.size.width;
//            state.titleTextH = _panImageView.label.frame.size.height;
//            state.titleText = _panImageView.label.text;
//            state.titleRotate = _panImageView.angleDiff;
            
            
            _panImageView.resizingControl.hidden = YES;
            UIImage* scaleImage = [Common convertViewToImageBySize:_clarityView withFitSize:CGSizeMake(480,480)];
            [Common writeImageIntoPath:scaleImage withTargetPath:[Common getSubtitleImagePath]];
            /*
            _cutOutImage = [self transformToImage];
            CGSize size = CGSizeMake(320, 320);
            _cutOutImage = [Common OriginImage:_cutOutImage scaleToSize:size];
            NSLog(@"%@",_cutOutImage);
            NSLog(@"%f,%f",_cutOutImage.size.width,_cutOutImage.size.height);
            NSData *imagedata = UIImagePNGRepresentation(_cutOutImage);
            
            NSArray*paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *savedImagePath =[documentsDirectory stringByAppendingPathComponent:@"saveTitle.png"];
            NSLog(@"%@",savedImagePath);
            [imagedata writeToFile:savedImagePath atomically:YES];
            //*/
            [self.navigationController popViewControllerAnimated:YES];
            NSLog(@"完成所有编辑");
        }
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
//滑块移动方法
-(void) dragSlider:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:_colorView];
    sender.view.center = CGPointMake(sender.view.center.x + translation.x,sender.view.center.y + translation.y);
    NSLog(@"%f,%f",sender.view.center.x,sender.view.center.y);
    [sender setTranslation:CGPointZero inView:_colorView];
    if (_slider.frame.origin.x <0) {
        _slider.frame = CGRectMake(0, -3, _slider.frame.size.width, _slider.frame.size.height);
    }else if (_slider.frame.origin.x > 234){
        _slider.frame = CGRectMake(234, -3, _slider.frame.size.width, _slider.frame.size.height);
    }else if (_slider.frame.origin.y >-3 ||_slider.frame.origin.y <-3){
        _slider.frame = CGRectMake(_slider.frame.origin.x, -3, _slider.frame.size.width, _slider.frame.size.height);
    }
    NSLog(@"slider.x:%f,slider.y:%f",_slider.frame.origin.x,_slider.frame.origin.y);
    float moveWidth = _slider.frame.origin.x - _lastColorWidth;
    _lastColorWidth = _slider.frame.origin.x;
    NSLog(@"%f",_slider.frame.origin.x);
    [self checkColor:_slider.frame.origin.x moveFrame:moveWidth];
}

-(void) checkColor:(float)sliderOriginX moveFrame:(float)moveWidth
{
    int origin = sliderOriginX/13;
    switch (origin) {
        case 0:
            NSLog(@"r:255,g:255,b:255");
            r = 255.0/255;
            g = 255.0/255;
            b = 255.0/255;
            break;
        case 1:
            NSLog(@"r:128,g:128,b:128");
            r = 128.0/255;
            g = 128.0/255;
            b = 128.0/255;
            break;
        case 2:
            NSLog(@"r:64,g:64,b:64");
            r = 64.0/255;
            g = 64.0/255;
            b = 64.0/255;
            break;
        case 3:
            NSLog(@"r:0,g:0,b:0");
            r = 0.0/255;
            g = 0.0/255;
            b = 0.0/255;
            break;
        case 4:
            NSLog(@"r:190,g:129,b:69");
            r = 190.0/255;
            g = 129.0/255;
            b = 69.0/255;
            break;
        case 5:
            NSLog(@"r:128,g:57,b:0");
            r = 128.0/255;
            g = 57.0/255;
            b = 0.0/255;
            break;
        case 6:
            NSLog(@"r:128,g:0,b:0");
            r = 128.0/255;
            g = 0.0/255;
            b = 0.0/255;
            break;
        case 7:
            NSLog(@"r:255,g:0,b:0");
            r = 255.0/255;
            g = 0.0/255;
            b = 0.0/255;
            break;
        case 8:
            NSLog(@"r:255,g:128,b:0");
            r = 255.0/255;
            g = 128.0/255;
            b = 0.0/255;
            break;
        case 9:
            NSLog(@"r:255,g:191,b:0");
            r = 255.0/255;
            g = 191.0/255;
            b = 0.0/255;
            break;
        case 10:
            NSLog(@"r:168,g:224,b:0");
            r = 168.0/255;
            g = 244.0/255;
            b = 0.0/255;
            break;
        case 11:
            NSLog(@"r:108,g:191,b:0");
            r = 108.0/255;
            g = 191.0/255;
            b = 0.0/255;
            break;
        case 12:
            NSLog(@"r:0,g:140,b:0");
            r = 0.0/255;
            g = 140.0/255;
            b = 0.0/255;
            break;
        case 13:
            NSLog(@"r:8,g:182,b:203");
            r = 8.0/255;
            g = 182.0/255;
            b = 203.0/255;
            break;
        case 14:
            NSLog(@"r:0,g:149,b:255");
            r = 0.0/255;
            g = 149.0/255;
            b = 255.0/255;
            break;
        case 15:
            NSLog(@"r:0,g:26,b:102");
            r = 0.0/255;
            g = 26.0/255;
            b = 102.0/255;
            break;
        case 16:
            NSLog(@"r:60,g:0,b:102");
            r = 60.0/255;
            g = 0.0/255;
            b = 102.0/255;
            break;
        case 17:
            NSLog(@"r:117,g:0,b:140");
            r = 117.0/255;
            g = 0.0/255;
            b = 140.0/255;
            break;
        default:
            NSLog(@"r:255,g:51,b:143");
            r = 255.0/255;
            g = 51.0/255;
            b = 143.0/255;
            break;
    }
    NSLog(@"moveWidth:%f",moveWidth);
    if (_currentlyStatus.lastColorwidth >30.5) {
        _currentColorView.frame = CGRectMake(_currentlyStatus.lastColorwidth, _currentColorView.frame.origin.y, _currentColorView.frame.size.width, _currentColorView.frame.size.height);
    }else{
    _currentColorView.frame = CGRectMake(_currentColorView.frame.origin.x +moveWidth, _currentColorView.frame.origin.y, _currentColorView.frame.size.width, _currentColorView.frame.size.height);
    }
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    //state.titleColorSliderRect = [NSValue valueWithCGPoint:CGPointMake(_slider.frame.origin.x, _currentColorView.frame.origin.x)];
//    state.titleColorSliderX = _slider.frame.origin.x;
//    state.titleColorSliderY = _currentColorView.frame.origin.x;
//    NSLog(@"2222222%f,%f",state.titleColorSliderX,state.titleColorSliderY);
    _currentColor.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    _currentLabelColor.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    _panImageView.label.textColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    [UIView animateWithDuration:1.0 animations:^{
        _currentColorView.alpha = 1;
    } completion:^(BOOL finished){
    }];
    [_timer invalidate];
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                              target:self
                                            selector:@selector(disPopView)
                                            userInfo:nil repeats:NO];
}
-(void) disPopView
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         [_currentColorView setAlpha:0.f];
                     }
                     completion:^(BOOL finished){
                     }];
}

#pragma mark - 检查字幕状态

/*-(void) checkTitleState
{
    FeinnoVideoState *state = [FeinnoVideoState getFeinnoVideoInstance];
    if (state.titleBubbleTag != NULL) {
        _currentlyStatus.selectBubbleTag = [state.titleBubbleTag intValue];
    }
    if (state.titleFontTag != NULL) {
        _currentlyStatus.selectFontTag = [state.titleFontTag intValue];
    }
    if (state.titleShade != NULL) {
        _currentlyStatus.shadow = [state.titleShade intValue];
    }
    if (state.titleBold!= NULL) {
        _currentlyStatus.boldfaced = [state.titleBold intValue];
    }
    if (state.titleColorSliderX != 0) {
        _currentlyStatus.sliderX =  state.titleColorSliderX;
    }
    if (state.titleColorSliderY != 0) {
        _currentlyStatus.lastColorwidth = state.titleColorSliderY;
    }
    if (state.titleBubbleX != 0) {
        _currentlyStatus.bubbleX = state.titleBubbleX;
    }
    if (state.titleBubbleY != 0) {
        _currentlyStatus.bubbleY = state.titleBubbleY;
    }
    if (state.titleBubbleW != 0) {
        _currentlyStatus.bubbleW = state.titleBubbleW;
    }
    if (state.titleBubbleH != 0) {
        _currentlyStatus.bubbleH = state.titleBubbleH;
    }
    if (state.titleTextX != 0) {
        _currentlyStatus.textX = state.titleTextX;
    }
    if (state.titleTextY != 0) {
        _currentlyStatus.textY = state.titleTextY;
    }
    if (state.titleTextW != 0) {
        _currentlyStatus.textW = state.titleTextW;
    }
    if (state.titleTextH != 0) {
        _currentlyStatus.textH = state.titleTextH;
    }
    if (state.titleText != NULL) {
        _currentlyStatus.titleText = state.titleText;
    }
    if (state.titleRotate) {
        _currentlyStatus.rotate = state.titleRotate;
    }
}*/

@end
