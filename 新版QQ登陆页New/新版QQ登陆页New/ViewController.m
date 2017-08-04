//
//  ViewController.m
//  新版QQ登陆页New
//
//  Created by admin on 2017/8/3.
//  Copyright © 2017年 xuwenbo. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height
#define kRGBColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:0.7]

@interface ViewController ()<UITextFieldDelegate>
//播放器
@property (nonatomic, strong) AVPlayer *player;
//UI控件的容器
@property (nonatomic, strong) UIView *bgView;
//头像图
@property (nonatomic, strong) UIImageView *titleImg;

@end

@implementation ViewController

#pragma mark - 懒加载AVPlayer
- (AVPlayer *)player
{
    if (!_player) {
        
        //获取本地视频文件路径
        NSString *path = [[NSBundle mainBundle]pathForResource:@"register_guide_video.mp4" ofType:nil];
        
        NSURL *url = [NSURL fileURLWithPath:path];
        
        //创建一个播放的item
        AVPlayerItem *playItem = [AVPlayerItem playerItemWithURL:url];
        
        //播放设置
        _player = [AVPlayer playerWithPlayerItem:playItem];
        //永不暂停
        _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        //设置播放器
        AVPlayerLayer *layerPlay = [AVPlayerLayer playerLayerWithPlayer:_player];
        layerPlay.frame = CGRectMake(0, 0, kScreenW, kScreenH);
    
        // 将播放器至于底层，不然UI部分会被视频遮挡
        [self.view.layer insertSublayer:layerPlay atIndex:0];
//        [self.view.layer addSublayer:layerPlay];
        
        //设置通知，视频播放结束后 从头再次播放，达到循环的效果
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playAgain) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
    }
    return _player;
}
#pragma mark - 视图即将出现的时候就播放视频，会显着比较流畅
- (void)viewWillAppear:(BOOL)animated
{
    //播放视频
    [self.player play];
    
    //注册通知，app从后台再次进入前台后继续播放视频
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoAgain) name:@"VideoAgain" object:nil];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    [self setUpLoginUI];
    
    [self createNotification];
}

- (void)setUpLoginUI
{
    //背景图片
    _bgView = [[UIView alloc] init];
    _bgView.frame = self.view.bounds;
    [self.view addSubview:_bgView];
    
    
    //代表图titleImg
    _titleImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 50, 85, 85)];
    _titleImg.layer.masksToBounds = YES;
    _titleImg.layer.cornerRadius = 42.f;
    _titleImg.image = [UIImage imageNamed:@"TitleImage"];
    [_bgView addSubview:_titleImg];
    
    //用户名
    UITextField *nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_titleImg.frame)+10, kScreenW-30, 50)];
    nameTextField.placeholder = @"手机号/邮箱";
    nameTextField.delegate = self;
    [nameTextField setValue:[UIColor whiteColor]  forKeyPath:@"_placeholderLabel.textColor"];
    nameTextField.font = [UIFont systemFontOfSize:15.f];
    nameTextField.borderStyle = UITextBorderStyleNone;
    [_bgView addSubview:nameTextField];
    
    
    UIView *nameLine = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(nameTextField.frame)+1, kScreenW-30, 1)];
    nameLine.backgroundColor = [UIColor whiteColor];
    [_bgView addSubview:nameLine];
    
    
    //密码
    UITextField *pwdTextField = [[UITextField alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(nameLine.frame)+10, kScreenW-30, 50)];
    pwdTextField.placeholder = @"密码";
    pwdTextField.delegate = self;
    [pwdTextField setValue:[UIColor whiteColor]  forKeyPath:@"_placeholderLabel.textColor"];
    pwdTextField.secureTextEntry = YES;
    pwdTextField.font = [UIFont systemFontOfSize:15.0f];
    pwdTextField.borderStyle = UITextBorderStyleNone;
    [_bgView addSubview:pwdTextField];
    
    
    UIView *pwdLine = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(pwdTextField.frame)+1, kScreenW-30, 1)];
    pwdLine.backgroundColor = [UIColor whiteColor];
    [_bgView addSubview:pwdLine];
    
    
    //登陆按钮
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(15, CGRectGetMaxY(pwdLine.frame)+15, kScreenW-30, 40);
    loginBtn.layer.cornerRadius = 5;
    
    loginBtn.backgroundColor = kRGBColor(24, 154, 204);

    [loginBtn setTitle:@"登  录" forState:UIControlStateNormal];
    
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [loginBtn addTarget:self action:@selector(loginBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [_bgView addSubview:loginBtn];

}

#pragma mark - 视频播放结束 触发
- (void)playAgain
{
    // 重头再来 seekToTime跳转到相应的时间播放
    [self.player seekToTime:kCMTimeZero];
}

#pragma mark - 登陆按钮回调
- (void)loginBtnClick
{
    [self.view endEditing:YES];
}

#pragma mark - 点击屏幕收键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self.view endEditing:YES];
}

#pragma mark - 输入框代理事件
-(void)createNotification{
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //编辑时，上移+时间延迟
   [UIView animateWithDuration:0.3 animations:^{
       _titleImg.transform=CGAffineTransformMakeScale(0.7, 0.7);
       _bgView.frame = CGRectMake(0, -30, kScreenW, kScreenH+30);
   }];
    
}

-(void)keyboardHide:(NSNotification*)notification{
    //键盘收起时，恢复+时间延迟
    [UIView animateWithDuration:0.3 animations:^{
        _titleImg.transform=CGAffineTransformMakeScale(1.0, 1.0);
        _bgView.frame = CGRectMake(0, 0, kScreenW, kScreenH);

    }];
    
}

#pragma mark - 程序进入后台，再次进入前台的时候，继续播放视频
- (void)videoAgain
{
    [self.player play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
