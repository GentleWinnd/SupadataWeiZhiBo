//
//  RecorderViewController.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/21.
//  Copyright © 2017年 YH. All rights reserved.
//
#define  KEY_BOARD_M_H 162
#define  KEY_BOARD_H_H 193


#import "HistoryRecoderViewController.h"
#import "RecorderViewController.h"
#import "RecordClassNameView.h"
#import "RecordingEndView.h"
#import "AppDelegate.h"
#import "UserData.h"

#import "NSString+Extension.h"
#import "SaveDataManager.h"

//视频录播
#import "WCLRecordEngine.h"
#import "WCLRecordProgressView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>


typedef NS_ENUM(NSUInteger, UploadVieoStyle) {
    VideoRecord = 0,
    VideoLocation,
};

@interface RecorderViewController ()<WCLRecordEngineDelegate>
//手势
@property (strong, nonatomic) IBOutlet UIPinchGestureRecognizer *pinchGesture;//缩放手势
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;//点击手势
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGesture;//双击手势

@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UIView *cameraView;

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


@end

static NSString *cellID = @"cellId";

@implementation RecorderViewController {
    
    NSMutableArray *selClassArr;
    NSString *playTitle;
    
    NSTimer *timer;
    int seconds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
    //旋转背景容器view
    self.backView.transform = CGAffineTransformMakeRotation(- M_PI_2);
    self.cameraView.transform = CGAffineTransformMakeRotation(- M_PI_2);

    
    [self initNeedData];
    [self setShowItem];
    
    [self createCLassNamePickerView];
    [self performSelector:@selector(showClassView) withObject:nil afterDelay:1.0];
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

}

#pragma mark - 设置record

- (void)readyRecorder {
    if (_recordEngine == nil) {
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
    self.playBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.traformCameraBtn.transform = CGAffineTransformMakeRotation( M_PI_2);
    //    _beautySlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    self.backViewWidth.constant = SCREEN_HEIGHT;
    self.backViewHeight.constant = SCREEN_WIDTH;
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
//    self.historyBtn.hidden = [self getVideoPathAtFilePath:[self.recordEngine getVideoCachePath]].count>0?NO:YES;
}

#pragma mark - 设置蒙版和按钮的模糊效果

- (void)setBackgroundViewAlpal:(BOOL)hidden {
    
    self.playBtn.alpha = hidden?0.3:1;
    self.historyBtn.alpha = hidden?0.3:1;
    self.traformCameraBtn.alpha = hidden?0.3:1;
    self.backBtn.hidden = hidden;
}

#pragma mark - action

- (IBAction)onToggleFlash:(UIButton *)sender {
    
    if (sender.tag == 11) {//闪光灯
        
    } else if (sender.tag == 12){//美颜
        sender.selected = !sender.selected;
        
    } else {//返回
        if (timer) {
            
        } else {
            
            AppDelegate * app = [UIApplication sharedApplication].delegate;
            app.shouldChangeOrientation = NO;
            
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                
            }];
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
    CGPoint point = [self.tapGesture locationInView:self.view];
    point.x /= self.view.frame.size.width;
    point.y /= self.view.frame.size.height;
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
    [self setDoingState:NO];
    [self createTimer];

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

}

#pragma mark - 停止录制视频

- (void)stopRecoder {

    [self.recordEngine pauseCapture];
    if (self.recordEngine.videoPath.length>0) {
        
        [self.recordEngine stopCaptureHandler:^(UIImage *movieImage) {
            [self setDoingState:YES];
            [self andEndView];
            [self stopTimer];
            self.recorderTitle.text = @"直播";
        }];
    }
  
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

}

#pragma mark - 设置录制状态

- (void)setDoingState:(BOOL) hidden {
    self.playBtn.selected = !hidden;
    self.redDot.hidden = hidden;
    self.recorderTime.hidden = hidden;
    self.backBtn.hidden = !hidden;

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
            
        }
        [endViewWeak removeFromSuperview];
    };
}

- (void)removeHistoryRecoder:(NSString *)recoderPath {
    NSError *error;
    NSFileManager *filerManager = [NSFileManager defaultManager];
    if ([filerManager fileExistsAtPath:recoderPath]) {
        BOOL result = [filerManager removeItemAtPath:recoderPath error:&error];
        if (result) {
            NSLog(@"_______视频删除成功————————");
            [[SaveDataManager shareSaveRecoder] removeRecoderVideoWithVideoId:@""];
        } else {
            [Progress progressShowcontent:@"删除失败了" currView:self.view];
        }
    }
}

- (void)saveRecoderVideoClasses {
    NSString *videoPath = self.recordEngine.videoPath;
    if (videoPath.length>0) {
        NSString *videoName = [videoPath componentsSeparatedByString:@"/"].lastObject;
        if (videoName.length>0) {
            NSString *videoId = [videoName componentsSeparatedByString:@"."].firstObject;
            [[SaveDataManager shareSaveRecoder] saveRecoderVodeoClass:selClassArr withVideoId:videoId];
            [[SaveDataManager shareSaveRecoder] saveRecoderTitle:playTitle withVideoId:videoId];

        } else {
            [Progress progressShowcontent:@"视频保存失败了" currView:self.view];
        }
    } else {
        [Progress progressShowcontent:@"视频保存失败了" currView:self.view];
    }
    
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
            playTitle = titleStr;
            selfWeak.recorderTitle.text = titleStr;
            for (NSDictionary *classDic in selClassesArr) {
                NSDictionary *classInfo = @{@"title":titleStr,
                                            @"classId":classDic[@"classId"],
                                            @"className":classDic[@"className"]};
                [selClassArrWeak addObject:classInfo];
            }
            
            [selfWeak startRecoder];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}



@end

