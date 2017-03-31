//
//  StreamingViewModel.m
//  LiveDemo
//
//  Created by 白璐 on 16/8/10.
//  Copyright © 2016年 baidu. All rights reserved.
//

#import "StreamingViewModel.h"
#import <VideoCore/VideoCore.h>

@interface StreamingViewModel ()
@property(nonatomic, assign) BOOL automaticResume;
@property(nonatomic, assign) float zoomMax;
@property(nonatomic, assign) float zoomStep;
@property(nonatomic, assign) float scale;
@property(nonatomic, assign) float previousScale;
@end

@implementation StreamingViewModel

- (instancetype)initWithPushUrl:(NSString *)url {
    if (self = [super init]) {
        self.pushUrl = url;
        self.beautyEnabled = YES;
        _automaticResume = NO;
        _zoomMax = 0.f;
        _scale = 1.0f;
        
    }
    
    return self;
}

- (CGSize)size {
    return [ResolutionHelper size:Resolution_720P direction:DirectionLandscape];
}

- (NSUInteger)bitrate {
    return [BitrateHelper bitrate:Resolution_720P];
}

- (void)setupSession:(AVCaptureVideoOrientation)orientation delegate:(id<VCSessionDelegate>)delegate {
    VCSimpleSessionConfiguration* configuration = [[VCSimpleSessionConfiguration alloc] init];
    configuration.cameraOrientation = orientation;
    configuration.videoSize = [self size];
    configuration.bitrate = [self bitrate];
    configuration.cameraDevice = VCCameraStateBack;
    configuration.continuousAutofocus = NO;
    configuration.continuousExposure = YES;
    
    self.session = [[VCSimpleSession alloc] initWithConfiguration:configuration];
    self.session.aspectMode = VCAspectModeFill;
    self.session.delegate = delegate;
}

- (void)onNotification:(NSNotification*)notification {
    if ([notification.name isEqualToString:UIApplicationWillResignActiveNotification]) {
        if (self.session.rtmpSessionState == VCSessionStateStarted) {
            self.automaticResume = YES;
            [self toggleStream];
        }
    }
    
    if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        if (self.automaticResume) {
            [self toggleStream];
            self.automaticResume = NO;
        }
    }
}

- (void)preview:(UIView*)view {
    if (self.session) {
        [view insertSubview:self.session.previewView atIndex:0];
    }
}

- (void)updateFrame:(UIView*)view {
    self.session.previewView.frame = view.bounds;
    for (UIView* subview in self.session.previewView.subviews) {
        subview.frame = view.bounds;
    }
}


- (BOOL)back {
    if (self.session.rtmpSessionState == VCSessionStateStarting
        || self.session.rtmpSessionState == VCSessionStateStarted) {
        [self.session endRtmpSession];
        return YES;
    }
    
    return NO;
}

- (BOOL)toggleTorch {
    if (self.session) {
        self.session.torch = !self.session.torch;
    }
    
    return self.session.torch;
}

- (void)switchCamera {
    [self.session switchCamera];
    self.scale = 1.0f;
    self.zoomMax = 0.0f;
}

- (BOOL)toggleBeauty {
    if (self.session) {
        self.beautyEnabled = !self.beautyEnabled;
        [self.session enableBeautyEffect:self.beautyEnabled];
    }
    
    return self.beautyEnabled;
}

- (BOOL)toggleStream {
    
    switch(self.session.rtmpSessionState) {
        case VCSessionStateNone:
        case VCSessionStatePreviewStarted:
        case VCSessionStateEnded:
        case VCSessionStateError: {
            [self.session startRtmpSessionWithURL:self.pushUrl];
            return YES;
        }
        case VCSessionStateStarted: {
            [self.session endRtmpSession];
            return NO;
        }
        default:
            return NO;
    }
}

- (void)enableBeauty:(VCBeautyLevel)level {
    self.session.beautyLevel = level;
}

- (void)updateBright:(float)bright smooth:(float)smooth pink:(float)pink {
    [self.session setBeatyEffect:bright withSmooth:smooth withPink:pink];
}

- (void)initZoomMax {
    if (fabs(self.zoomMax) < 10e-6) {
        self.zoomMax = [self.session getMaxZoomLevel];
        self.zoomStep = (self.zoomMax - 1.0f) / 4;
    }
}

- (void)pinch:(CGFloat)scale state:(UIGestureRecognizerState)state {
    if (state == UIGestureRecognizerStateBegan) {
        [self initZoomMax];
        self.previousScale = self.scale;
    }
    
    CGFloat currentScale = fmaxf(fminf(self.scale * scale, self.zoomMax), 1.0f);
    CGSize size = self.session.videoSize;
    CGPoint center = CGPointMake(size.width / 2, size.height / 2);
    [self.session zoomVideo:currentScale withCenter:center];
    NSLog(@"the zoom level is %.2f", currentScale);
    
    self.previousScale = currentScale;
    if (state == UIGestureRecognizerStateEnded
        || state == UIGestureRecognizerStateCancelled
        || state == UIGestureRecognizerStateFailed) {
        self.scale = currentScale;
        NSLog(@"final scale: %f", self.scale);
    }
}

- (void)zoomIn {
    [self initZoomMax];
    
    if (fabs(self.scale - self.zoomMax) < 10e-6) {
        self.scale = 1.0f;
    } else {
        float scale = self.scale + self.zoomStep;
        scale = fmaxf(1, fminf(scale, self.zoomMax));
        self.scale = scale;
    }
    
    CGSize size = self.session.videoSize;
    CGPoint center = CGPointMake(size.width / 2, size.height / 2);
    [self.session zoomVideo:self.scale withCenter:center];
}

- (void)setInterestPoint:(CGPoint)point {
    self.session.focusPointOfInterest = point;
    self.session.exposurePointOfInterest = point;
}


@end
