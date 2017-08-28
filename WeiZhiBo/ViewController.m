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
#import "AppDelegate.h"
#import "ClassNameView.h"


@interface ViewController ()<VCSessionDelegate, SRWebSocketDelegate, InputViewDelegate>
//手势
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGesture;//缩放手势
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;//点击手势
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGesture;//双击手势

@property (strong, nonatomic) IBOutlet UIView *backView;//承载控件的view
@property (strong, nonatomic) IBOutlet UIButton *beautyBtn;//美颜

@property (strong, nonatomic) IBOutlet UIView *cameraView;//用于专门承载预览画面
@property (strong, nonatomic) IBOutlet UIImageView *backImageView;//显示占位的image，暂时不用

@property (strong, nonatomic) IBOutlet UIButton *torchButton;//闪光灯
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backViewHeight;//用于转屏之后调整高度
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backViewWidth;//...

/*************contentView**********/
@property (strong, nonatomic) ContentView *CView;//承载录制视频时顶部的itemview

@property (strong, nonatomic) IBOutlet UIButton *backBtn;//返回按钮
@property (strong, nonatomic) IBOutlet UIView *maskingBtn;//弹出选择班级页面时的蒙版view

@property (strong, nonatomic) IBOutlet UIButton *sendCommentBtn;//发评论的按钮
@property (strong, nonatomic) IBOutlet UIButton *playCommentBtn;//显示或关闭评论的按钮

/************bttomView*********/

@property (strong, nonatomic) IBOutlet UIButton *classBtn;//选择班级按钮，现在没有用
@property (strong, nonatomic) IBOutlet UIButton *playBtn;//播放按钮
@property (strong, nonatomic) IBOutlet UIButton *traformCameraBtn;//旋转镜头按钮

@property (strong, nonatomic) ClassNameView *classView;//选择班级按钮
@property (strong, nonatomic) CommentMessageView *commentView;//右侧显示评论的view
@property (strong, nonatomic) InputView *inputView;//输入评论的view

/********end******/

@property (strong, nonatomic) UIActivityIndicatorView *iniIndicator;
@property (assign, nonatomic) BOOL publish_switch;

@end


@implementation ViewController
{
    NSString *classId;
    
    SRWebSocket *_webSocket;
    MessageType messageType;
    NSMutableArray *messageArr;
    CGFloat keyBoardHeight;
    CGFloat textMessgeHeight;
    NSString *playTitle;
    NSString *recordStr;
    NSInteger noDataCount;
    
    NSTimer *timer;
    int seconds;
    BOOL uploadFinished;
    BOOL havedSendPlayState;
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
    //设置百度直播SDK
    [self setBaiDuSDK];
}


//初始化一些配置数据
- (void)initNeedData {
    
    textMessgeHeight = 42;
    noDataCount = 0;
    requestCount = 1;
    messageArr = [NSMutableArray arrayWithCapacity:0];
    uploadFinished = NO;
    havedSendPlayState = NO;
    recordStr = @"";

}

#pragma mark - 创建班级label

- (void)setShowItem {
    
    [self.iniIndicator stopAnimating];
    self.iniIndicator.hidden = YES;
    self.sendCommentBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.playCommentBtn.transform = CGAffineTransformMakeRotation( M_PI_2);
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
    [self performSelector:@selector(startRtmp) withObject:nil afterDelay:1.0];
    
}

#pragma mark - 设置蒙版和按钮的模糊效果

- (void)setBackgroundViewAlpal:(BOOL)hidden {
    
    self.playBtn.alpha = hidden?0.5:1;
    self.backBtn.alpha = hidden?0.5:1;
    self.traformCameraBtn.alpha = hidden?0.5:1;
    self.CView.alpha = hidden?0.5:1;
    self.backBtn.hidden = hidden;
}

#pragma mark - 创建contentView

- (void)createContentView {
    self.CView = [[NSBundle mainBundle] loadNibNamed:@"ContentView" owner:self options:nil].lastObject;
    self.CView.frame = CGRectMake(4, 26, 120, 30);
    self.CView.hidden = YES;
    
    [self.view  addSubview:self.CView];
    
    self.maskingBtn = [[UIView alloc] initWithFrame:self.view.bounds];
    self.maskingBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.maskingBtn.hidden = YES;
    
    [self.view addSubview:self.maskingBtn];
}

/*************************set baidu sdk**********************/

- (void)setBaiDuSDK {
    [self.model setupSession:AVCaptureVideoOrientationLandscapeRight delegate:self];
    [self.model preview:_cameraView];
    [self.model updateFrame:_cameraView];
    
}


#pragma mark - comment
- (IBAction)playCommenAction:(UIButton *)sender {
    if (sender.tag == 123) {//显示评论
        sender.selected = !sender.selected;
        [self showCommentMessageView:sender.selected showMessage:YES];
    } else if(sender.tag == 321){//发送评论
        if (_playCommentBtn.selected) {
            [self showInputView];
        } else {
            [Progress progressShowcontent:@"打开评论才可以发表评论" currView:self.view];
        }
    } else {//显示蒙版
        //        [self showClassInfoTable:NO];
        [self.view resignFirstResponder];
    }
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
        
    } else {//返回
        if (timer) {
            [self alertViewMessage:@"正在直播，是否关闭？" alertType:AlertViewTypeQuitPlayView];
            
        } else {
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
        [self.model switchCamera];
        sender.selected = !sender.selected;
        
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

#pragma mark - change beauty value
- (IBAction)changeSlider:(UISlider *)sender {//设置美颜
    [self.model.session setBeatyEffect:sender.value withSmooth:sender.value withPink:sender.value];
    
}

#pragma mark - VCSessionDelegate

- (void) connectionStatusChanged: (VCSessionState) sessionState {
    
    switch(sessionState) {
        case VCSessionStatePreviewStarted:{// 开始出现预览画面，收到此状态回调后方可设置美颜参数
            [self.model.session setBeatyEffect:0.5 withSmooth:0.3 withPink:0.3];
            NSLog(@"*************开始出现预览画面，收到此状态回调后方可设置美颜参数^^^^^^^^\n");
            
            break;}
        case VCSessionStateStarting:{// 正在连接服务器或创建码流传输通道
            NSLog(@"Current state is VCSessionStateStarting\n");
            NSLog(@"*************正在连接服务器或创建码流传输通道^^^^^^^^\n");
            
            break;}
        case VCSessionStateStarted:{// 已经建立连接，并已经开始推流
            NSLog(@"Current state is VCSessionStateStarted\n");
                       
            break;}
        case VCSessionStateError:{// 推流sdk运行过程中出错
            NSLog(@"*************Current state is VCSessionStateError^^^^^^^^\n");
            
            break;}
        case VCSessionStateEnded:{// 推流已经结束
            NSLog(@"**************Current state is VCSessionStateEnded^^^^^^^^\n");
            
            break;}
        default:
            break;
    }
}

- (void)sendPlayState {
    [self uploadZhiBoState:NO];
}


// 当推流sdk创建CameraSource（即相机被占用）以后，该接口会被调用，参数session为VCSimpleSession的对象
- (void) didAddCameraSource:(VCSimpleSession*)session {
    
}
// 当错误发生时会被调用。
- (void) onError:(VCErrorCode)error {
    
    switch (error) {
        case VCErrorCodePrepareSessionFailed:{//准备session的过程出错
            NSLog(@"****************%@^^^^^^^^^^^^^^^^^",@"准备session的过程出错");
            
            break;
        }
        case VCErrorCodeConnectToServerFailed:{//startRtmpSession过程中连接服务器出错
            NSLog(@"****************%@^^^^^^^^^^^^^^^^^",@"startRtmpSession过程中连接服务器出错");
            
            break;
        }
        case VCErrorCodeDisconnectFromServerFailed:{//endRtmpSession过程中出错
            NSLog(@"****************%@^^^^^^^^^^^^^^^^^",@"endRtmpSession过程中出错");
            
            break;
        }
        case VCErrorCodeOpenMicFailed:{//打开MIC设备出错
            NSLog(@"****************%@^^^^^^^^^^^^^^^^^",@"打开MIC设备出错");
            
            break;
        }
        case VCErrorCodeOpenCameraFailed:{//打开相机设备出错
            NSLog(@"****************%@^^^^^^^^^^^^^^^^^",@"打开相机设备出错");
            
            break;
        }
        case VCErrorCodeUnknownStreamingError:{//推流过程中，遇到未知错误导致推流失败
            
            break;
        }
        case VCErrorCodeWeakConnection:{
            /*
             * 推流过程中，遇到弱网情况导致推流失败
             * 收到此错误后，建议提示用户当前网络不稳定，
             * 如果反复收到此错误码，建议调用endRtmpSession停止推流
             */
            NSLog(@"****************%@^^^^^^^^^^^^^^^^^",@"当前网络不稳定001，");
            
            break;
        }
        case VCErrorCodeServerNetworkError:{
            /**
             * 推流过程中，遇到服务器网络错误导致推流失败
             * 收到此错误后，建议调用endRtmpSession立即停止推流，并在服务恢复后再重新推流
             */
            NSLog(@"****************%@^^^^^^^^^^^^^^^^^",@"当前网络不稳定001，");
            
            break;
        }
        case VCErrorCodeLocalNetworkError:{
            /**
             * 推流过程中，遇到设备断网导致推流失败，
             * 收到此错误后，建议提示用户检查网络连接，然后调用endRtmpSession立即停止推流
             */
            NSLog(@"****************%@^^^^^^^^^^^^^^^^^",@"当前网络不稳定003");
            
            break;
        }
            
        default:
            break;
    }
    
    if (timer) {
        [self toastTip:@"信息异常，直播断开，请稍后重试！"];
        [self stopRtmp];
    }
    
}

#pragma mark - start push
-(BOOL)startRtmp {
    if (!([_pushUrl hasPrefix:@"rtmp://"] )) {
        [Progress progressShowcontent:@"发生意外错误了" currView:self.view];
        return NO;
    }
    NSString *rtmpUrl = _pushUrl;
    rtmpUrl = @"rtmp://apk.139jy.cn:8005/live/32010020170717170143457107myp4ec";
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
    
    return YES;
}

#pragma mark - show play items

- (void)ShowItemWhileStartPlay {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [self createTimer];
    
    _playBtn.selected = YES;
    _playCommentBtn.selected = YES;
    _sendCommentBtn.hidden = NO;
    _playCommentBtn.hidden = NO;

    [self.CView hiddenDoingView:NO];
    [self showCommentMessageView:YES showMessage:NO];
}

- (BOOL)stopRtmp {
    BOOL result = [self.model back];
    
    [self stopTimer];
    [self closeWebSocket];//关闭socket
    [self.CView hiddenDoingView:YES];
    [self showCommentMessageView:NO showMessage:NO];
    
    self.playBtn.selected = NO;
    _sendCommentBtn.hidden = YES;
    _playCommentBtn.hidden = YES;
    [messageArr removeAllObjects];
    _commentView.messageArray = messageArr;
    [_commentView reloadMessageTable];
    [messageArr removeAllObjects];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    return result;
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
    double bandwidth = [self.model.session getCurrentUploadBandwidthKbps];
    bandwidth = bandwidth < 0.0?0.0:bandwidth;
    self.CView.rateLabel.textColor = bandwidth >50?[UIColor whiteColor]:[UIColor redColor];
    
    self.CView.rateLabel.text = [NSString stringWithFormat:@"%.lf %@",bandwidth,@"kbps"];
    if (seconds/90 && seconds%90==0 && !uploadFinished) {
        [self uploadZhiBoState:NO];
    }

    self.CView.redDotImage.hidden = !self.CView.redDotImage.hidden;
    
    if (seconds%10 == 0 && _webSocket) {//发送心跳包
        [_webSocket sendPing:nil error:nil];
    }
    
    if (bandwidth == 0) {
        noDataCount++;
    }
    
    if (seconds%20==0) {
        noDataCount = 0;
    }
    
    if (noDataCount>10) {
        noDataCount = 0;
        [self stopRtmp];
        [self toastTip:seconds>30?@"信息异常，直播断开，请稍后重试！":@"创建班级直播失败，请稍后重试! "];
    }
}

- (void)stopTimer {
    if (havedSendPlayState) {
        
        [self uploadZhiBoState:YES];
    }
    
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
        [self stopRtmp];
    }
    [_webSocket close];
    _webSocket = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    [self setShowItem];
    [self initNeedData];
    [self createContentView];
    [self createCLassNamePickerView];
    [self createInputView];
    [self createMessageView];
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


#pragma Mark - net service

/****************selected school and class******************/


- (void)groupSendMassage {//发送消息通知家长
    
    NSDictionary *parameter = @{@"access_token":self.accessToken,
                                @"open_id":self.openId,
                                @"flag":@"2",
                                @"classId":classId,
                                @"className":_schoolName,
                                @"schoolId":_schoolId};
    
    [WZBNetServiceAPI getGroupSendMassageWithParameters:parameter success:^(id reponseObject) {
        if ([reponseObject[@"status"] intValue] == 1) {
            [Progress progressShowcontent:[NSString safeString:reponseObject[@"message"]] currView:self.view];
        } else {
            [Progress progressShowcontent:[NSString safeString:reponseObject[@"message"]] currView:self.view];
        }
    } failure:^(NSError *error) {
        
        [KTMErrorHint showNetError:error inView:self.view];
    }];
}

- (NSString *)getSendMessageClassId:(NSArray *)classArr {
    NSString *sendClassId = classId;
    sendClassId = @"";
    NSInteger index = 0;
    for (NSDictionary *classInfo in classArr) {
        if (index == 0) {
            sendClassId = classInfo[@"classId"];
        } else {
            sendClassId = [NSString stringWithFormat:@"%@,%@",sendClassId,classInfo[@"classId"]];
            
        }
        index++;
    }

    return sendClassId;
}

#pragma mark- 上传直播状态

- (void)uploadZhiBoState:(BOOL) stop {//flag:1开始直播2关闭直播
    
    if (_cameraDataId == nil || classId == nil) {
        return;
    }
    
    if (playTitle.length == 0) {
        playTitle = [NSString stringWithFormat:@"%@的直播",[UserData getUser].nickName];
    }
    
    NSDictionary *parameter = @{@"id":_cameraDataId,
                                @"flag":stop?@"2":@"1",
                                @"classId":classId,
                                @"userName":[UserData getUser].nickName,
                                @"schoolId":self.schoolId,
                                @"sumTime":stop?[NSNumber numberWithInt:seconds]:@"",
                                @"userId":self.userId,
                                @"liveTitle":[NSString stringWithFormat:@"%@",playTitle],
                                @"count":[NSNumber numberWithInteger:requestCount]};
    [WZBNetServiceAPI postZhiBoStateMessageWithParameters:parameter success:^(id reponseObject) {
        if ([reponseObject[@"status"] intValue] == 1) {
            uploadFinished = [[NSString safeNumber:reponseObject[@"data"][@"status"]] intValue] == 1?YES:NO;
            NSDictionary *recorderInfo = [NSDictionary safeDictionary:reponseObject[@"data"][@"record"]];
            recordStr = [NSString stringWithFormat:@"%@",recorderInfo[@"id"]];
            if (stop == NO && recordStr.length>0) {
                havedSendPlayState = YES;
                if (_webSocket == nil) {
                    [self reconnectWebSocket];
                }
            } else {
                havedSendPlayState = NO;
            }
            NSLog(@"send zhibo state success!!!!!");
        } else {
            uploadFinished = NO;
            NSLog(@"send zhibo state failed!!!!!");
        }
        
        if (stop) {
            requestCount = 1;
        } else {
            requestCount++;
        }
    } failure:^(NSError *error) {
        NSLog(@"send zhibo state failed!!!!!");
        
    }];
}


/****************webSocket*****************/

///--------------------------------------
#pragma mark - Actions web socket
///--------------------------------------

- (void)reconnectWebSocket {//创建webSocket
    _webSocket.delegate = nil;
    [_webSocket close];
    
    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://118.178.84.40:6980/ssm/websocket"]];
    //    NSArray *urlContensArr = [HOST_URL componentsSeparatedByString:@"http"];
    //    NSString *socketStr = [NSString stringWithFormat:@"ws%@websocket",urlContensArr.lastObject];
    //    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:socketStr]];
    
    _webSocket.delegate = self;
    [_webSocket open];
}

- (void)closeWebSocket {//关闭webSocket
    if (havedSendPlayState) {
        [self sendMessage:MessageTypeClose messageString:@"WebSocket closed"];
    }
    [_webSocket close];
    _webSocket = nil;
}

///--------------------------------------
#pragma mark - SRWebSocketDelegate
///--------------------------------------

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"Websocket Connected");
    //    self.title = @"Connected!";
    [self sendMessage:MessageTypeOpen messageString:@"Websocket Connected"];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@":( Websocket Failed With Error %@", error);
    
    _webSocket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessageWithString:(nonnull NSString *)string {
    NSLog(@"Received \"%@\"", string);
    
    NSDictionary *messageInfos = [NSDictionary safeDictionary:[self dictionaryWithJsonString:string]];
    MessageSocketType type = [NSString safeNumber:messageInfos[@"flag"]].integerValue;
    if (type == MessageSocketTypeDefualtMessage) {
        [messageArr addObject:messageInfos];
        _commentView.messageArray = messageArr;
        [_commentView reloadMessageTable];
        
    } else if (type == MessageSocketTypeLivePeople) {
        int WNum = [[NSString safeNumber:messageInfos[@"livePeople"]] intValue];
        self.CView.watchLabel.text = [NSString stringWithFormat:@"%d 人",WNum];
        
    } else if (type == MessageSocketTypeThumbNumebr) {
        int PNum = [[NSString safeNumber: messageInfos[@"givePraise"]] intValue];
        self.CView.thumbsUpLabel.text = [NSString stringWithFormat:@"%d 赞",PNum];
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
                                                                              @"record":recordStr,
                                                                              @"videoId":_cameraDataId}} options:NSJSONWritingPrettyPrinted error:&error];
    
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
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

/*******************create class name pickerview*****************/

#pragma mark 0- 创建classInfoVIew

- (void)createCLassNamePickerView {
    _classView = [[NSBundle mainBundle] loadNibNamed:@"ClassNameView" owner:self options:nil].lastObject;
    _classView.hidden = YES;
    _classView.classInfo = [NSDictionary safeDictionary:[self.userClassInfo firstObject]];
    _classView.userClassInfo = self.userClassInfo;
    _classView.userRole = self.userRole;
    
    @WeakObj(self)
    @WeakObj(_classView)
    _classView.getClassInfo = ^(BOOL success, NSArray *selClasssArr, NSString *title, NSString *className){
        
        if (success) {
            
            playTitle = title;
            classId = [self getSendMessageClassId:selClasssArr];
            
            if (classId != 0) {//ceshi
                selfWeak.CView.hidden = NO;
                selfWeak.CView.classLabel.text = [NSString stringWithFormat:@"%@-%@",selfWeak.schoolName,className];
                selfWeak.classView.classTitleTextFeild.textColor = MAIN_LIGHT_WHITE_TEXTFEILD;
                
                [selfWeak showClassInfoTable:NO];
                
                if (self.model.session.rtmpSessionState != VCSessionStateStarted) {
                    [selfWeak startRtmp];
                }
                
                if (_classViewWeak.sendMessageBtn.selected) {
                    [selfWeak groupSendMassage];
                }
                
                [selfWeak uploadZhiBoState:NO];
                [selfWeak ShowItemWhileStartPlay];
                
            } else {
                [Progress progressShowcontent:@"此班级不存在" currView:selfWeak.view];
            }
        } else {
            [selfWeak showClassInfoTable:NO];
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


#pragma mark- 创建评论view

- (void)createMessageView {
    
    _commentView = [[NSBundle mainBundle] loadNibNamed:@"CommentMessageView" owner:self options:nil].lastObject;
    _commentView.messageArray = messageArr;
    _commentView.hidden = YES;
    _commentView.frame = CGRectMake(0, 0, 280, 0);
    _commentView.sendMessage = ^(BOOL selected){
        
    };
    [self.view insertSubview:_commentView belowSubview:_inputView];
}

- (void)showCommentMessageView:(BOOL)show showMessage:(BOOL)showM {
    [UIView animateWithDuration:0.1 animations:^{
        _commentView.frame = CGRectMake(0, 0, WIDTH_6_ZSCALE(222), SCREEN_HEIGHT);
        _commentView.hidden = !show;
    }];
    
    if (showM) {
        if (show) {
            if (messageArr.count>0) {
                [Progress progressShowcontent:@"打开评论详情" currView:self.view];
            } else {
                [Progress progressShowcontent:@"暂无评论详情" currView:self.view];
            }
        } else {
            [Progress progressShowcontent:@"关闭评论详情" currView:self.view];
        }
    }
}

- (void) changeContentViewPoint:(NSNotification *)notification {// 根据键盘状态，调整_mainView的位置
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGFloat keyBoardEndX = value.CGRectValue.size.height;
    
    NSString *device = [DeviceDetailManager getSystemDeviceModel];
    if ([device isEqualToString:@"iPad"]) {
        //        [self changeOration];
    }
    
    CGRect frame = CGRectMake(0,SCREEN_HEIGHT-keyBoardEndX-textMessgeHeight, SCREEN_WIDTH, textMessgeHeight);
    _inputView.frame = frame;
    keyBoardHeight = keyBoardEndX;
    
    [UIView animateWithDuration:0.001  animations:^{
        [UIView setAnimationBeginsFromCurrentState:YES];
        _inputView.frame = frame;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    [self removeBackView];
    _inputView.hidden = YES;
    _inputView.frame = CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 42);
}

/***************评论输入框***************/
#pragma mark - 创建输入评论的消息

- (void)createInputView {
    _inputView = [[NSBundle mainBundle] loadNibNamed:@"InputView" owner:self options:nil].lastObject;
    _inputView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 42);
    _inputView.hidden = YES;
    _inputView.delegate = self;
    @WeakObj(self)
    @WeakObj(_inputView)
    _inputView.sendMessage = ^(NSString *message) {
        if (message.length>60) {
            [Progress progressShowcontent:@"发表评论内容不能超过60字"];
            return ;
        }
        [selfWeak removeBackView];
        _inputViewWeak.hidden = YES;
        _inputViewWeak.textView.text = @"";
        _inputViewWeak.frame = CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 42);
        _inputViewWeak.messageStr = @"";
        if (message.length<=0) {
            return ;
        }
        [selfWeak sendMessage:MessageTypeSendMessage messageString:message];
    };
    
    [self.view addSubview:_inputView];
    
}

- (void)inputViewTextChanged:(NSInteger)lineNum {//监听textView输入
    
    CGRect frame = _inputView.frame;
    NSInteger number = lineNum==0?1:lineNum;
    frame.size.height = 12+15+15*number;
    textMessgeHeight = frame.size.height;
    
    _inputView.frame = CGRectMake(0, SCREEN_HEIGHT-keyBoardHeight-textMessgeHeight, SCREEN_WIDTH, textMessgeHeight);
}

#pragma mark - showInputView

- (void)showInputView {
    
    _inputView.hidden = NO;
    _inputView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 42);
    [_inputView.textView becomeFirstResponder];
    
    [self addKeyBoardBackView];
}


#pragma mark - 添加键盘的backView

- (void)addKeyBoardBackView {
    UIView *view = [self.view viewWithTag:1234];
    if (view) {
        return;
    }
    UIView *backViewKey = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    backViewKey.tag = 1234;
    backViewKey.backgroundColor = [UIColor clearColor];
    UIView *MView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-keyBoardHeight, SCREEN_WIDTH, keyBoardHeight)];
    MView.backgroundColor = [UIColor whiteColor];
    [backViewKey addSubview:MView];
    
    [self.view insertSubview:backViewKey belowSubview:_inputView];
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
    
    [_inputView.textView resignFirstResponder];
    _inputView.hidden = YES;
    _inputView.textView.text = @"";
    _inputView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 42);
    
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
            [self stopRtmp];
        } else {
            
            if (self.model.session.rtmpSessionState == VCSessionStateStarted ||
                self.model.session.rtmpSessionState == VCSessionStateStarting) {
                [self stopRtmp];
            }
            self.model = nil;

            [_classView removeFromSuperview];
            
            dispatch_after(0.3, dispatch_get_main_queue(), ^{
                AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                app.direction = SuportDirectionAll;
                [self dismissViewControllerAnimated:YES completion:nil];

            });
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

-(BOOL)shouldAutorotate {
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    _iniIndicator.center = CGPointMake(WIDTH/2, HEIGHT/2);
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end


