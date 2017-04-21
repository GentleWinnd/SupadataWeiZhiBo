//
//  ViewController.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/21.
//  Copyright © 2017年 YH. All rights reserved.
//
#define  HEIGHT CGRectGetHeight(self.view.frame)
#define  WIDTH CGRectGetWidth(self.view.frame)
#define  KEY_BOARD_M_H 162
#define  KEY_BOARD_H_H 193

#import "ViewController.h"
#import "SchoolNameView.h"
#import "NSString+Extension.h"
#import "ContentView.h"
#import "AFNetworkReachabilityManager.h"

#import "AppLogMgr.h"

#import <sys/types.h>
#import <sys/sysctl.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import "StreamingViewModel.h"
#import <VideoCore/VideoCore.h>
#import <CoreMotion/CoreMotion.h>
#import "UserData.h"
#import "SocketRocket.h"
#import "CommentMessageView.h"
#import "InputView.h"
#import "DeviceDetailManager.h"


@interface ViewController ()<VCSessionDelegate, SRWebSocketDelegate, InputViewDelegate>
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

/*************contentView**********/
@property (strong, nonatomic) ContentView *CView;
@property (strong, nonatomic) IBOutlet UIView *inputView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *inputViewBottomSpace;
@property (strong, nonatomic) IBOutlet UIButton *backBtn;


/************bttomView*********/
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewSpace;
@property (strong, nonatomic) IBOutlet UIButton *unfoldBtn;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UIImageView *foldImageView;


@property (strong, nonatomic) IBOutlet UIView *classBackView;
@property (strong, nonatomic) IBOutlet UIButton *classBtn;
@property (strong, nonatomic) IBOutlet UIButton *playBtn;
@property (strong, nonatomic) IBOutlet UIButton *traformCameraBtn;

@property (strong, nonatomic) ClassNameView *classView;
/********end******/


@property (assign, nonatomic) BOOL publish_switch;


@end

static NSString *cellID = @"cellId";

@implementation ViewController
{
    NSString *classId;
    NSString *className;
    NSString *cameraDataId;
    CGFloat currentRotation;
    NSMutableDictionary *unfoldInfo;
    UIDeviceOrientation _deviceOrientation;
    CMMotionManager *motionManager;
    AFNetworkReachabilityManager *manager;
    SRWebSocket *_webSocket;
    MessageType messageType;
    NSMutableArray *messageArr;
    CGFloat keyBoardHeight;
    CGFloat textMessgeHeight;


    CommentMessageView *commentView;
    InputView *inputView;
    NSTimer *timer;
    int seconds;
    BOOL isTengXun;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_webSocket close];
    _webSocket = nil;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setBaiDuSDK];
    [self setShowItem];
    [self createContentView];
    [self createCLassNamePickerView];
    [self initNeedData];
    [self AFNReachability];
    [self createInputView];
    [self createMessageView];
    [self.view bringSubviewToFront:self.backBtn];
}


- (void)initNeedData {
    
    if (self.userClassInfo.count == 1) {
        NSDictionary *classInfo = [NSDictionary safeDictionary:[self.userClassInfo firstObject]];
        className = [NSString safeString:classInfo[@"className"]];
        classId = [NSString safeNumber:classInfo[@"classId"]];
        _CView.classLabel.text = [NSString stringWithFormat:@"%@-%@",_schoolName,className];

        [self getPushInfo];
    }
    
    textMessgeHeight = 42;
    currentRotation = 0;
    messageArr = [NSMutableArray arrayWithCapacity:0];
    unfoldInfo = [NSMutableDictionary dictionaryWithCapacity:self.userClassInfo.count];
    
}

#pragma mark - 创建班级label

- (void)setShowItem {
    
    //    self.logPlayId.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.backView.transform = CGAffineTransformMakeRotation(- M_PI_2);
    self.backViewWidth.constant = SCREEN_WIDTH;
    self.backViewHeight.constant = SCREEN_HEIGHT;
    self.tapGesture.numberOfTapsRequired = 1;
    self.doubleTapGesture.numberOfTapsRequired = 2;
    self.tapGesture.enabled = NO;
    [self.tapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
    _beautySlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    [_beautySlider setThumbImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
    [self orientationChangedWithDeviceOrientation:UIDeviceOrientationLandscapeLeft];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeContentViewPoint:) name:UIKeyboardDidChangeFrameNotification object:nil];

}

#pragma mark - 创建contentView

- (void)createContentView {
    self.CView = [[NSBundle mainBundle] loadNibNamed:@"ContentView" owner:self options:nil].lastObject;
    self.CView.frame = CGRectMake(SCREEN_WIDTH-60, 50, 120, 30);
    self.CView.transform = CGAffineTransformMakeRotation(M_PI_2);http://www.cocoachina.com/ios/20150918/13449.html
    
    [self.backView addSubview:self.CView];
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
    sender.selected = !sender.selected;
    [self showBottomView:sender.selected];
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
        if (timer) {
            [self alertViewMessage:@"正在直播，是否关闭？" alertType:AlertViewTypeQuitPlayView];

        } else {
            [self.navigationController popViewControllerAnimated:NO];
        }
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
            [self alertViewMessage:@"是否停止直播？" alertType:AlertViewTypeStopPlay];
        } else {//开始直播
            if (!([_pushUrl hasPrefix:@"rtmp://"] )) {
                [Progress progressShowcontent:@"请选择班级" currView:self.view];
                return;
            }
            [self alertViewMessage:@"是否短信告知家长？" alertType:AlertViewTypeSendParents];
        }

    } else if (sender.tag == 2){//翻转摄像头
        [self.model switchCamera];
        sender.selected = !sender.selected;

    } else {//选择班级
        sender.selected = !sender.selected;
        if (_playBtn.selected) {
            [Progress progressShowcontent:@"直播过程中不可选择班级" currView:self.view];
        } else{
            [self showClassInfoTable:_classView.hidden];

        }
    }

}


#pragma mark - start push
-(BOOL)startRtmp {
//    NSString* rtmpUrl = @"rtmp://push.bcelive.com/live/ftqhgk3ch6wtwcvexu";//测试地址
    
    [self createTimer];

    NSString *rtmpUrl = _pushUrl;
    //是否有摄像头权限
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusVideo == AVAuthorizationStatusDenied) {
        [Progress progressShowcontent:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限" currView:self.view];
        return NO;
    }
    
    //是否有麦克风权限
    AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (statusAudio == AVAuthorizationStatusDenied) {
        [Progress progressShowcontent:@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限" currView:self.view];

        return NO;
    }
    
    
    [self.model.session startRtmpSessionWithURL:rtmpUrl];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
  
    self.isBacking = NO;
    [manager startMonitoring];//开启网络监听
    [self showBottomView:NO];//隐藏侧边栏
    [self showCommentMessageView:YES];
    [self reconnectWebSocket];
    [self.CView hiddenDoingView:NO];
    _playBtn.selected = YES;
    
    return YES;
}

- (void)stopRtmp {
    self.isBacking = YES;
    BOOL result = [self.model back];
    
    [self stopTimer];
    [self closeWebSocket];//关闭socket
    [self showBottomView:YES];
    [self showCommentMessageView:NO];
    [self.CView hiddenDoingView:YES];
    _playBtn.selected = NO;
    
    [manager stopMonitoring];
    [messageArr removeAllObjects];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)clearLog {
    [self stopRtmp];
    self.model = nil;
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
    
    self.CView.shotingTimeLable.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hourse,minutes,second];
    double rate = [self.model.session getCurrentUploadBandwidthKbps];
    rate = rate < 0.0?0.0:rate;
    self.CView.rateLabel.text = [NSString stringWithFormat:@"%.lf %@",rate,@"kb"];
    if (seconds == 38) {
        [self uploadZhiBoState:NO];
    }
    self.CView.redDotImage.hidden = !self.CView.redDotImage.hidden;
//    if (seconds%5==0) {//获取观看人数
//        [self getWacthPeopleNumber];
//    }
    
    if (seconds%10 == 0 && _webSocket) {//发送心跳包
        [_webSocket sendPing:nil error:nil];
    }
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
   
    if (self.schoolId == nil || self.schoolName == nil) {
        [Progress progressShowcontent:@"请选择学校" currView:self.view];
        return;
    } else if (classId == nil || className == nil) {
        [Progress progressShowcontent:@"请选择班级" currView:self.view];
        return;
    }
    
    if (className.length == 0) {
        className = @"";
    }
    
    if (self.schoolName.length == 0) {
        self.schoolName = @"";
    }
    
    NSDictionary *parameter = @{@"userId":self.userId,@"device":@"2",
                                @"school_id":self.schoolId,@"class_id":classId,
                                @"push_type":@"2",@"liveName":@"IOS",
                                @"className":className,@"schoolName":self.schoolName,
                                @"schoolIp":@"",@"cameraId":@"",
                                @"schoolAdminName":@"",@"schoolAdminPhone":@"",
                                @"adminClassName":@"",@"cameraClassLocation":@""};
    
    MBProgressManager *progressM = [[MBProgressManager alloc] init];
    [progressM loadingWithTitleProgress:@""];
    [WZBNetServiceAPI postRegisterPhoneMicroLiveWithParameters:parameter success:^(id reponseObject) {
        [progressM hiddenProgress];
        if ([reponseObject[@"status"] intValue] == 1) {
            _pushUrl = [NSString safeString:reponseObject[@"data"][@"cameraPushUrl"]];
            _logPlayId.text = [NSString safeString:reponseObject[@"data"][@"cameraPlayUrl"]];
            cameraDataId = [NSString safeString:reponseObject[@"data"][@"id"]];
//            [self startRtmp];
        } else {
            
            
        }
    } failure:^(NSError *error) {
        [progressM hiddenProgress];
        [KTMErrorHint showNetError:error inView:self.view];
    }];
    
}

- (void)groupSendMassage {//发送消息通知家长
   
    NSDictionary *parameter = @{@"access_token":self.accessToken,
                                @"open_id":self.openId,
                                @"flag":@"2",
                                @"classId":classId,
                                @"className":className};
    [WZBNetServiceAPI getGroupSendMassageWithParameters:parameter success:^(id reponseObject) {
        if ([reponseObject[@"status"] intValue] == 1) {
            [Progress progressShowcontent:@"已经通知家长了！！！" currView:self.view];
        } else {
            [Progress progressShowcontent:@"通知家长失败了！！！" currView:self.view];
        }
    } failure:^(NSError *error) {
         [Progress progressShowcontent:@"通知家长失败了！！！" currView:self.view];
    }];
    
}

#pragma mark- 上传直播状态

- (void)uploadZhiBoState:(BOOL) stop {//flag:1开始直播2关闭直播

    if (cameraDataId == nil || classId == nil) {
        return;
    }
    NSDictionary *parameter = @{@"id":cameraDataId,
                                @"flag":stop?@"2":@"1",
                                @"classId":classId,
                                @"sumTime":stop?[NSNumber numberWithInt:seconds]:@"",
                                @"userId":self.userId};
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

- (void)getWacthPeopleNumber {
    NSDictionary *parameter = @{@"id":cameraDataId};
    [WZBNetServiceAPI getWatchingNumberWithParameters:parameter success:^(id reponseObject) {
        
        if ([reponseObject[@"status"] integerValue] == 1) {
            int WNum = [[NSString safeNumber: [NSDictionary safeDictionary:reponseObject[@"data"]][@"livePeople"]] intValue];
            self.CView.watchLabel.text = [NSString stringWithFormat:@"%d 人",WNum];
            
            int PNum = [[NSString safeNumber: [NSDictionary safeDictionary:reponseObject[@"data"]][@"givePraise"]] intValue];
            self.CView.thumbsUpLabel.text = [NSString stringWithFormat:@"%d 人",PNum];
        }
    } failure:^(NSError *error) {
        
    }];

}

/*******************create class name pickerview*****************/

- (void)createCLassNamePickerView {
    _classView = [[NSBundle mainBundle] loadNibNamed:@"ClassNameView" owner:self options:nil].lastObject;
    _classView.hidden = YES;
    _classView.userClassInfo = self.userClassInfo;
    _classView.classInfo = [NSDictionary safeDictionary:[self.userClassInfo firstObject]];
    @WeakObj(self)
    
    _classView.getClassInfo = ^(BOOL success, NSDictionary *userInfo){
        
        if (success) {
            
            if ([[NSString safeNumber:userInfo[@"classId"]] isEqualToString:classId]) {
                [selfWeak showClassInfoTable:NO];

                return ;
            }
            NSString *CId = [NSString safeNumber:userInfo[@"classId"]];
            NSString *CName = [NSString safeString:userInfo[@"className"]];
            
            if (CId.length != 0) {//ceshi
                classId = CId;
                className = CName.length == 0?@"未命名班级":CName;
                _CView.classLabel.text = [NSString stringWithFormat:@"%@-%@",_schoolName,className];
                [selfWeak showClassInfoTable:NO];
                [selfWeak getPushInfo];//get push info

            } else {
                [Progress progressShowcontent:@"此班级不存在" currView:self.view];
            }
           
        } else {
            [selfWeak showClassInfoTable:NO];
        }
    };
    [_classView.classNameTab reloadData];
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
        
        CGFloat height = 36 + WIDTH_6_ZSCALE(45)*5;
        
        frame = CGRectMake(0, 0,WIDTH_6_ZSCALE(350) , HEIGHT_6_ZSCALE(height));
        [_classView.classNameTab reloadData];

    } else {
        frame = CGRectMake(0, 0, 400, 0);

    }
    _classView.hidden = !show;
    
    [UIView animateWithDuration:0.01 animations:^{
        _classView.frame = frame;
        _classView.center = CGPointMake(SCREEN_HEIGHT/2, SCREEN_WIDTH/2);
        self.classBackView.backgroundColor = _classView.hidden?MAIN_WHITE:MAIN_LIGHTBLUE_BTN_SELECTED;

    }];
}

#pragma mark - show classInfo table
- (void)showBottomView:(BOOL) show {
    
    if (self.classView.hidden == NO) {
        [Progress progressShowcontent:@"请选择班级！！！" currView:self.view];
        return;
    }
    CGRect frame = self.bottomView.frame;
    
    if (show) {
//        if (_deviceOrientation == UIDeviceOrientationPortrait ||_deviceOrientation == UIDeviceOrientationUnknown) {
//            frame = CGRectMake(8, WIDTH - 55 -208, 120, 200);
//        } else {
//            frame = CGRectMake(8, WIDTH - 55 -128, 200, 120);
//            
//        }
        frame = CGRectMake(0, SCREEN_HEIGHT - 98, SCREEN_WIDTH , 98);
        self.foldImageView.image = [UIImage imageNamed:@"shouqi"];
    } else {
       frame = CGRectMake(0, SCREEN_HEIGHT - 48, SCREEN_WIDTH, 48);
        self.foldImageView.image = [UIImage imageNamed:@"zhankai"];
    }
    
    [UIView animateWithDuration:0.001 animations:^{
        _bottomView.frame = frame;
    }];
    
}


/****************webSocket*****************/

///--------------------------------------
#pragma mark - Actions web socket
///--------------------------------------

- (void)reconnectWebSocket {//创建webSocket
    
    _webSocket.delegate = nil;
    [_webSocket close];
    
//    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://baihongyu1234567.xicp.io/ssm/websocket"]];
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://live.sch.supadata.cn:9080/ssm/websocket"]];
    _webSocket.delegate = self;
    
    [_webSocket open];
}

- (void)closeWebSocket {//关闭webSocket
    [self sendMessage:MessageTypeClose messageString:@"WebSocket closed"];
    [_webSocket close];
    _webSocket = nil;

}

///--------------------------------------
#pragma mark - SRWebSocketDelegate
///--------------------------------------

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Websocket Connected");
//    self.title = @"Connected!";
    NSLog(@"Websocket Connected");
    [self sendMessage:MessageTypeOpen messageString:@"Websocket Connected"];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@":( Websocket Failed With Error %@", error);
    
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(nonnull NSString *)string {
    NSLog(@"Received \"%@\"", string);
//    if (messageArr.count == 0) {
//        messageArr = nil;
//        [messageArr addObject:[self dictionaryWithJsonString:string]];
//    } else {
    
//    }
    NSDictionary *messageInfos = [NSDictionary safeDictionary:[self dictionaryWithJsonString:string]];
    MessageSocketType type = [NSString safeNumber:messageInfos[@"flag"]].integerValue;
    if (type == MessageSocketTypeDefualtMessage) {
        [messageArr addObject:messageInfos];
        commentView.messageArray = messageArr;
        [commentView reloadMessageTable];

    } else if (type == MessageSocketTypeLivePeople) {
        int WNum = [[NSString safeNumber:messageInfos[@"livePeople"]] intValue];
        self.CView.watchLabel.text = [NSString stringWithFormat:@"%d 人",WNum];
       
    } else if (type == MessageSocketTypeThumbNumebr) {
        int PNum = [[NSString safeNumber: messageInfos[@"givePraise"]] intValue];
        self.CView.thumbsUpLabel.text = [NSString stringWithFormat:@"%d 人",PNum];

    }
    
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"WebSocket closed");
    _webSocket = nil;
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {//每次发送一次心跳包时，服务器返回的消息
    
    NSLog(@"WebSocket received pong");
}


#pragma mark - sendMessage
- (void)sendMessage:(MessageType)type messageString:(NSString *)messageStr {
    /*
     "message": {
     "type": 1,(1建立连接第一次发，2发消息，3关闭连接发)
     "userType": 1,(1老师，3家长)
     "classId": 43432,(老师必传)
     "parentId": 123,(家长必传)
     "teacherId": 321,
     "livePeopel": 321,
     "content": "fsdjkgdaga"
     "userName": "李家长",
     "userPic": "http://aservice.139jy.cn/webshare/static/ucenter/user/64066/2100.jpg",
     "videoId":
     },
     
     
     */
    if (classId == nil) {
        return;
    }
    NSString *userNickName = [NSString safeString:[UserData getUser].nickName];
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"message":@{@"type":[NSNumber numberWithInteger:type],
                                                                 @"userType":@"1",
                                                                 @"classId":classId,
                                                                 @"parentId":@"",
                                                                 @"teacherId":self.userId,
                                                                 @"livePeopel":@"",
                                                                 @"content":messageStr,
                                                                 @"userName":userNickName,
                                                                 @"userPic":@"",
                                                                 @"videoId":cameraDataId}} options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    BOOL success = [_webSocket sendString:jsonString error:nil];
}

#pragma mark- jsonString To dictionary

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark- 创建评论view

- (void)createMessageView {

    commentView = [[NSBundle mainBundle] loadNibNamed:@"CommentMessageView" owner:self options:nil].lastObject;
    commentView.messageArray = messageArr;
    commentView.hidden = YES;
    commentView.frame = CGRectMake(0, 0, 280, 0);
    @WeakObj(inputView)
    @WeakObj(self)
    commentView.sendMessage = ^(BOOL selected){
        
        inputViewWeak.hidden = NO;
        inputViewWeak.frame = CGRectMake(0, SCREEN_WIDTH, SCREEN_HEIGHT, 42);
        [inputViewWeak.textView becomeFirstResponder];

        [selfWeak changeOration];
        [selfWeak addKeyBoardBackView];

    };
    [self.view insertSubview:commentView belowSubview:inputView];
}

- (void)showCommentMessageView:(BOOL)show {
    _backBtn.hidden = show;
    [UIView animateWithDuration:0.1 animations:^{
        commentView.frame = CGRectMake(0, 0, HEIGHT_6_ZSCALE(222), SCREEN_WIDTH);
        commentView.hidden = !show;
    }];

}

- (void)changeOration {
    NSInteger windowCount = [[[UIApplication sharedApplication] windows] count];
    if (windowCount < 2) {
        return;
    }
    
    UIWindow *keyboardWindow = [[[UIApplication sharedApplication] windows]  lastObject];
    UIWindow *textWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:windowCount-2];
//    CGPoint point = keyboardWindow.frame.origin;
    keyboardWindow.transform = CGAffineTransformMakeRotation(M_PI_2);
    keyboardWindow.bounds = CGRectMake(0,0,SCREEN_HEIGHT, SCREEN_WIDTH);
    
    textWindow.transform = CGAffineTransformMakeRotation(M_PI_2);
    textWindow.bounds = CGRectMake(0, 0,SCREEN_HEIGHT, SCREEN_WIDTH);
 
}


- (void) changeContentViewPoint:(NSNotification *)notification {// 根据键盘状态，调整_mainView的位置
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndX = value.CGRectValue.size.width;
    if (keyBoardEndX>200) {
        return;
    }
    
    NSString *device = [DeviceDetailManager getSystemDeviceModel];
    if ([device isEqualToString:@"iPad"]) {
//        [self changeOration];
    }
    CGRect frame = CGRectMake(0,SCREEN_WIDTH-keyBoardEndX-textMessgeHeight, SCREEN_HEIGHT, textMessgeHeight);
    inputView.frame = frame;
    keyBoardHeight = keyBoardEndX;
    
    [UIView animateWithDuration:0.01  animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        inputView.frame = frame;
    }];

    // 添加移动动画，使视图跟随键盘移动
}

/***************评论输入框***************/
#pragma mark - 创建输入评论的消息

- (void)createInputView {
    inputView = [[NSBundle mainBundle] loadNibNamed:@"InputView" owner:self options:nil].lastObject;
    inputView.frame = CGRectMake(0, 0, SCREEN_HEIGHT, 42);
    inputView.hidden = YES;
    inputView.delegate = self;
    @WeakObj(self)
    @WeakObj(inputView)
    inputView.sendMessage = ^(NSString *message) {
        if (message.length>60) {
            [Progress progressShowcontent:@"发表评论内容不能超过60字"];
            return ;
        }
        [selfWeak removeBackView];
        inputViewWeak.hidden = YES;
        inputViewWeak.textView.text = @"";
        inputViewWeak.frame = CGRectMake(0, SCREEN_WIDTH, SCREEN_HEIGHT, 42);
        if (message.length<=0) {
            return ;
        }
        [selfWeak sendMessage:MessageTypeSendMessage messageString:message];
    
    };
    
    [self.view addSubview:inputView];
    
}

- (void)inputViewTextChanged:(NSInteger)lineNum {//监听textView输入
    
    CGRect frame = inputView.frame;
    NSInteger number = lineNum==0?1:lineNum;
    frame.size.height = 12+15+15*number;
    textMessgeHeight = frame.size.height;
    
    inputView.frame = CGRectMake(0, SCREEN_WIDTH-keyBoardHeight-textMessgeHeight, SCREEN_HEIGHT, textMessgeHeight);
}

#pragma mark - 添加键盘的backView

- (void)addKeyBoardBackView {
    UIView *view = [self.view viewWithTag:1234];
    if (view) {
        return;
    }
    UIView *backViewKey = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
    backViewKey.tag = 1234;
    backViewKey.backgroundColor = [UIColor clearColor];
    UIView *MView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH-keyBoardHeight, SCREEN_HEIGHT, keyBoardHeight)];
    MView.backgroundColor = [UIColor whiteColor];
    [backViewKey addSubview:MView];
    
    [self.view insertSubview:backViewKey belowSubview:inputView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeBackView)];;
    [backViewKey addGestureRecognizer:tap];

}

- (void)removeBackView {
    UIView *view = [self.view viewWithTag:1234];
    if (view == nil) {
        return;
    }
    UIView *MV = view.subviews.lastObject;
    [MV removeFromSuperview];
    [view removeFromSuperview];
    
    MV = nil;
    view = nil;
    
    [inputView.textView resignFirstResponder];
    inputView.hidden = YES;
    inputView.textView.text = @"";
    inputView.frame = CGRectMake(0, SCREEN_WIDTH, SCREEN_HEIGHT, 42);

}

- (void)alertViewMessage:(NSString *)messageStr alertType:(AlertViewType)type {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:messageStr preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (type == AlertViewTypeStopPlay) {
            [self stopRtmp];
        } else if (type == AlertViewTypeSendParents) {
            [self startRtmp];
            [self groupSendMassage];
        } else {
            [self clearLog];
            [self.navigationController popViewControllerAnimated:NO];
        }
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        if (type == AlertViewTypeSendParents) {
            [self startRtmp];
        }
        
    }]];
    alert.view.subviews.lastObject.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    [self presentViewController:alert animated:YES completion:nil];
//    [self performSelector:@selector(changeAlertVC) withObject:nil afterDelay:0.001];
}


- (void)changeAlertVC {
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    UIView *view = window.subviews.lastObject.subviews.lastObject;
    
    view.transform = CGAffineTransformMakeRotation(M_PI_2);
//    view.subviews.lastObject.transform = CGAffineTransformMakeRotation(-M_PI_2);
}

#pragma mark -

/**********************rotation btn********************/

//#pragma mark -  当手机旋转时将按钮旋转

-(void)rotation_icon:(float)n {
    [UIView animateWithDuration:0.55 animations:^{
        
        //        self.classView.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        
        self.torchButton.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        self.playBtn.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        self.classBtn.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        self.traformCameraBtn.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        self.beautyBtn.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*******************deal push****************/
//使用AFN框架来检测网络状态的改变
-(void)AFNReachability {
    //1.创建网络监听管理者
    manager = [AFNetworkReachabilityManager sharedManager];
    
    //2.监听网络状态的改变
    /*
     AFNetworkReachabilityStatusUnknown          = 未知
     AFNetworkReachabilityStatusNotReachable     = 没有网络
     AFNetworkReachabilityStatusReachableViaWWAN = 3G
     AFNetworkReachabilityStatusReachableViaWiFi = WIFI
     */
    @WeakObj(self)
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                [Progress progressShowcontent:@"当前网络不可用，请检查" currView:selfWeak.view];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G");
                [Progress progressShowcontent:@"您当前使用的是4G网络，直播时建议使用WiFi" currView:selfWeak.view];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                [Progress progressShowcontent:@"当前是在WiFi环境下，您可以放心使用" currView:selfWeak.view];
                break;
                
            default:
                break;
        }
    }];
    
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

#import "ClassNameTableViewCell.h"

@interface ClassNameView()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIView *classInfoView;

@end
static NSString *CellIdOfClass = @"cellIdOfClass";

@implementation ClassNameView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self customCLassNameTableView];
    
}

- (void)customCLassNameTableView {
    // 显示选中框
    self.classNameTab.backgroundColor = [UIColor clearColor];
    self.classNameTab.dataSource = self;
    self.classNameTab.delegate = self;
    [self.classNameTab registerNib:[UINib nibWithNibName:@"ClassNameTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdOfClass];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.userClassInfo.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return WIDTH_6_ZSCALE(45);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    ClassNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdOfClass forIndexPath:indexPath];
    NSDictionary *classInfo = [NSDictionary safeDictionary:self.userClassInfo[indexPath.row]];
    NSString *classN = [NSString safeString:classInfo[@"className"]];
    if (classN.length == 0) {
        cell.classNameLabel.text = @"未命名班级";
        
    } else {
        cell.classNameLabel.text = classN;
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *classInfo = [NSDictionary safeDictionary:self.userClassInfo[indexPath.row]];
    self.className = [NSString safeString:classInfo[@"className"]];
    self.classId = [NSString safeNumber:classInfo[@"classId"]];
    self.classInfo = [NSDictionary safeDictionary:classInfo];
    if (self.getClassInfo) {
        self.getClassInfo(YES,self.classInfo);
    }


}


#pragma mark - selectedCLass
- (IBAction)cancelBtnAction:(UIButton *)sender {
    
    if (self.getClassInfo) {
        self.getClassInfo(NO,self.classInfo);
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


