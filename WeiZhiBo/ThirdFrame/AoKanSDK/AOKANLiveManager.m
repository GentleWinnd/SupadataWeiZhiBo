//
//  ViewController.m
//  anyLive
//
//  Created by Jason's Mac on 15/11/13.
//  Copyright ¬© 2015Âπ¥ OOK. All rights reserved.
//
#import "AOKANLiveManager.h"
#import "__anyLive.h"

#define VERSION 8 // @ 2016/03/31

static int openvideo_   = 1;
static int openaudio_   = 1;

static int profile_     = 1;
static int frames_[4]   = { 15, 20, 25, 30 };
static int vbitrate_[4] = { 400000, 600000, 1200000, 2000000 };
static int abitrate_    = 32000;

static unsigned int aprintmask_ = 0x00;
static unsigned int vprintmask_ = 0x00;

static NSString * myuuid_   = nil;//直播唯一标识
static NSString * uploadUrl_  = nil;//上传URL
static NSString * uploadPort = nil;//上传端口
static NSString * upldpwd_  = nil;//秘钥
static NSString * tracesvr_ = nil;//日志地址


@interface AOKANLiveManager () <UITextFieldDelegate>

@end

@implementation AOKANLiveManager
- (void)dealloc {
    [_recordSession stopRunning];
    _captureQueue     = nil;
    _recordSession    = nil;
    _previewLayer     = nil;
    _backCameraInput  = nil;
    _frontCameraInput = nil;
    _audioOutput      = nil;
    _videoOutput      = nil;
    _audioConnection  = nil;
    _videoConnection  = nil;
    _StartLiving       = NO;
    
    _venc = NULL;
    _aenc = NULL;
    _upld = NULL;
    
}


- (NSString *)spliceUploadURL:(NSString *) httpUtl {
//http://live2.139jy.cn:1554/live/11d7950729ab4230bdc71b2989a84066?ps=push2

    NSArray *items = [httpUtl componentsSeparatedByString:@":"];
    NSString *lastStr = items.lastObject;
    uploadPort = [lastStr componentsSeparatedByString:@"/"].firstObject;
    
    NSString *uploadPath = [httpUtl componentsSeparatedByString:@"//"].lastObject;
    uploadUrl_ = [[uploadPath stringByAppendingString:@":"] stringByAppendingString:uploadPort];
    
    return uploadUrl_;
}

- (instancetype)initWithURL:(NSString *) httpUrl {
    
    self = [super init];
    if (self) {
        
        myuuid_ = @"11e326d051f349f2b2817d8fd4bb1c7d";

        //拼接推流地址
        [self spliceUploadURL:@"http://live4.139jy.cn:1554/live/11e326d051f349f2b2817d8fd4bb1c7d?ps=push4:1554"];
        
        //设置日志地址
        if(tracesvr_ && [tracesvr_ length] > 0) {
            // open remote TRACE for debug
            openTrace(tracesvr_, 3);
            printTrace(@"running on 'iOS' device");

        }
 
    }
    return self;
}

/****************功能方法****************/

//启动录制功能
- (void)startUp {
    //    NSLog(@"启动录制功能");
    if (self.recordSession) {
        [self.recordSession startRunning];
        [self startLive];
    }
    
}

//关闭录制功能
- (void)shutdown {
    
    if (_recordSession) {
        [_recordSession stopRunning];
    }
}

//开始录制
- (BOOL) startLive {
    @synchronized(self) {
        if (![self checkDeviceStatus]) {
            return NO;
        }
        _upld = create_uploader(uploadUrl_, myuuid_, upldpwd_, false);
        
        if (_upld) {
            _StartLiving = YES;
            printTrace(@"start video recording...");

            return YES;
        }
        return NO;
    }
}

//停止录制
- (void) stopLive {
    @synchronized(self) {
        
        _StartLiving = NO;
        printTrace(@"stop video recording...");
        release_video_encoder(_venc);
        release_audio_encoder(_aenc);
        release_uploader(_upld);
        
        _venc = NULL;
        _aenc = NULL;
        _upld = NULL;
        
    }
}

//刷新时间和上传码率
- (NSString *)getUploadRate {
    
    struct upload_info_ex info;
    uploader_info_ex(_upld, &info);
    
    return  [NSString stringWithFormat:@" %dkbps/%d",info.s.speed/1024,info.buffer];
}

//获取推流状态
- (BOOL)getUplaodLiveState {
    struct upload_info_ex info;
    uploader_info_ex(_upld, &info);
    
    return info.s.status > 0;
    
}

//获取推流延迟状态
- (BOOL)getDelayState {

    struct upload_info_ex info;
    uploader_info_ex(_upld, &info);
    
    if (info.s.speed > (vbitrate_ [profile_]+ abitrate_) / 3) {
        return YES;
    } else {
        return NO;
    }
}


//获取视频上传的溢出率
- (int)getOverflow {
    
    struct upload_info_ex info;
    uploader_info_ex(_upld, &info);
    
    return info.s.overflow;
}

- (BOOL)checkDeviceStatus {
    BOOL status = YES;
    //是否有摄像头权限
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusVideo == AVAuthorizationStatusDenied) {
        [Progress progressShowcontent:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限"];
        status = NO;
    }
    
    //是否有麦克风权限
    AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (statusAudio == AVAuthorizationStatusDenied) {
        [Progress progressShowcontent:@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限"];
        status = NO;
    }
    return status;
}

#pragma mark - set、get方法

//录制的队列
- (dispatch_queue_t)captureQueue {
    if (_captureQueue == nil) {
        _captureQueue = dispatch_queue_create("cn.supadata.im.liveing.capture", DISPATCH_QUEUE_SERIAL);
    }
    return _captureQueue;
}

//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        //通过AVCaptureSession初始化
        AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.recordSession];
        //设置比例为铺满全屏
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer = preview;
    }
    return _previewLayer;
}

//捕获视频的会话
- (AVCaptureSession *)recordSession {
    if (_recordSession == nil) {
        _recordSession = [[AVCaptureSession alloc] init];
        //添加后置摄像头的输出
        if ([_recordSession canAddInput:self.backCameraInput]) {
            [_recordSession addInput:self.backCameraInput];
        }
        //添加后置麦克风的输出
        if ([_recordSession canAddInput:self.audioMicInput]) {
            [_recordSession addInput:self.audioMicInput];
        }
        //添加视频输出
        if ([_recordSession canAddOutput:self.videoOutput]) {
            [_recordSession addOutput:self.videoOutput];
            //设置视频的分辨率
//            _cx = 640;
//            _cy = 480;
            [_recordSession setSessionPreset:AVCaptureSessionPreset640x480];

        }
        //添加音频输出
        if ([_recordSession canAddOutput:self.audioOutput]) {
            [_recordSession addOutput:self.audioOutput];
        }
        //添加防抖动功能
        self.videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([self.videoConnection isVideoStabilizationSupported]) {
            self.videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;//防抖模式
        }
        //设置视频录制的方向
        self.videoConnection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        _currentdevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
        
    }
    return _recordSession;
}

//后置摄像头输入
- (AVCaptureDeviceInput *)backCameraInput {
    if (_backCameraInput == nil) {
        NSError *error;
        _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        if (error) {
            NSLog(@"获取后置摄像头失败~");
        }
    }
    return _backCameraInput;
}

//前置摄像头输入
- (AVCaptureDeviceInput *)frontCameraInput {
    if (_frontCameraInput == nil) {
        NSError *error;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        if (error) {
            NSLog(@"获取前置摄像头失败~");
        }
    }
    return _frontCameraInput;
}

//麦克风输入
- (AVCaptureDeviceInput *)audioMicInput {
    if (_audioMicInput == nil) {
        AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error;
        _audioMicInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
        if (error) {
            NSLog(@"获取麦克风失败~");
        }
    }
    return _audioMicInput;
}

//视频输出
- (AVCaptureVideoDataOutput *)videoOutput {
    if (_videoOutput == nil) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoOutput setSampleBufferDelegate:self queue:self.captureQueue];
        NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                        nil];
        _videoOutput.videoSettings = setcapSettings;
    }
    return _videoOutput;
}

//音频输出
- (AVCaptureAudioDataOutput *)audioOutput {
    if (_audioOutput == nil) {
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioOutput setSampleBufferDelegate:self queue:self.captureQueue];
    }
    return _audioOutput;
}

//视频连接
- (AVCaptureConnection *)videoConnection {
    _videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    return _videoConnection;
}

//音频连接
- (AVCaptureConnection *)audioConnection {
    _audioConnection = [self.audioOutput connectionWithMediaType:AVMediaTypeAudio];
    return _audioConnection;
}

#pragma mark - 视频相关
//返回前置摄像头
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

//返回后置摄像头
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}


//切换前后置摄像头
- (void)changeCameraInputDeviceisFront:(BOOL)isFront {
    if (isFront) {
        [self.recordSession stopRunning];
        [self.recordSession removeInput:self.backCameraInput];
        if ([self.recordSession canAddInput:self.frontCameraInput]) {
//            [self changeCameraAnimation];
            [self.recordSession addInput:self.frontCameraInput];
            _currentdevice = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
    }else {
        [self.recordSession stopRunning];
        [self.recordSession removeInput:self.frontCameraInput];
        if ([self.recordSession canAddInput:self.backCameraInput]) {
//            [self changeCameraAnimation];
            [self.recordSession addInput:self.backCameraInput];
            _currentdevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
    }
}

//用来返回是前置摄像头还是后置摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    //返回和视频录制相关的所有默认设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //遍历这些设备返回跟position相关的设备
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

//开启闪光灯
- (void)openFlashLight {
    AVCaptureDevice *backCamera = [self backCamera];
    if (backCamera.torchMode == AVCaptureTorchModeOff) {
        [backCamera lockForConfiguration:nil];
        backCamera.torchMode = AVCaptureTorchModeOn;
        backCamera.flashMode = AVCaptureFlashModeOn;
        [backCamera unlockForConfiguration];
    }
}
//关闭闪光灯
- (void)closeFlashLight {
    AVCaptureDevice *backCamera = [self backCamera];
    if (backCamera.torchMode == AVCaptureTorchModeOn) {
        [backCamera lockForConfiguration:nil];
        backCamera.torchMode = AVCaptureTorchModeOff;
        backCamera.flashMode = AVCaptureTorchModeOff;
        [backCamera unlockForConfiguration];
    }
}

//AVCaptureFlashMode 闪光灯
//AVCaptureFocusMode 对焦
//AVCaptureExposureMode 曝光
//AVCaptureWhiteBalanceMode 白平衡
//闪光灯和白平衡可以在生成相机时候设置
//曝光要根据对焦点的光线状况而决定,所以和对焦一块写
//point为点击的位置
- (void)focusAtPoint:(CGPoint)point {
    NSError *error;
    if ([self.currentdevice lockForConfiguration:&error]) {
        //对焦模式和对焦点
        if ([self.currentdevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.currentdevice setFocusPointOfInterest:point];
            [self.currentdevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        //曝光模式和曝光点
        if ([self.currentdevice isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.currentdevice setExposurePointOfInterest:point];
            [self.currentdevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.currentdevice unlockForConfiguration];
        //        //设置对焦动画
        //        _focusView.center = point;
        //        _focusView.hidden = NO;
        //        [UIView animateWithDuration:0.3 animations:^{
        //            _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        //        }completion:^(BOOL finished) {
        //            [UIView animateWithDuration:0.5 animations:^{
        //                _focusView.transform = CGAffineTransformIdentity;
        //            } completion:^(BOOL finished) {
        //                _focusView.hidden = YES;
        //            }];
        //        }];
    }
    
}


#pragma AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {

    if (_StartLiving) {
        if (connection == self.audioConnection) {
            ///printTrace(@"audio sample");
            if (!AEncoding) {
                AEncoding = YES;
                AudioStreamBasicDescription inAudioStreamBasicDescription = *CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer));
                
                int samplerate = inAudioStreamBasicDescription.mSampleRate;
                int channels   = inAudioStreamBasicDescription.mChannelsPerFrame;
                
                _aenc = create_audio_encoder(samplerate, channels, abitrate_, aprintmask_);
                
                if(_aenc && _upld)
                    audio_attach_uploader(_aenc, _upld);
            }
            
            audio_encode(_aenc, sampleBuffer);
        } else if (connection == _videoConnection) {
            ///printTrace(@"video sample");
            
            if (!VEncoding) {
                VEncoding = YES;
                CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                
                size_t width  = CVPixelBufferGetWidth (imageBuffer);
                size_t height = CVPixelBufferGetHeight(imageBuffer);
                
                _venc = create_video_encoder((int)width, (int)height, frames_[profile_], frames_[profile_] * 3, vbitrate_[profile_], vprintmask_);
                
                if(_venc && _upld)
                    video_attach_uploader(_venc, _upld);
            }
            
            video_encode(_venc, sampleBuffer);
        }
    }
	
}


@end
