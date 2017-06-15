//
//  RecorderViewController.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/21.
//  Copyright © 2017年 YH. All rights reserved.
//
#define  HEIGHT CGRectGetHeight(self.view.frame)
#define  WIDTH CGRectGetWidth(self.view.frame)
#define  KEY_BOARD_M_H 162
#define  KEY_BOARD_H_H 193

#import "RecorderViewController.h"
#import "SchoolNameView.h"
#import "NSString+Extension.h"
#import "ContentView.h"

#import "AppLogMgr.h"

#import <sys/types.h>
#import <sys/sysctl.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <CoreMotion/CoreMotion.h>
#import "UserData.h"
#import "SocketRocket.h"
#import "CommentMessageView.h"
#import "InputView.h"
#import "DeviceDetailManager.h"
#import "AppDelegate.h"
#import "CLassNameView.h"


@interface RecorderViewController ()
//手势
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGesture;//缩放手势
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;//点击手势
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGesture;//双击手势

@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *cameraView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backViewWidth;

/*************contentView**********/

@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet UIView *maskingBtn;

/************bttomView*********/

@property (strong, nonatomic) IBOutlet UIButton *historyBtn;
@property (strong, nonatomic) IBOutlet UIButton *playBtn;
@property (strong, nonatomic) IBOutlet UIButton *traformCameraBtn;

@property (strong, nonatomic) CLassNameView *classView;
/********end******/

@property (strong, nonatomic) UIActivityIndicatorView *iniIndicator;
@property (assign, nonatomic) BOOL publish_switch;


@end

static NSString *cellID = @"cellId";

@implementation RecorderViewController {
    
    NSString *classId;
    NSString *className;
    NSString *cameraDataId;
    
    UIDeviceOrientation _deviceOrientation;
    CMMotionManager *motionManager;
    MessageType messageType;
    NSMutableArray *messageArr;
    CGFloat keyBoardHeight;
    CGFloat textMessgeHeight;
    NSString *playTitle;
    NSString *recordStr;
    NSInteger noDataCount;
    
    
    NSTimer *timer;
    int seconds;
    BOOL siglePlaying;
    BOOL uploadFinished;
    BOOL havedSendPlayState;
    NSInteger liveType;
    NSInteger requestCount;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //创建camera加载菊花
    _iniIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
    _iniIndicator.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    _iniIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    //    [self.view addSubview:_iniIndicator];
    [_iniIndicator startAnimating];
    //旋转背景容器view
    self.backView.transform = CGAffineTransformMakeRotation(- M_PI_2);
}


//初始化一些配置数据
- (void)initNeedData {
    
    if (self.userClassInfo.count == 1) {
        NSDictionary *classInfo = [NSDictionary safeDictionary:[self.userClassInfo firstObject]];
        className = [NSString safeString:classInfo[@"className"]];
        classId = [NSString safeNumber:classInfo[@"classId"]];
    }
    textMessgeHeight = 42;
    noDataCount = 0;
    liveType = 1;
    requestCount = 1;
    messageArr = [NSMutableArray arrayWithCapacity:0];
    siglePlaying = NO;
    uploadFinished = NO;
    havedSendPlayState = NO;
    recordStr = @"";
}

#pragma mark - 创建班级label

- (void)setShowItem {
    
    [self.iniIndicator stopAnimating];
    self.iniIndicator.hidden = YES;
    self.playBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.traformCameraBtn.transform = CGAffineTransformMakeRotation( M_PI_2);
    //    _beautySlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    self.backViewWidth.constant = HEIGHT;
    self.backViewHeight.constant = WIDTH;
    self.tapGesture.numberOfTapsRequired = 1;
    self.doubleTapGesture.numberOfTapsRequired = 2;
    //    self.tapGesture.enabled = YES;
    
    //    self.classBtn.hidden = NO;
    self.playBtn.hidden = NO;
    self.traformCameraBtn.hidden = NO;
    self.backBtn.hidden = NO;
    
    [self.tapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeContentViewPoint:) name:UIKeyboardDidChangeFrameNotification object:nil];
    //监听当键将要退出时
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

#pragma mark - 设置蒙版和按钮的模糊效果

- (void)setBackgroundViewAlpal:(BOOL)hidden {
    
    self.playBtn.alpha = hidden?0.5:1;
    self.backBtn.alpha = hidden?0.5:1;
    self.traformCameraBtn.alpha = hidden?0.5:1;
    self.backBtn.hidden = hidden;
}


#pragma mark - comment
- (IBAction)playCommenAction:(UIButton *)sender {
    if (sender.tag == 123) {//显示评论
        sender.selected = !sender.selected;
    } else if(sender.tag == 321){//发送评论
       
    } else {//显示蒙版
        //        [self showClassInfoTable:NO];
        [self.view resignFirstResponder];
    }
}


#pragma mark - action

- (IBAction)onToggleFlash:(UIButton *)sender {
    if (sender.tag == 11) {//闪光灯
        
    } else if (sender.tag == 12){//美颜
        sender.selected = !sender.selected;
        
    } else {//返回
        if (timer) {
            [self alertViewMessage:@"正在直播，是否关闭？" alertType:AlertViewTypeQuitPlayView];
            
        } else {
            //            AppDelegate * app = [UIApplication sharedApplication].delegate;
            //            app.shouldChangeOrientation = NO;
            //
            //            [self.navigationController dismissViewControllerAnimated:YES completion:^{
            //
            //            }];
            [self alertViewMessage:@"是否关闭直播？" alertType:AlertViewTypeQuitPlayView];
            
        }
    }
}

- (IBAction)btnClickAction:(UIButton *)sender {
    if (sender.tag == 1) {//播放
        if (sender.selected) {//停止zhibo
            [self alertViewMessage:@"是否停止直播？" alertType:AlertViewTypeStopPlay];
        } else {//开始直播
            [self showClassInfoTable:_classView.hidden];
        }
        
    } else if (sender.tag == 2){//翻转摄像头
        sender.selected = !sender.selected;
        
    }
    //    else {//选择班级
    //        if (_playBtn.selected) {
    //            [Progress progressShowcontent:@"直播过程中不可选择班级" currView:self.view];
    //        } else{
    //            [self showClassInfoTable:_classView.hidden];
    //
    //        }
    //    }
    
}


- (IBAction)onPinch:(id)sender {//缩放手势

}

- (IBAction)onTap:(id)sender {//单击手势
    CGPoint point = [self.tapGesture locationInView:self.view];
    point.x /= self.view.frame.size.width;
    point.y /= self.view.frame.size.height;

}

- (IBAction)onDoubleTap:(id)sender {//双击手势

}

#pragma mark - change beauty value
- (IBAction)changeSlider:(UISlider *)sender {//设置美颜

    
}


#pragma mark - create timer
- (void)createTimer {
    seconds = 0;
    if (timer) {
        [timer fire];
        return;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(startTimer) userInfo:@"什么鬼" repeats:YES];
}

- (void)startTimer {
    seconds++;
    int minutes = seconds/60;
    int hourse = seconds/pow(60, 2);
    int second = seconds%60;
    
//    self.CView.shotingTimeLable.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hourse,minutes,second];
//    double rate = [self.model.session getCurrentUploadBandwidthKbps];
//    rate = rate < 0.0?0.0:rate;
//    self.CView.rateLabel.textColor = rate >50?[UIColor whiteColor]:[UIColor redColor];
//    
//    self.CView.rateLabel.text = [NSString stringWithFormat:@"%.lf %@",rate,@"kb"];
  
    if (siglePlaying || self.userClassInfo.count>1) {
//        self.CView.redDotImage.hidden = !self.CView.redDotImage.hidden;
    }
    
//    if (rate == 0) {
//        noDataCount++;
//    }
    
    if (seconds/20&&seconds%20==0) {
        noDataCount = 0;
    }
    if (noDataCount>10) {

        [self toastTip:@"创建班级直播失败，请稍后重试！"];
    }
}

- (void)stopTimer {
    
    
    [timer invalidate];
    timer = nil;
}

- (void)continueTimer {
    [timer setFireDate:[NSDate date]];
}

- (void)pauseTimer {
    [timer setFireDate:[NSDate distantFuture]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (timer) {

    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [self setShowItem];
    [self createCLassNamePickerView];
    [self initNeedData];
    [self showClassInfoTable:YES];
    
}


/***************notice**************/
//在低系统（如7.1.2）可能收不到这个回调，请在onAppDidEnterBackGround和onAppWillEnterForeground里面处理打断逻辑
- (void) onAudioSessionEvent: (NSNotification *) notification {
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        
    } else {
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            
        }
    }
}

- (void)onAppDidEnterBackGround:(UIApplication*)app {
    
}

- (void)onAppWillEnterForeground:(UIApplication*)app {
    
}

- (void)onAppDidBecomeActive:(UIApplication*)app {
    
}


- (NSString *)getSendMessageClassId {
    NSString *sendClassId = classId;
    if (self.userRole == UserRoleKindergartenLeader && liveType == 2) {
        sendClassId = @"";
        NSInteger index = 0;
        for (NSDictionary *classInfo in self.userClassInfo) {
            if (index == 0) {
                sendClassId = classInfo[@"classId"];
            } else {
                sendClassId = [NSString stringWithFormat:@"%@,%@",sendClassId,classInfo[@"classId"]];
                
            }
            index++;
        }
    }
    return sendClassId;
}


/*******************create class name pickerview*****************/

- (void)createCLassNamePickerView {
    _classView = [[NSBundle mainBundle] loadNibNamed:@"ClassNameView" owner:self options:nil].lastObject;
    _classView.hidden = YES;
    _classView.classInfo = [NSDictionary safeDictionary:[self.userClassInfo firstObject]];
    _classView.userClassInfo = self.userClassInfo;
    _classView.userRole = self.userRole;
    
    @WeakObj(self)
    _classView.getClassInfo = ^(BOOL success, NSDictionary *userInfo){
        
        if (success) {
            playTitle = _classView.classTitleTextFeild.text;
            
            NSString *CId = [NSString safeNumber:userInfo[@"classId"]];
            NSString *CName = [NSString safeString:userInfo[@"className"]];
            classId = CId;
            className = CName.length == 0?@"未命名班级":CName;
            
            if (CId.length != 0) {//ceshi
                selfWeak.classView.classTitleTextFeild.textColor = MAIN_LIGHT_WHITE_TEXTFEILD;
                liveType = _classView.noticeAllSchoolBtn.selected?2:1;
                
                
            } else {
                [Progress progressShowcontent:@"此班级不存在" currView:self.view];
            }
        } else {
            [selfWeak showClassInfoTable:NO];
            if (timer) {

            }
        }
    };
    [self.view addSubview:_classView];
}


#pragma mark - show classInfo table
- (void)showClassInfoTable:(BOOL)show {
    CGRect frame = _classView.frame;
    if (show) {
        frame = CGRectMake(0, 0,SCREEN_WIDTH ,SCREEN_HEIGHT);
        if (playTitle.length == 0) {
            _classView.proTitle = [NSString stringWithFormat:@"%@的直播",[UserData getUser].nickName];
            _classView.classTitleTextFeild.textColor = MAIN_LIGHT_WHITE_TEXTFEILD;
        } else {
            _classView.proTitle = playTitle;
        }
        
    } else {
        frame = CGRectMake(0, 0, 400, 0);
    }
    
    _maskingBtn.hidden = !show;
    _classView.hidden = !show;
    [self setBackgroundViewAlpal:show];
    
    [UIView animateWithDuration:0.01 animations:^{
        _classView.frame = frame;
        _classView.center = CGPointMake(WIDTH/2, HEIGHT/2);
    }];
}


- (void)alertViewMessage:(NSString *)messageStr alertType:(AlertViewType)type {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:messageStr preferredStyle:UIAlertControllerStyleAlert];
    
    //修改标题的内容，字号，颜色。使用的key值是“attributedTitle”
    NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:messageStr];
    [hogan addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, [[hogan string] length])];
    //    [hogan addAttribute:NSForegroundColorAttributeName value:MAIN_DACK_BLUE_ALERT range:NSMakeRange(0, [[hogan string] length])];
    [alert setValue:hogan forKey:@"attributedMessage"];
    
    //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (type == AlertViewTypeStopPlay) {

        } else if (type == AlertViewTypeSendParents) {
            //            [self startRtmp];
            //            [self groupSendMassage];
        } else {

            AppDelegate * app = [UIApplication sharedApplication].delegate;
            app.shouldChangeOrientation = NO;
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    [defaultAction setValue:MAIN_DACK_BLUE_ALERT forKey:@"_titleTextColor"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //        if (type == AlertViewTypeSendParents) {
        //            [self startRtmp];
        //        }
    }];
    
    [cancelAction setValue:MAIN_LIGHT_GRAY_ALERT forKey:@"_titleTextColor"];
    
    // 添加按钮
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 提示文字

- (void) toastTip:(NSString*)toastInfo {
    
    CGRect frameRC = [[UIScreen mainScreen] bounds];
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15]};
    CGRect rect = [toastInfo boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attribute
                                          context:nil];
    
    __block UILabel * toastView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width+16, 28)];
    toastView.font = [UIFont systemFontOfSize:15];
    toastView.textColor = [UIColor whiteColor];
    toastView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    toastView.text = toastInfo;
    toastView.center = CGPointMake(frameRC.size.width/2, frameRC.size.height/2);
    toastView.layer.cornerRadius = 3.0f;
    toastView.layer.masksToBounds = YES;
    toastView.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:toastView];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(){
        [toastView removeFromSuperview];
        toastView = nil;
    });
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)shouldAutorotate {
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    _iniIndicator.center = CGPointMake(WIDTH/2, HEIGHT/2);
    return UIInterfaceOrientationMaskLandscapeRight;
}


@end

