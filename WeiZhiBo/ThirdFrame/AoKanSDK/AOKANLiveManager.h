//
//  ViewController.h
//  anyLive
//
//  Created by Jason's Mac on 15/11/13.
//  Copyright © 2015年 OOK. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>

#import <CoreImage/CoreImage.h>

#import <UIKit/UIKit.h>

@interface AOKANLiveManager :NSObject<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate> {

        BOOL   VEncoding;
        BOOL   AEncoding;
        
    void * _venc;
    void * _aenc;
    void * _upld;
}

@property (strong, nonatomic) AVCaptureSession           *recordSession;//捕获视频的会话
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;//捕获到的视频呈现的layer
@property (strong, nonatomic) AVCaptureDeviceInput       *backCameraInput;//后置摄像头输入
@property (strong, nonatomic) AVCaptureDeviceInput       *frontCameraInput;//前置摄像头输入
@property (strong, nonatomic) AVCaptureDeviceInput       *audioMicInput;//麦克风输入
@property (strong, nonatomic) AVCaptureDevice            *currentdevice;//当前的设备
@property (copy  , nonatomic) dispatch_queue_t           captureQueue;//录制的队列
@property (strong, nonatomic) AVCaptureConnection        *audioConnection;//音频录制连接
@property (strong, nonatomic) AVCaptureConnection        *videoConnection;//视频录制连接
@property (strong, nonatomic) AVCaptureVideoDataOutput   *videoOutput;//视频输出
@property (strong, nonatomic) AVCaptureAudioDataOutput   *audioOutput;//音频输出
@property (assign, nonatomic) BOOL StartLiving;


- (instancetype)initWithURL:(NSString *) httpUrl withOnlyId:(NSString *)onlyId;

//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer;


//启动录制功能
- (void)startUp;
//关闭录制功能
- (void)shutdown;
//开始录制
- (BOOL) startLive;
//停止录制
- (void) stopLive;

//刷新时间和上传码率
- (NSString *)getUploadRate;
//获取推流状态
- (BOOL)getUplaodLiveState;
//获取推流延迟状态
- (BOOL)getDelayState;
//获取视频上传的溢出率
- (int)getOverflow;

//开启闪光灯
- (void)openFlashLight;
//关闭闪光灯
- (void)closeFlashLight;
//设置焦点
- (void)focusAtPoint:(CGPoint)point;
//切换前后置摄像头
- (void)changeCameraInputDeviceisFront:(BOOL)isFront;




@end
