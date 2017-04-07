//
//  ViewController.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/21.
//  Copyright © 2017年 YH. All rights reserved.
//
#define  HEIGHT CGRectGetHeight(self.view.frame)
#define  WIDTH CGRectGetWidth(self.view.frame)

#import "ViewController.h"
#import "ClassNameTableViewCell.h"
#import "SchoolNameView.h"
#import "NSString+Extension.h"
#include "AFNetworkReachabilityManager.h"
#import "AppLogMgr.h"

#import <sys/types.h>
#import <sys/sysctl.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import "StreamingViewModel.h"
#import <VideoCore/VideoCore.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()<VCSessionDelegate>
//手势
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGesture;//缩放手势
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;//点击手势
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGesture;//双击手势

@property (assign, nonatomic) BOOL isBacking;
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UISlider *beautySlider;

@property (strong, nonatomic) IBOutlet UILabel *logPlayId;

@property (strong, nonatomic) IBOutlet UIButton *beautyBtn;

@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) IBOutlet UIImageView *backImageView;

@property (strong, nonatomic) IBOutlet UIButton *torchButton;//闪光灯
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backViewWidth;
@property (strong, nonatomic) IBOutlet UILabel *rateLabel;


/************bttomView*********/
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewSpace;
@property (strong, nonatomic) IBOutlet UIButton *unfoldBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) IBOutlet UIView *classBackView;
@property (strong, nonatomic) IBOutlet UIButton *classBtn;
@property (strong, nonatomic) IBOutlet UIButton *playBtn;
@property (strong, nonatomic) IBOutlet UIButton *traformCameraBtn;

@property (strong, nonatomic) ClassNameView *classView;
/********end******/

@property (strong, nonatomic) IBOutlet UIView *topContentView;
@property (strong, nonatomic) IBOutlet UIImageView *playingDotImgView;
@property (strong, nonatomic) IBOutlet UILabel *shotingTimeLable;
@property (strong, nonatomic) IBOutlet UILabel *classNameLabel;

@property (assign, nonatomic) BOOL publish_switch;


@end

static NSString *cellID = @"cellId";

@implementation ViewController
{
    NSString *classId;
    NSString *className;
    NSString *schoolId;
    NSString *schoolName;
    NSString *cameraDataId;
    CGFloat currentRotation;
    NSMutableDictionary *unfoldInfo;
    UIDeviceOrientation _deviceOrientation;
    CMMotionManager *motionManager;

    NSTimer *timer;
    int seconds;
    BOOL isTengXun;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initNeedData];
    [self setBaiDuSDK];
    [self createCLassNamePickerView];
//    [self initDeviceOrientation];
}

- (void)initNeedData {
    currentRotation = 0;
    unfoldInfo = [NSMutableDictionary dictionaryWithCapacity:self.userClassInfo.count];
    
    self.logPlayId.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.backView.transform = CGAffineTransformMakeRotation(- M_PI_2);
    self.backViewWidth.constant = SCREEN_WIDTH;
    self.backViewHeight.constant = SCREEN_HEIGHT;
    self.tapGesture.numberOfTapsRequired = 1;
    self.doubleTapGesture.numberOfTapsRequired = 2;
    [self.tapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
    _beautySlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    [_beautySlider setThumbImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
    [self orientationChangedWithDeviceOrientation:UIDeviceOrientationLandscapeLeft];
}

/*************************set baidu sdk**********************/

- (void)setBaiDuSDK {
//    _pushUrl = @"rtmp://push.bcelive.com/live/ftqhgk3ch6wtwcvexu";
    StreamingViewModel* vmodel = [[StreamingViewModel alloc] initWithPushUrl:_pushUrl];
    
    [vmodel setupSession:AVCaptureVideoOrientationLandscapeRight delegate:self];
    [vmodel preview:_cameraView];
    [vmodel updateFrame:_cameraView];
    self.model = vmodel;

}
- (IBAction)unfoldBtnClick:(UIButton *)sender {//显示或收起底部按钮栏
    [self showBottomView];
}

#pragma mark - action

- (IBAction)onToggleFlash:(UIButton *)sender {
    if (sender.tag == 11) {//闪光灯
        BOOL toggle = [self.model toggleTorch];
        if (toggle) {
            [self.torchButton setBackgroundImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
        } else {
            [self.torchButton setBackgroundImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
        }

    } else if (sender.tag == 12){//美颜
        sender.selected = !sender.selected;
        _beautySlider.hidden = !sender.selected;
        
    } else {//返回
        [self clearLog];

        [self.navigationController popViewControllerAnimated:NO];
    }
}


- (IBAction)onPinch:(id)sender {//缩放手势
    [self.model pinch:self.pinchGesture.scale state:self.pinchGesture.state];
}

- (IBAction)onTap:(id)sender {//单击手势
    CGPoint point = [self.tapGesture locationInView:self.view];
    point.x /= self.view.frame.size.width;
    point.y /= self.view.frame.size.height;
    [self.model setInterestPoint:point];
}

- (IBAction)onDoubleTap:(id)sender {//双击手势
    [self.model zoomIn];
}

#pragma mark - VCSessionDelegate

- (void) connectionStatusChanged: (VCSessionState) sessionState {
    switch(sessionState) {
        case VCSessionStatePreviewStarted:
            break;
        case VCSessionStateStarting:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
            NSLog(@"Current state is VCSessionStateStarting\n");
            break;
        case VCSessionStateStarted:
            NSLog(@"Current state is VCSessionStateStarted\n");
            [self.playBtn setBackgroundImage:[UIImage imageNamed:@"streaming"] forState:UIControlStateNormal];
            break;
        case VCSessionStateError:
            NSLog(@"Current state is VCSessionStateError\n");
            [self.playBtn setBackgroundImage:[UIImage imageNamed:@"stream_background"] forState:UIControlStateNormal];
            break;
        case VCSessionStateEnded:
            NSLog(@"Current state is VCSessionStateEnded\n");
            [self.playBtn setBackgroundImage:[UIImage imageNamed:@"stream_background"] forState:UIControlStateNormal];
//            if (self.isBacking) {
//                [self.navigationController popViewControllerAnimated:YES];
//                self.isBacking = NO;
//            }
            break;
        default:
            break;
    }
}

- (IBAction)btnClickAction:(UIButton *)sender {
    if (sender.tag == 1) {//播放
        if (sender.selected) {//停止zhibo
            [self stopRtmp];

        } else {//开始直播
            if (!([_pushUrl hasPrefix:@"rtmp://"] )) {
                [self toastTip:@"请选择班级"];
                return;
            }

            [self alertViewSendMassageToPatriarch];

        }
        _playingDotImgView.hidden = sender.selected;
        _shotingTimeLable.hidden = sender.selected;
        sender.selected = !sender.selected;

    } else if (sender.tag == 2){//翻转摄像头
        [self.model switchCamera];
        sender.selected = !sender.selected;

    } else {//选择班级
        self.classBackView.backgroundColor = _classView.hidden?MainColor_White:MainBtnSelectedColor_lightBlue;
        [self showClassInfoTable:_classView.hidden];
    }

}


#pragma mark - start push
-(BOOL)startRtmp {
//    NSString* rtmpUrl = @"rtmp://push.bcelive.com/live/ftqhgk3ch6wtwcvexu";//测试地址
    [self createTimer];

    _rateLabel.hidden = NO;
    NSString *rtmpUrl = _pushUrl;
    //是否有摄像头权限
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusVideo == AVAuthorizationStatusDenied) {
        [self toastTip:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限"];
        return NO;
    }
    
    //是否有麦克风权限
    AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (statusAudio == AVAuthorizationStatusDenied) {
        [self toastTip:@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限"];
        return NO;
    }
    
    
    [self.model.session startRtmpSessionWithURL:rtmpUrl];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
  
    self.isBacking = NO;

    return YES;
}

- (void)stopRtmp {
    self.isBacking = YES;
    BOOL result = [self.model back];
    [self stopTimer];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)clearLog {
    [self stopRtmp];
    self.model = nil;
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*******************deal push****************/
- (void)checkoutNet {
    
    BOOL isWifi = [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
    if (!isWifi) {
        __weak typeof(self) weakSelf = self;
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (_pushUrl.length == 0) {
                return;
            }
            if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                               message:@"您要切换到WiFi再推流吗?"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                    [weakSelf stopRtmp];
                    [weakSelf startRtmp];
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }]];
                [weakSelf presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
    
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
    
    _shotingTimeLable.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hourse,minutes,second];
    double rate = [self.model.session getCurrentUploadBandwidthKbps];
    _rateLabel.text = [NSString stringWithFormat:@"%.lf %@",rate,@"kb"];
    if (seconds == 38) {
        [self uploadZhiBoState:NO];
    }
    _playingDotImgView.hidden = !_playingDotImgView.hidden;
}

- (void)stopTimer {
    [self uploadZhiBoState:YES];
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
    [self stopRtmp];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
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
/*
 if (_play_switch == YES) {
 if ([self isVODType:_playType]) {
 if (!_videoPause) {
 [_txLivePlayer pause];
 }
 }
 }

 */
    
}

- (void)onAppWillEnterForeground:(UIApplication*)app {
//    if (_play_switch == YES) {
//        if ([self isVODType:_playType]) {
//            if (!_videoPause) {
//                [_txLivePlayer resume];
//            }
//        }
//    }
}

- (void)onAppDidBecomeActive:(UIApplication*)app {
//    if (_play_switch == YES && _appIsInterrupt == YES) {
//        if ([self isVODType:_playType]) {
//            if (!_videoPause) {
//                [_txLivePlayer resume];
//            }
//        }
//        _appIsInterrupt = NO;
//    }
}


#pragma mark - change beauty value
- (IBAction)changeSlider:(UISlider *)sender {
    
    [self.model.session setBeatyEffect:sender.value withSmooth:sender.value withPink:sender.value];
    
}

#pragma Mark - net service

/****************selected school and class******************/

- (void)getPushInfo {
   
    if (schoolId == nil) {
        [Progress progressShowcontent:@"请选择学校"];
        return;
    } else if (classId == nil) {
        [Progress progressShowcontent:@"请选择班级"];
        return;
    }
    
    if (className.length == 0) {
        className = @"";
    }
    
    if (schoolName.length == 0) {
        schoolName = @"";
    }
    
    NSDictionary *parameter = @{@"userId":_phoneNUM,@"device":@"2",
                                @"school_id":schoolId,@"class_id":classId,
                                @"push_type":@"2",@"liveName":@"IOS",
                                @"className":className,@"schoolName":schoolName,
                                @"schoolIp":@"",@"cameraId":@"",
                                @"schoolAdminName":@"",@"schoolAdminPhone":@"",
                                @"adminClassName":@"",@"cameraClassLocation":@""};
    
    MBProgressManager *progressM = [[MBProgressManager alloc] init];
    [progressM loadingWithTitleProgress:nil];
    [WZBNetServiceAPI postRegisterPhoneMicroLiveWithParameters:parameter success:^(id reponseObject) {
        [progressM hiddenProgress];
        if ([reponseObject[@"status"] intValue] == 1) {
            _pushUrl = [NSString safeString:reponseObject[@"data"][@"cameraPushUrl"]];
            _logPlayId.text = [NSString safeString:reponseObject[@"data"][@"cameraPlayUrl"]];
            cameraDataId = [NSString safeNumber:reponseObject[@"id"]];
//            [self startRtmp];
        } else {
            
            
        }
    } failure:^(NSError *error) {
        [progressM hiddenProgress];
        [KTMErrorHint showNetError:error inView:self.view];
    }];
    
}

- (void)groupSendMassage {//发送消息通知家长
   
    NSDictionary *parameter = @{@"access_token":@"0fc010d482d83c68ae2bfdf498ff108f",
                                @"open_id":@"38fbb5cf11a22e96747eb07421056cce",
                                @"flag":@"1",
                                @"classId":@"10606073",
                                @"className":@"11111"};
    [WZBNetServiceAPI getGroupSendMassageWithParameters:parameter success:^(id reponseObject) {
        if ([reponseObject[@"status"] intValue] == 1) {
            [Progress progressShowcontent:@"已经通知家长了！！！"];
        } else {
            [Progress progressShowcontent:@"通知家长失败了！！！"];
        }
    } failure:^(NSError *error) {
         [Progress progressShowcontent:@"通知家长失败了！！！"];
    }];
    
}

#pragma mark- 上传直播状态

- (void)uploadZhiBoState:(BOOL) stop {//flag:1开始直播2关闭直播

    if (cameraDataId == nil || classId == nil) {
        return;
    }
    NSDictionary *parameter = @{@"id":cameraDataId,
                                @"flag":stop?@"2":@"1",
                                @"classId":classId};
    [WZBNetServiceAPI postZhiBoStateMessageWithParameters:parameter success:^(id reponseObject) {
        if ([reponseObject[@"state"] intValue] == 1) {
            NSLog(@"send zhibo state success!!!!!");
        } else {
            NSLog(@"send zhibo state failed!!!!!");
        }
    } failure:^(NSError *error) {
        NSLog(@"send zhibo state failed!!!!!");

    }];

}

- (void)alertViewSendMassageToPatriarch {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否通知学生家长观看直播？" preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self startRtmp];
        [self groupSendMassage];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self startRtmp];
    }]];
    alert.view.subviews.firstObject.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


/*******************create class name pickerview*****************/

- (void)createCLassNamePickerView {
    _classView = [[NSBundle mainBundle] loadNibNamed:@"ClassNameView" owner:self options:nil].lastObject;
    _classView.hidden = YES;
    _classView.userClassInfo = self.userClassInfo;
    @WeakObj(_classNameLabel)
    @WeakObj(self)
    
    _classView.getClassInfo = ^(BOOL success, NSDictionary *userInfo, NSString *schoolI, NSString *schoolN){
        if (success) {
            
            if ([[NSString safeNumber:userInfo[@"classId"]] isEqualToString:classId]) {
                return ;
            }
            classId = [NSString safeNumber:userInfo[@"classId"]];
            className = [NSString safeString:userInfo[@"className"]];
            schoolId = schoolI;
            schoolName = schoolN;
            
            if (classId.length == 0) {//ceshi
                NSDictionary *schoolInfo = [NSDictionary safeDictionary:selfWeak.userClassInfo.firstObject];
                NSDictionary *classInfo = [NSDictionary safeDictionary:[NSArray safeArray:schoolInfo[@"classes"]][0]];
                schoolName = [NSString safeString:schoolInfo[@"schoolName"]];
                schoolId = [NSString safeNumber:schoolInfo[@"schoolId"]];
                className = [NSString safeString:classInfo[@"className"]];
                classId = [NSString safeNumber:classInfo[@"classId"]];
                _classNameLabelWeak.text = classInfo[@"className"];

            } else {
            
                _classNameLabelWeak.text = userInfo[@"className"];
            }
            [selfWeak showClassInfoTable:NO];
            [selfWeak getPushInfo];//get push info

        } else {
            [selfWeak showClassInfoTable:NO];
        }
    };
    [_classView.classPickerView reloadAllComponents];
    [self.view addSubview:_classView];
}


#pragma mark - show classInfo table
- (void)showClassInfoTable:(BOOL)show {
    
    CGRect frame = _classView.frame;
    if (show) {
//        if (_deviceOrientation == UIDeviceOrientationPortrait ||_deviceOrientation == UIDeviceOrientationUnknown) {
//            frame = CGRectMake(8, WIDTH - 55 -208, 120, 200);
//        } else {
//            frame = CGRectMake(8, WIDTH - 55 -128, 200, 120);
//
//        }
        
        frame = CGRectMake(0, 0, 400, 250);
        [_classView.classPickerView reloadAllComponents];
        [_classView.classPickerView selectRow:0 inComponent:0 animated:YES];

    } else {
        frame = CGRectMake(0, 0, 400, 0);

    }
    _classView.hidden = !show;
    
    [UIView animateWithDuration:0.01 animations:^{
        _classView.frame = frame;
        _classView.center = CGPointMake(SCREEN_HEIGHT/2, SCREEN_WIDTH/2);
        
    }];
}

#pragma mark - show classInfo table
- (void)showBottomView {
    
    if (self.classView.hidden == NO) {
        [Progress progressShowcontent:@"请选择班级！！！"];
        return;
    }
    CGRect frame = self.bottomView.frame;
    
    if (frame.origin.y > SCREEN_HEIGHT - 98 ) {
//        if (_deviceOrientation == UIDeviceOrientationPortrait ||_deviceOrientation == UIDeviceOrientationUnknown) {
//            frame = CGRectMake(8, WIDTH - 55 -208, 120, 200);
//        } else {
//            frame = CGRectMake(8, WIDTH - 55 -128, 200, 120);
//            
//        }
        frame = CGRectMake(0, SCREEN_HEIGHT - 98, SCREEN_WIDTH , 98);
        
    } else {
       frame = CGRectMake(0, SCREEN_HEIGHT - 48, SCREEN_WIDTH, 48);
    }
    
    [UIView animateWithDuration:0.01 animations:^{
        _bottomView.frame = frame;
    }];
    
}




#pragma mark - 

/**********************rotation btn********************/

//#pragma mark -  当手机旋转时将按钮旋转

-(void)rotation_icon:(float)n {
    [UIView animateWithDuration:0.55 animations:^{

//        self.classView.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        self.topContentView.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        
        self.torchButton.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        
        self.playBtn.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        self.classBtn.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        self.traformCameraBtn.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        self.beautyBtn.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        self.rateLabel.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
//        CGRect frame = _classView.frame;
//        if (_deviceOrientation == UIDeviceOrientationPortrait) {
//            frame = CGRectMake(8, WIDTH - 55 -208, 120, 200);
//        } else {
//            frame = CGRectMake(8, WIDTH - 55 -128, 200, 120);
//
//        }
//        _classView.frame = frame;
        

    }];
}

#pragma mark - 初始化设备旋转监听管理

- (void)initDeviceOrientation {
    //----- SETUP DEVICE ORIENTATION CHANGE NOTIFICATION -----1
    //    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    //    [device beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
    //    NSNotificationCenter *notificatioCenter = [NSNotificationCenter defaultCenter]; //Get the notification centre for the app
    //    [notificatioCenter addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:device];
    motionManager = [[CMMotionManager alloc] init];
    if (motionManager.deviceMotionAvailable) {
        motionManager.deviceMotionUpdateInterval = 1;
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                           withHandler:^(CMDeviceMotion *data, NSError *error) {
                                               double rotation = atan2(data.gravity.x,data.gravity.y)*180/M_PI;
                                               if (rotation>135 || rotation<-135) {
                                                   [self orientationChangedWithDeviceOrientation:UIDeviceOrientationPortrait];
                                               } else if (rotation>-135 && rotation<-45) {
                                                   [self orientationChangedWithDeviceOrientation:UIDeviceOrientationLandscapeLeft];
                                               } else if (rotation>-45 && rotation<45) {
                                                   [self orientationChangedWithDeviceOrientation:UIDeviceOrientationPortraitUpsideDown];
                                               } else {
                                                   [self orientationChangedWithDeviceOrientation:UIDeviceOrientationLandscapeRight];
                                               }
                                           }];
    }

}

#pragma mark - 更具设备旋转方向设置旋转角度
- (void)orientationChangedWithDeviceOrientation:(UIDeviceOrientation ) orientation {
    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == _deviceOrientation) {
        return;
    }
    _deviceOrientation = orientation;
    switch (orientation) {
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
            [self  rotation_icon:0.0];
            break;
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            [self  rotation_icon:180.0];
            break;
        case UIDeviceOrientationLandscapeLeft:      // Device oriented horizontally, home button on the right
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];

            [self  rotation_icon:90.0*3];
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];

            [self  rotation_icon:90.0];
            break;
        default:
            break;
    }
}

/************toastTip*********/

#pragma mark - toastTip
- (void) toastTip:(NSString*)toastInfo {
    
    CGRect frameRC = [[UIScreen mainScreen] bounds];
    frameRC.origin.y = frameRC.size.height - 110;
    frameRC.size.height -= 110;
    __block UITextView * toastView = [[UITextView alloc] init];
    
    toastView.editable = NO;
    toastView.selectable = NO;
    
    frameRC.size.height = [self heightForString:toastView andWidth:frameRC.size.width];
    
    toastView.frame = frameRC;
    
    toastView.text = toastInfo;
    toastView.backgroundColor = [UIColor whiteColor];
    toastView.alpha = 0.5;
    
    [self.view addSubview:toastView];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(){
        [toastView removeFromSuperview];
        toastView = nil;
    });
}

/**
 @method 获取指定宽度width的字符串在UITextView上的高度
 @param textView 待计算的UITextView
 @param Width 限制字符串显示区域的宽度
 @result float 返回的高度
 */
- (float) heightForString:(UITextView *)textView andWidth:(float)width {
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end

/*******************classNameView****************/
#pragma mark - classNameView

@interface ClassNameView()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UIView *classInfoView;

@end


@implementation ClassNameView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self customCLassNamePickerView];
    
}

- (void)customCLassNamePickerView {
    // 显示选中框
    _classPickerView.showsSelectionIndicator=YES;
    _classPickerView.dataSource = self;
    _classPickerView.delegate = self;
    [_classPickerView reloadAllComponents];
    
}

#pragma Mark -- UIPickerViewDataSource
// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSDictionary *schoolInfo = [NSDictionary safeDictionary:self.userClassInfo.firstObject];
    return [NSArray safeArray:schoolInfo[@"classes"]].count;
}
#pragma Mark -- UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 45;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSDictionary *schoolInfo = [NSDictionary safeDictionary:self.userClassInfo.firstObject];
    NSDictionary *classInfo = [NSDictionary safeDictionary:[NSArray safeArray:schoolInfo[@"classes"]][row]];
    self.schoolName = [NSString safeString:schoolInfo[@"schoolName"]];
    self.schoolId = [NSString safeNumber:schoolInfo[@"schoolId"]];
    self.className = [NSString safeString:classInfo[@"className"]];
    self.classId = [NSString safeNumber:classInfo[@"classId"]];
    self.classInfo = [NSDictionary safeDictionary:classInfo];
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    NSDictionary *classInfo = [NSDictionary safeDictionary:[NSArray safeArray:[NSDictionary safeDictionary:self.userClassInfo.firstObject][@"classes"]][row]];
//    
//    return [NSString safeString:classInfo[@"className"]];
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 45)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 45, 400, 1)];
    line.backgroundColor = RulesLineColor_LightGray;
    [label addSubview:line];
    NSDictionary *classInfo = [NSDictionary safeDictionary:[NSArray safeArray:[NSDictionary safeDictionary:self.userClassInfo.firstObject][@"classes"]][row]];
    
    label.text = [NSString safeString:classInfo[@"className"]];
    return label;
    
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//
//    SchoolNameView *headerView = [[SchoolNameView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 28)];
//    NSDictionary *schoolInfo = [NSDictionary safeDictionary:self.userClassInfo[section]];
//    headerView.schoolView.text = [NSString safeString:schoolInfo[@"schoolName"]];
//    headerView.tag = section;
//
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unFoldCell:)];
//    [headerView addGestureRecognizer:tap];
//
//    return headerView;
//
//}


#pragma mark - selectedCLass
- (IBAction)selectedClassBtn:(UIButton *)sender {
    if (sender.tag == 1122) {//取消
        if (self.getClassInfo) {
            self.getClassInfo(NO,self.classInfo,_schoolId,_schoolName );
        }

    } else {//确定
        if (self.getClassInfo) {
            self.getClassInfo(YES,self.classInfo,_schoolId,_schoolName);
        }
    }
}

//#pragma mark - unfold or fold cell
//- (void)unFoldCell:(UIGestureRecognizer *)gesture {
//    NSInteger section = gesture.view.tag;
//    NSString *indexStr = [NSString stringWithFormat:@"%tu",section];
//    BOOL fold = ![unfoldInfo[indexStr] boolValue];
//    [unfoldInfo setValue:[NSNumber numberWithBool:fold] forKey:indexStr];
//    [_classNameTable reloadData];
//    
//}


@end
