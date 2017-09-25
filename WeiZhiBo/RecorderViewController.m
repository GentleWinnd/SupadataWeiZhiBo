//
//  RecorderViewController.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/21.
//  Copyright © 2017年 YH. All rights reserved.
//
#define  KEY_BOARD_M_H 162
#define  KEY_BOARD_H_H 193

#define  UPLOAD_STATE_NOTICE @"videoUploadState"

#import "HistoryRecoderViewController.h"
#import "RecorderViewController.h"
#import "RecordClassNameView.h"
#import "RecordingEndView.h"
#import "UploadingView.h"
//#import "ControlScreen.h"
#import "FileUploader.h"
#import "AppDelegate.h"
#import "UserData.h"

#import "VideoUploader.h"
#import "NotificationManager.h"
#import "DeviceInfoManager.h"


#import "NSString+Extension.h"
#import "SaveDataManager.h"
#import <CoreImage/CoreImage.h>
#import <GLKit/GLKit.h>

//视频录播
#import "WCLRecordEngine.h"
#import "WCLRecordProgressView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>


typedef NS_ENUM(NSUInteger, UploadVieoStyle) {
    VideoRecord = 0,
    VideoLocation,
};

@interface RecorderViewController ()<FileUploaderDelegate, UIGestureRecognizerDelegate>
//手势
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGesture;//缩放手势
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;//点击手势
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGesture;//双击手势

@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet GLKView *cameraView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *backViewWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cameraViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cameraViewWidth;


/*************contentView**********/

@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet UIView *maskingBtn;

/************bttomView*********/

@property (strong, nonatomic) IBOutlet UIButton *historyBtn;
@property (strong, nonatomic) IBOutlet UIButton *playBtn;
@property (strong, nonatomic) IBOutlet UIButton *traformCameraBtn;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *playBtnCenterSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *playCameragap;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;


@property (strong, nonatomic) RecordClassNameView *classView;
@property (strong, nonatomic) IBOutlet UILabel *recorderTime;
@property (strong, nonatomic) IBOutlet UILabel *recorderTitle;
@property (strong, nonatomic) IBOutlet UIImageView *redDot;


/********end******/

@property (weak, nonatomic) IBOutlet WCLRecordProgressView *progressView;
@property (strong, nonatomic) WCLRecordEngine         *recordEngine;
@property (assign, nonatomic) BOOL                    allowRecord;//允许录制
@property (assign, nonatomic) UploadVieoStyle         videoStyle;//视频的类型
@property (strong, nonatomic) UIImagePickerController *moviePicker;//视频选择器
@property (strong, nonatomic) MPMoviePlayerViewController *playerVC;


@property (strong, nonatomic) UploadingView *uploadingView;
@end

static NSString *cellID = @"cellId";

@implementation RecorderViewController {
    
    NSMutableArray *selClassArr;
    NSString *playTitle;
    CGPoint _currentPoint;
    
    NSTimer *timer;
    int seconds;
    BOOL uploading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
  
    //旋转背景容器view
    self.cameraView.transform = CGAffineTransformMakeRotation(- M_PI_2);
    [self initNeedData];
    [self setShowItem];
    
    [self createCLassNamePickerView];
    [self performSelector:@selector(showClassView) withObject:nil afterDelay:1.0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBack) name:@"enterBack" object:nil];
}

- (void)appEnterBack {//app进入后台通知
    if (uploading) {
        [NotificationManager registerLocalNotificationAlertBody:@"您有短视频正在后台上传" description:@""];
        
    }
}

- (void)showClassView {
    [self showClassInfoTable:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.recordEngine) {
        [self.recordEngine shutdown];
        [self stopTimer];
    }
   
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self readyRecorder];
  
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    pan.delegate = self;
    [self.backView addGestureRecognizer:pan];
}


- (void)readyRecorder {
    if (_recordEngine == nil) {
//        [self.recordEngine setPreView:self.cameraView];
        [self.recordEngine previewLayer].frame = self.cameraView.bounds;
        [self.cameraView.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
    }
    [self.recordEngine startUp];
}

#pragma mark - set、get方法

- (WCLRecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[WCLRecordEngine alloc] init];
        _recordEngine.delegate = self;
    }
    return _recordEngine;
}

//初始化一些配置数据
- (void)initNeedData {
    
    selClassArr = [NSMutableArray arrayWithCapacity:0];
    self.allowRecord = YES;
}

#pragma mark - 创建班级label

- (void)setShowItem {
    
    self.cameraViewWidth.constant = SCREEN_HEIGHT;
    self.cameraViewHeight.constant = SCREEN_WIDTH;
    
    self.tapGesture.numberOfTapsRequired = 1;
    self.doubleTapGesture.numberOfTapsRequired = 2;
    //    self.tapGesture.enabled = YES;
    
    //    self.classBtn.hidden = NO;
    self.playBtn.hidden = NO;
    self.traformCameraBtn.hidden = NO;
    self.backBtn.hidden = NO;
    
    [self.tapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
}

#pragma mark - action

- (IBAction)onToggleFlash:(UIButton *)sender {
    
    if (sender.tag == 11) {//闪光灯
        
    } else if (sender.tag == 12){//美颜
        sender.selected = !sender.selected;
        
    } else {//返回
        if (timer) {
            [self  alertViewMessage:@"" isUploading:NO];

        } else {
            AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            app.direction = SuportDirectionAll;
            
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];

        }
    }
}

- (IBAction)btnClickAction:(UIButton *)sender {
    if (sender.tag == 2) {//播放
        if (sender.selected) {//停止zhibo
            [self stopRecoder];
        } else {//开始直播
            [self showClassInfoTable:_classView.hidden];
        }
        
    } else if (sender.tag == 3){//翻转摄像头
        sender.selected = !sender.selected;
        if (sender.selected == YES) {
            //前置摄像头
            [self.recordEngine closeFlashLight];
            [self.recordEngine changeCameraInputDeviceisFront:YES];
        }else {
            [self.recordEngine changeCameraInputDeviceisFront:NO];
        }
    } else{//历史录制视频
    
        HistoryRecoderViewController *historyVC = [[HistoryRecoderViewController alloc] init];
        historyVC.historyRecoderArr = [self getVideoPathAtFilePath:[self.recordEngine getVideoCachePath]];
        historyVC.schoolName = self.schoolName;
        historyVC.schoolId = self.schoolId;
        historyVC.userId = self.userId;
        historyVC.userRole = self.userRole;
        
        [self.navigationController pushViewController:historyVC animated:YES];
    }
}


#pragma mark - 获取文件夹里图片filePath
- (NSMutableArray *)getVideoPathAtFilePath:(NSString *)filePath {
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //将filePath路径下的文件夹里的照片取出
    NSArray *imageNameArray = [[NSArray alloc] initWithArray:[fileManager contentsOfDirectoryAtPath:filePath error:&error]];
    NSMutableArray *imagesPathArray  = [NSMutableArray arrayWithCapacity:imageNameArray.count];
    
    for (NSString *imageName in imageNameArray) {
        [imagesPathArray addObject:[filePath stringByAppendingPathComponent:imageName]];
    }
    
    return imagesPathArray;
}

- (IBAction)onPinch:(id)sender {//缩放手势
    
}

- (IBAction)onTap:(id)sender {//单击手势
    CGPoint point = [sender locationInView:self.backView];
    CGSize size = self.view.frame.size;
    point.x /= size.width;
    point.y /= size.height;
//    CGPoint point = CGPointMake( point.y /size.height ,1-point.x/size.width );

//    NSLog(@"-----====point:%@",NSStringFromCGPoint(point));
    [_recordEngine focusAtPoint:point];
}

- (IBAction)onDoubleTap:(id)sender {//双击手势

}

#pragma mark - change beauty value
- (IBAction)changeSlider:(UISlider *)sender {//设置美颜

}

#pragma mark - 开始录制视频

- (void)startRecoder {

    if (self.recordEngine.isCapturing) {
        [self.recordEngine resumeCapture];
    } else {
        [self.recordEngine startCapture];
    }
    [self showClassInfoTable:NO];
    [self hiddenTopViewItem:NO];
    [self setBottomViewItemHidden:YES];
    [self createTimer];

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}


#pragma mark - 停止录制视频

- (void)stopRecoder {

    [self.recordEngine pauseCapture];
    if (self.recordEngine.videoPath.length>0) {
        
        [self.recordEngine stopCaptureHandler:^(UIImage *movieImage) {
            [self.redDot setHidden:YES];
            [self andEndView];
            [self stopTimer];
            self.recorderTitle.text = playTitle;
        }];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

}

#pragma mark - 设置录制状态

- (void)hiddenTopViewItem:(BOOL)hidden {
    self.redDot.hidden = hidden;
    self.recorderTime.hidden = hidden;
    self.recorderTitle.hidden = hidden;

}

- (void)setBottomViewItemHidden:(BOOL)hidden {
    self.historyBtn.hidden = hidden;
    self.playBtnCenterSpace.constant = hidden?32+23:0;
    self.playCameragap.constant = hidden?62:42;
    self.playBtn.selected = hidden;

}


#pragma mark - create timer

- (void)createTimer {
    seconds = 0;
    self.recorderTime.text = @"00:00:00";
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
    
    self.recorderTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hourse,minutes,second];
    self.redDot.hidden = !self.redDot.hidden;
    
//    double rate = [self.model.session getCurrentUploadBandwidthKbps];
//    rate = rate < 0.0?0.0:rate;
//    self.CView.rateLabel.textColor = rate >50?[UIColor whiteColor]:[UIColor redColor];
//    
//    self.CView.rateLabel.text = [NSString stringWithFormat:@"%.lf %@",rate,@"kb"];
  
    
//    if (rate == 0) {
//        noDataCount++;
//    }
    
    if (seconds/20&&seconds%20==0) {
    }
    
    if (seconds == 290 ) {
        [Progress progressShowcontent:@"亲，您快达到视频录制的时间上线5分钟了" currView:self.view];
    }
    
    if (seconds == 295) {
        [Progress progressShowcontent:@"请您尽快停止录制" currView:self.view];
    }
    
    if (seconds == 300) {
        [Progress progressShowcontent:@"您的录制总时长已经达到上线了" currView:self.view];
        [self stopRecoder];
    }
  
}

- (void)stopTimer {
    [timer invalidate];
    timer = nil;
}

#pragma mark - and end View

- (void)andEndView {

    RecordingEndView *endView = [[NSBundle mainBundle] loadNibNamed:@"RecordingEndView" owner:self options:nil].lastObject;
    endView.frame = self.view.bounds;
    [self.view addSubview:endView];
    @WeakObj(endView)
    endView.endViewBtnBlock = ^(EndViewBtnType type){
    
        if (type == EndViewBtnTypeBack) {//返回录制页面
            [self saveRecoderVideoClasses];
            
        } else if (type == EndViewBtnTypeRemove) {//删除视频
            [self removeHistoryRecoder:self.recordEngine.videoPath];
            
        } else if (type == EndViewBtnTypeUpload) {//上传视频
            [self saveRecoderVideoClasses];
            [self getUploadShortVideoPath];
            [self addUploadingView];


        }
        [endViewWeak removeFromSuperview];
        
        [self hiddenTopViewItem:YES];
        [self setBottomViewItemHidden:NO];
    };
}

#pragma mark - 上传视频

//- (void)uploadVideo:(NSString *)url  {
////    FileUploader *uploader = [FileUploader shareFileUploader];
////    uploader.delegate = self;
////    [uploader uploadFileAtPath:self.recordEngine.videoPath];
////    NSData *data = [NSData dataWithContentsOfFile:self.recordEngine.videoPath];
////    NSString *url = @"http://112.4.28.208:38080/media21";
////    NSDictionary *paramater =@{@"resourceId":@"32010020170815115026716106shxxkm",
////                               @"uploadType":@"vodFile,short1",
////                               @"prefix":@"20170815115026765"};
////    
//    
//}


- (void)fileUploadingState:(BOOL)state fileName:(NSString *)fileName{//fileuploaderdelegate function
    
    if (fileName.length>0) {//修改文件上传的额状态
        [[SaveDataManager shareSaveRecoder] saveRecoderUploadState:state withVideoId:[self getVideoIdWithVideoPath:fileName]];
    
    } else {
        [Progress progressShowcontent:@"视频保存失败了" currView:self.view];
    }
}

- (void)removeHistoryRecoder:(NSString *)recoderPath {
    NSError *error;
    NSFileManager *filerManager = [NSFileManager defaultManager];
    if ([filerManager fileExistsAtPath:recoderPath]) {
        BOOL result = [filerManager removeItemAtPath:recoderPath error:&error];
        if (result) {
            [[SaveDataManager shareSaveRecoder] removeRecoderVideoWithVideoId:recoderPath];
            NSLog(@"_______视频删除成功————————");
        } else {
            [Progress progressShowcontent:@"删除失败了" currView:self.view];
        }
    }
}

- (void)saveRecoderVideoClasses {
    NSString *videoPath = self.recordEngine.videoPath;
    if (videoPath.length>0) {
        NSString *videoTag = [self getVideoIdWithVideoPath:videoPath];
        [[SaveDataManager shareSaveRecoder] saveRecoderVodeoClass:selClassArr withVideoId:videoTag];
        [[SaveDataManager shareSaveRecoder] saveRecoderTitle:playTitle withVideoId:videoTag];
        [[SaveDataManager shareSaveRecoder] saveRecoderTimeDate:[NSString stringFromCompleteDate:[NSDate date]] withVideoId:videoTag];
        [[SaveDataManager shareSaveRecoder] saveRecoderTimeLength:[NSNumber numberWithInteger:seconds] withVideoId:videoTag];
    
    } else {
        [Progress progressShowcontent:@"视频保存失败了" currView:self.view];
    }
}

- (void)getUploadShortVideoPath {//获取视频的上传路径
    NSString *classIdStr = @"";
    NSString *videoPath = self.recordEngine.videoPath;

    for (NSDictionary *classInfo in selClassArr) {
        if (classIdStr.length == 0) {
            classIdStr = [NSString stringWithFormat:@"%@",classInfo[@"classId"]];
            
        } else {
            classIdStr = [NSString stringWithFormat:@"%@,%@",classIdStr, classInfo[@"classId"]];
        }
    }
    
    NSString *videoTag = [self getVideoIdWithVideoPath:videoPath];
    
    NSString *timeDate = [[SaveDataManager shareSaveRecoder] getRecoderTimeDateWithVideoId:videoTag];
    NSNumber *timeLegth = [[SaveDataManager shareSaveRecoder] getRecoderTimeLengthWithVideoId:videoTag];
    
    NSDictionary *videoInfo = @{VIDEO_PATH:videoPath,
                                UPLOAD_STATE:[NSNumber numberWithBool:NO]};
    
    NSDictionary *parameter = @{@"userId":[UserData getUser].userID,
                                @"classIdList":classIdStr,
                                @"schoolId":self.schoolId,
                                @"vodName":playTitle,
                                @"vodDesc":@"录播小视频",
                                @"timeLength":timeLegth,
                                @"screenTime":timeDate};
    
    [[VideoUploader shareUploader] getUploadShortVideoUrlWithParamater:parameter withVideoInfo:videoInfo];
    
        [VideoUploader shareUploader].uploadProgress = ^ (NSProgress *progress, NSDictionary *videoInfo) {
            NSString *rateStr = [NSString stringWithFormat:@"%.0f %%",progress.fractionCompleted*100];
            uploading = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                _uploadingView.ratelabel.text = rateStr;
                [_uploadingView.circlProgress drawProgress:progress.fractionCompleted];
            });
    };
        
    [VideoUploader shareUploader].uploadResult = ^ (BOOL result, NSDictionary *videoInfo){
            uploading = NO;
            if (result) {
                _uploadingView.ratelabel.text = @"100%";
                _uploadingView.uploadStateLabel.text = @"上传成功";
                [self fileUploadingState:YES fileName:videoPath];
                [self uploadVideoUploadState:videoInfo[VIDEO_ID]];
                
                if (!_uploadingView) {
                    [Progress progressShowcontent:@"上传成功"];
                }
            } else {
                _uploadingView.uploadStateLabel.text = @"上传失败";
                if (!_uploadingView) {
                    [Progress progressShowcontent:@"上传失败,请稍后在历史列表重新上传"];
                }
                
                [self fileUploadingState:result fileName:videoPath];
                [self removeUploadingView];
            }
            
            [self fileUploadingState:result fileName:videoPath];
    };
}

- (void)uploadVideoUploadState:(NSString *)videoId {//上传视频上传的状态

    NSDictionary *parameter = @{@"userId":[UserData getUser].userID,
                                @"vodId":videoId};
    [WZBNetServiceAPI getUploadVideoUpStateWithParameters:parameter success:^(id reponseObject) {
        
        if ([reponseObject[@"status"] integerValue]) {
//            [Progress progressShowcontent:@"上传成功" currView:self.view];
        } else {
        
            [Progress progressShowcontent:reponseObject[@"message"] currView:self.view];
        }
    } failure:^(NSError *error) {
        [KTMErrorHint showNetError:error inView:self.view];
    }];

}



#pragma mark - 添加上传进度view

- (void)addUploadingView {
    int minutes = seconds/60;
    int second = seconds%60;

    NSString *classNameStr = @"";
    for (NSDictionary *classInfo in selClassArr) {
        if (classNameStr.length == 0) {
            classNameStr = [NSString stringWithFormat:@"%@",classInfo[@"className"]];
            
        } else {
            classNameStr = [NSString stringWithFormat:@"%@,%@",classNameStr, classInfo[@"className"]];
        }
    }
    _uploadingView = [[NSBundle mainBundle] loadNibNamed:@"UploadingView" owner:self options:nil].lastObject;
    _uploadingView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    _uploadingView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    _uploadingView.titleLabel.text = playTitle;
    _uploadingView.nameLabel.text = [UserData getUser].nickName;
    _uploadingView.allTime.text = [NSString stringWithFormat:@"%d分%d秒",minutes,second];
    _uploadingView.classNameLabel.text = classNameStr;
    @WeakObj(_uploadingView)
    @WeakObj(self)
    _uploadingView.cancleBtnBlock = ^() {
    
        if (![_uploadingViewWeak.uploadStateLabel.text isEqualToString:@"上传成功"]) {
            [selfWeak alertViewMessage:@"关闭后视频将转到后台上传，确认关闭？" isUploading:YES];
        } else {
            [selfWeak removeUploadingView];
        }
    };
    
    [self.view addSubview:_uploadingView];
}

- (void)removeUploadingView {
    [_uploadingView removeFromSuperview];
    _uploadingView = nil;

}

/*******************create class name pickerview*****************/

- (void)createCLassNamePickerView {
    _classView = [[NSBundle mainBundle] loadNibNamed:@"RecordClassNameView" owner:self options:nil].lastObject;
    _classView.hidden = YES;
    _classView.userClassInfo = self.userClassInfo;
    _classView.userRole = self.userRole;
    _classView.proTitle = playTitle;
    @WeakObj(self)
    @WeakObj(selClassArr)
    _classView.getClassInfo = ^(BOOL success, NSArray *selClassesArr, NSString *titleStr){
        
        [selClassArrWeak removeAllObjects];
        if (success) {
            if (selClassesArr.count>0) {
                playTitle = titleStr;
                for (NSDictionary *classDic in selClassesArr) {
                    NSDictionary *classInfo = @{@"title":titleStr,
                                                @"classId":classDic[@"classId"],
                                                @"className":classDic[@"className"]};
                    [selClassArrWeak addObject:classInfo];
                }
                
                if ([selfWeak checkoutDeviceStore]) {
                    selfWeak.recorderTitle.text = titleStr;
                    [selfWeak startRecoder];
                } else {
                    [selfWeak showClassInfoTable:NO];
                }
                

            } else {
                [Progress progressShowcontent:@"请选择视频录制班级" currView:selfWeak.view];
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
            _classView.proTitle = [NSString stringWithFormat:@"%@的小视频",[UserData getUser].nickName];
            _classView.classTitleTextFeild.textColor = MAIN_LIGHT_WHITE_TEXTFEILD;
        } else {
            _classView.proTitle = playTitle;
        }
        
    } else {
        frame = CGRectMake(0, 0, 400, 0);
    }
    
    _maskingBtn.hidden = !show;
    _classView.hidden = !show;
    [self.topView setHidden:show];
    [self.bottomView setHidden:show];

    [UIView animateWithDuration:0.01 animations:^{
        _classView.frame = frame;
        _classView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    }];
}

////开关闪光灯
//- (IBAction)flashLightAction:(id)sender {
//    if (self.changeCameraBT.selected == NO) {
//        self.flashLightBT.selected = !self.flashLightBT.selected;
//        if (self.flashLightBT.selected == YES) {
//            [self.recordEngine openFlashLight];
//        }else {
//            [self.recordEngine closeFlashLight];
//        }
//    }
//}

#pragma mark - 通过videoPath获取videoID

- (NSString *)getVideoIdWithVideoPath:(NSString *)videoPath {
    
    NSString *videoName = [videoPath componentsSeparatedByString:@"/"].lastObject;
    NSString *videoTag = [videoName componentsSeparatedByString:@"."].firstObject;
    return videoTag;
}

#pragma mark - 监测手机的内存空间

- (BOOL)checkoutDeviceStore {
    BOOL satisfy = YES;
    
    NSString *sizeStr = [DeviceInfoManager freeDiskSpaceInMBS];
    CGFloat size = [[sizeStr componentsSeparatedByString:@" "].firstObject floatValue];
    
    if (size<100) {
        satisfy = NO;
        [Progress progressShowcontent:@"您的手机内存不够啦，赶紧去清理手机内存吧！" currView:self.view];

    }
    NSLog(@"----------------size == %@---------------",sizeStr);
    return satisfy;
}


- (void)playVideo {

    if (_recordEngine.videoPath.length > 0) {
        __weak typeof(self) weakSelf = self;
        [self.recordEngine stopCaptureHandler:^(UIImage *movieImage) {
            weakSelf.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:weakSelf.recordEngine.videoPath]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[weakSelf.playerVC moviePlayer]];
            [[weakSelf.playerVC moviePlayer] prepareToPlay];
            
            [weakSelf presentMoviePlayerViewControllerAnimated:weakSelf.playerVC];
            [[weakSelf.playerVC moviePlayer] play];
        }];
    }else {
        NSLog(@"请先录制视频~");
    }

}

//当点击Done按键或者播放完毕时调用此函数
- (void) playVideoFinished:(NSNotification *)theNotification {
    MPMoviePlayerController *player = [theNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [self.playerVC dismissMoviePlayerViewControllerAnimated];
    self.playerVC = nil;
}

#pragma mmark - 提示框

- (void)alertViewMessage:(NSString *)messageStr isUploading:(BOOL)uploading {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:messageStr preferredStyle:UIAlertControllerStyleAlert];
    
    //修改标题的内容，字号，颜色。使用的key值是“attributedTitle”
    NSMutableAttributedString *hogan = [[NSMutableAttributedString alloc] initWithString:messageStr];
    [hogan addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, [[hogan string] length])];
    //    [hogan addAttribute:NSForegroundColorAttributeName value:MAIN_DACK_BLUE_ALERT range:NSMakeRange(0, [[hogan string] length])];
    [alert setValue:hogan forKey:@"attributedMessage"];
    
    //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (uploading) {
            [self removeUploadingView];
        } else {
            AppDelegate * app = (AppDelegate *)[UIApplication sharedApplication].delegate;
            app.direction = SuportDirectionAll;
            
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];

        }
    }];
    [defaultAction setValue:MAIN_DACK_BLUE_ALERT forKey:@"_titleTextColor"];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
       
    
    }];
    
    [cancelAction setValue:MAIN_LIGHT_GRAY_ALERT forKey:@"_titleTextColor"];
    
    // 添加按钮
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - 改变屏幕亮度

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    _currentPoint = [[touches anyObject] locationInView:self.backView];
}

- (void)panAction:(UIPanGestureRecognizer *)sender {
    CGPoint point= [sender locationInView:self.backView];
    // 上下控制点
//    CGPoint tranPoint=[sender translationInView:self.backView];
    //播放进度
    typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
        UIPanGestureRecognizerDirectionUndefined,
        UIPanGestureRecognizerDirectionUp,
        UIPanGestureRecognizerDirectionDown,
        UIPanGestureRecognizerDirectionLeft,
        UIPanGestureRecognizerDirectionRight
    };
    
//    NSLog(@"point---------=====%@/transpoint*********===%@",NSStringFromCGPoint(point), NSStringFromCGPoint(tranPoint));
    
    static UIPanGestureRecognizerDirection direction = UIPanGestureRecognizerDirectionUndefined;
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            // 记录开始滑动位置
            if (direction == UIPanGestureRecognizerDirectionUndefined) {
                CGPoint velocity = [sender velocityInView:self.backView];
                BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
                if (isVerticalGesture) {
                    if (velocity.y > 0) {
                        direction = UIPanGestureRecognizerDirectionDown;
                    } else {
                        direction = UIPanGestureRecognizerDirectionUp;
                    }
                } else {
                    if (velocity.x > 0) {
                        direction = UIPanGestureRecognizerDirectionRight;
                    } else {
                        direction = UIPanGestureRecognizerDirectionLeft;
                    }
                }
            } break;
        }
        case UIGestureRecognizerStateChanged: {
            switch (direction) {
                case UIPanGestureRecognizerDirectionUp: {
                    float dy = point.y - _currentPoint.y;
                    int index = (int)dy;
                    if (index >0) {
                        [UIScreen mainScreen].brightness -= 0.01;
                    } else {
                        [UIScreen mainScreen].brightness += 0.01;
                    }
                    
                    break;
                }
                case UIPanGestureRecognizerDirectionDown: {
                    float dy = point.y - _currentPoint.y;
                    int index = (int)dy;
                    if (index >0) {
                        [UIScreen mainScreen].brightness -= 0.01;
                    } else {
                        [UIScreen mainScreen].brightness += 0.01;
                    }
                    break;
                }
                case UIPanGestureRecognizerDirectionLeft: {
                    //                    if(_isGes ==NO){
                    //                        NSLog(@"Left");
                    //                        _isGes =YES;
                    //                        self.progressDragging = YES;
                    //                    }
                    //                    // 手势滑动控制 快进进度
                    //                    if(tranPoint.x/SCREEN_HEIGHT +_origional <=0){
                    //                        videoSlider.value=0.0f;
                    //                    }else {
                    //                        videoSlider.value=tranPoint.x/SCREEN_HEIGHT+_origional;
                    //                    }
                    //                    currentTimeLabel.text =[NSString stringWithFormat:@"%@/",[self timeToHumanString:(long)(videoSlider.value * mDuration)]];
                    break;
                }
                case UIPanGestureRecognizerDirectionRight: {
                    //                    if(_isGes ==NO){
                    //                        NSLog(@"Right");
                    //                        _isGes = YES;
                    //                        self.progressDragging = YES;
                    //                    }
                    //                    if(tranPoint.x/SCREEN_HEIGHT +_origional <=0){
                    //                        videoSlider.value=0.0f;
                    //                    }else {
                    //                        videoSlider.value=tranPoint.x/SCREEN_HEIGHT+_origional;
                    //                    }
                    //                    currentTimeLabel.text =[NSString stringWithFormat:@"%@/",[self timeToHumanString:(long)(videoSlider.value * mDuration)]];
                    break;
                }
                default: {
                    break;
                }
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
         
            // 记录结束滑动位置
            direction = UIPanGestureRecognizerDirectionUndefined;
            //            [UIView animateWithDuration:0.5f animations:^{
            //                blightView.alpha =0.0f;
            //                voiceView.alpha=0.0f;
            //            }];
            break;
        } default:
            break;
    }
}

- (void)dealloc {
    _recordEngine = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:[_playerVC moviePlayer]];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL) shouldAutorotate {
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations {

    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    
    return UIInterfaceOrientationLandscapeLeft;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}



@end

