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
//#import "AppLogMgr.h"
#import "StreamingViewModel.h"
#import <VideoCore/VideoCore.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource,VCSessionDelegate>
//手势
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGesture;
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


@property (strong, nonatomic) IBOutlet UITableView *classNameTable;
@property (strong, nonatomic) IBOutlet UIButton *classBtn;
@property (strong, nonatomic) IBOutlet UIButton *playBtn;
@property (strong, nonatomic) IBOutlet UIButton *traformCameraBtn;

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
    [self customTableView];
    [self initDeviceOrientation];
}

- (void)initNeedData {
    unfoldInfo = [NSMutableDictionary dictionaryWithCapacity:self.userClassInfo.count];
    
    self.backView.transform = CGAffineTransformMakeRotation(- M_PI_2);
    self.backViewWidth.constant = SCREEN_WIDTH;
    self.backViewHeight.constant = SCREEN_HEIGHT;
    self.tapGesture.numberOfTapsRequired = 1;
    self.doubleTapGesture.numberOfTapsRequired = 2;
    [self.tapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
    _beautySlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    [_beautySlider setThumbImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
}

/*************************set baidu sdk**********************/

- (void)setBaiDuSDK {
//    _pushUrl = @"rtmp://push.bcelive.com/live/ftqhgk3ch6wtwcvexu";
    StreamingViewModel* vmodel = [[StreamingViewModel alloc] initWithPushUrl:_pushUrl];
    
    [vmodel setupSession:[self cameraOrientation] delegate:self];
    [vmodel preview:_cameraView];
    [vmodel updateFrame:_cameraView];
    self.model = vmodel;

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
        [self.navigationController popViewControllerAnimated:YES];
        [self clearLog];
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
            if (self.isBacking) {
                [self.navigationController popViewControllerAnimated:YES];
                self.isBacking = NO;
            }
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
            [self alertViewSendMassageToPatriarch];

        }
        _playingDotImgView.hidden = sender.selected;
        _shotingTimeLable.hidden = sender.selected;
        sender.selected = !sender.selected;

    } else if (sender.tag == 2){//翻转摄像头
        [self.model switchCamera];
        sender.selected = !sender.selected;

    } else {//选择班级
        [self showClassInfoTable:_classNameTable.hidden];
    }

}


#pragma mark - start push
-(BOOL)startRtmp {
    [self createTimer];
//    NSString* rtmpUrl = @"rtmp://push.bcelive.com/live/ftqhgk3ch6wtwcvexu";//测试地址
    _rateLabel.hidden = NO;
    NSString *rtmpUrl = _pushUrl;
    if (!([rtmpUrl hasPrefix:@"rtmp://"] )) {
        [self toastTip:@"推流地址不合法，目前支持rtmp推流!"];
        return NO;
    }
    
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
//    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        //Update UI in UI thread here
////            [_model.model.session.previewView removeFromSuperview];
//        
////            self.model = nil;
// 
//        
//    });
    [self stopTimer];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)clearLog {
    [self stopRtmp];
    self.model = nil;
}

//- (void)rotateVC:(CGFloat)angle {
//    CGSize screenSize = [UIScreen mainScreen].bounds.size;
//    CGPoint center = CGPointMake(screenSize.width / 2, screenSize.height / 2);
//    self.navigationController.view.center = center;
//    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
//    if (angle < 0) {
//        transform = CGAffineTransformIdentity;
//    }
//    self.navigationController.view.transform = transform;
//    
//    CGRect bounds = CGRectMake(0, 0, screenSize.height , screenSize.width);
//    if (angle < 0) {
//        bounds = CGRectMake(0, 0, screenSize.width , screenSize.height);
//    }
//    
//    self.navigationController.view.bounds = bounds;
//}

- (AVCaptureVideoOrientation)cameraOrientation {
    return AVCaptureVideoOrientationLandscapeRight;
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
    [self stopRtmp];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

/***************notice**************/
//在低系统（如7.1.2）可能收不到这个回调，请在onAppDidEnterBackGround和onAppWillEnterForeground里面处理打断逻辑
- (void) onAudioSessionEvent: (NSNotification *) notification {
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
    /*
     if (_play_switch == YES && _appIsInterrupt == NO) {
     if ([self isVODType:_playType]) {
     if (!_videoPause) {
     [_txLivePlayer pause];
     }
     }
     _appIsInterrupt = YES;
     }

     */
    }else{
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
        /*
         if (_play_switch == YES && _appIsInterrupt == YES) {
         if ([self isVODType:_playType]) {
         if (!_videoPause) {
         [_txLivePlayer resume];
         }
         }
         _appIsInterrupt = NO;
         }

         */
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


//- (void)statusBarOrientationChanged:(NSNotification *)note  {
//    
//    switch ([[UIDevice currentDevice] orientation]) {
//        case UIDeviceOrientationPortrait:        //activity竖屏模式，竖屏推流
//        {
//            if (_deviceOrientation != UIDeviceOrientationPortrait) {
//               
//                _deviceOrientation = UIDeviceOrientationPortrait;
//                self.model.session.cameraOrientation = AVCaptureVideoOrientationPortrait;
//                UIView *gpuView = [self.model.session.previewView.subviews lastObject];
//                CGRect frame = gpuView.frame;
//                frame.size = self.view.frame.size;
//                gpuView.frame = frame;
//
//            }
//        }
//            break;
//        case UIDeviceOrientationLandscapeLeft:   //activity横屏模式，home在右横屏推流 注意：渲染view（demo里面是：preViewContainer）要跟着activity旋转
//        {
//            if (_deviceOrientation != UIDeviceOrientationLandscapeLeft) {
//              
//                _deviceOrientation = UIDeviceOrientationLandscapeLeft;
//                self.model.session.cameraOrientation = AVCaptureVideoOrientationLandscapeLeft;
//                UIView *gpuView = [self.model.session.previewView.subviews lastObject];
//                CGRect frame = gpuView.frame;
//                frame.size = CGSizeMake(CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame));
//                gpuView.frame = frame;
//
//            }
//            
//        }
//            break;
//        case UIDeviceOrientationLandscapeRight:   //activity横屏模式，home在左横屏推流 注意：渲染view（demo里面是：preViewContainer）要跟着activity旋转
//        {
//            if (_deviceOrientation != UIDeviceOrientationLandscapeRight) {
//                
//                _deviceOrientation = UIDeviceOrientationLandscapeRight;
//                self.model.session.cameraOrientation = AVCaptureVideoOrientationLandscapeRight;
//                UIView *gpuView = [self.model.session.previewView.subviews lastObject];
//                CGRect frame = gpuView.frame;
//                frame.size = CGSizeMake(CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame));
//                gpuView.frame = frame;
//            }
//        }
//            break;
//        default:
//            break;
//    }
//}

#pragma mark - change beauty value
- (IBAction)changeSlider:(UISlider *)sender {
    
    [self.model.session setBeatyEffect:sender.value withSmooth:sender.value withPink:sender.value];
    
}


/****************selected school and class******************/
- (void)getPushInfo {
    /*
     phone
     device
     school_id
     class_id
     push_type
     liveName
     className
     schoolName
     选填
     schoolIp
     cameraId
     schoolAdminName
     schoolAdminPhone
     adminClassName
     cameraClassLocation
     
     */
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
//            [self startRtmp];
        } else {
            
            
        }
    } failure:^(NSError *error) {
        [progressM hiddenProgress];
        [KTMErrorHint showNetError:error inView:self.view];
    }];
    
}

- (void)groupSendMassage {
   
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

- (void)alertViewSendMassageToPatriarch {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否通知学生家长观看直播？" preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self startRtmp];
        [self groupSendMassage];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self startRtmp];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


/*******************tableview*****************/

- (void)customTableView {
    _classNameTable = [[UITableView alloc] initWithFrame:CGRectMake(8, HEIGHT -  63 - 200, 120, 200) style:UITableViewStylePlain];
    _classNameTable.delegate = self;
    _classNameTable.dataSource = self;
    [_classNameTable registerNib:[UINib nibWithNibName:@"ClassNameTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    _classNameTable.hidden = YES;
    [self.backView addSubview:_classNameTable];
    
}

#pragma mark - tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.userClassInfo.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *classArray = [NSArray safeArray:[NSDictionary safeDictionary:self.userClassInfo[section]][@"classes"]];
    BOOL unfold = [unfoldInfo[[NSString stringWithFormat:@"%tu",section]] boolValue];
    
    return unfold == YES?0:classArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 28;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 28;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ClassNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    NSDictionary *classInfo = [NSDictionary safeDictionary:[NSArray safeArray:[NSDictionary safeDictionary:self.userClassInfo[indexPath.section]][@"classes"]][indexPath.row]];
    cell.classNameLabel.text = [NSString safeString:classInfo[@"className"]];
    
    return cell;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    SchoolNameView *headerView = [[SchoolNameView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 28)];
    NSDictionary *schoolInfo = [NSDictionary safeDictionary:self.userClassInfo[section]];
    headerView.schoolView.text = [NSString safeString:schoolInfo[@"schoolName"]];
    headerView.tag = section;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unFoldCell:)];
    [headerView addGestureRecognizer:tap];
    
    return headerView;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *schoolInfo = [NSDictionary safeDictionary:self.userClassInfo[indexPath.section]];
    NSDictionary *classInfo = [NSDictionary safeDictionary:[NSArray safeArray:schoolInfo[@"classes"]][indexPath.row]];
    schoolName = [NSString safeString:schoolInfo[@"schoolName"]];
    schoolId = [NSString safeNumber:schoolInfo[@"schoolId"]];
    className = [NSString safeString:classInfo[@"className"]];
    classId = [NSString safeNumber:classInfo[@"classId"]];
    _classNameLabel.text = className;
    [self showClassInfoTable:NO];
    [self getPushInfo];//get push info
    
    
}


#pragma mark - unfold or fold cell
- (void)unFoldCell:(UIGestureRecognizer *)gesture {
    NSInteger section = gesture.view.tag;
    NSString *indexStr = [NSString stringWithFormat:@"%tu",section];
    BOOL fold = ![unfoldInfo[indexStr] boolValue];
    [unfoldInfo setValue:[NSNumber numberWithBool:fold] forKey:indexStr];
    [_classNameTable reloadData];
    
}

#pragma mark - show classInfo table
- (void)showClassInfoTable:(BOOL)show {
    
    CGRect frame = _classNameTable.frame;
    if (show) {
        if (_deviceOrientation == UIDeviceOrientationPortrait ||_deviceOrientation == UIDeviceOrientationUnknown) {
            frame = CGRectMake(8, WIDTH - 55 -208, 120, 200);
        } else {
            frame = CGRectMake(8, WIDTH - 55 -128, 200, 120);

        }
     
        [_classNameTable reloadData];
    }
    _classNameTable.hidden = !show;
    
    [UIView animateWithDuration:0.01 animations:^{
        _classNameTable.frame = frame;
    }];
}

/**********************rotation btn********************/

//#pragma mark -  当手机旋转时将按钮旋转

-(void)rotation_icon:(float)n {
    [UIView animateWithDuration:0.55 animations:^{

        self.classNameTable.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        self.topContentView.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        
        self.torchButton.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        
        self.playBtn.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        self.classBtn.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        self.traformCameraBtn.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        self.beautyBtn.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        self.rateLabel.transform = CGAffineTransformMakeRotation(-n*M_PI/180.0);
        CGRect frame = _classNameTable.frame;
        if (_deviceOrientation == UIDeviceOrientationPortrait) {
            frame = CGRectMake(8, WIDTH - 55 -208, 120, 200);
        } else {
            frame = CGRectMake(8, WIDTH - 55 -128, 200, 120);

        }
        _classNameTable.frame = frame;
        

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
- (void) toastTip:(NSString*)toastInfo
{
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
- (float) heightForString:(UITextView *)textView andWidth:(float)width{
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
