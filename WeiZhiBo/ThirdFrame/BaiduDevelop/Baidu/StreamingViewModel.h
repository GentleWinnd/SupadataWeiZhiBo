//
//  StreamingViewModel.h
//  LiveDemo
//
//  Created by 白璐 on 16/8/10.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Defines.h"
#import <VideoCore/VideoCore.h>

@class VCSimpleSession;
@protocol VCSessionDelegate;

@interface StreamingViewModel : NSObject
@property (nonatomic, strong) VCSimpleSession* session;
@property (nonatomic, strong) NSString *pushUrl;
@property (nonatomic, assign) BOOL beautyEnabled;

- (instancetype)initWithPushUrl:(NSString *)url;

- (void)setupSession:(AVCaptureVideoOrientation)orientation delegate:(id<VCSessionDelegate>)delegate;
- (void)preview:(UIView*)view;
- (void)updateFrame:(UIView*)view;
- (BOOL)back;
- (BOOL)toggleTorch;
- (void)switchCamera;
- (BOOL)toggleBeauty;
- (BOOL)toggleStream;
- (void)enableBeauty:(VCBeautyLevel)level;
- (void)updateBright:(float)bright smooth:(float)smooth pink:(float)pink;

- (void)pinch:(CGFloat)scale state:(UIGestureRecognizerState)state;
- (void)setInterestPoint:(CGPoint)point;
- (void)zoomIn;

@end
