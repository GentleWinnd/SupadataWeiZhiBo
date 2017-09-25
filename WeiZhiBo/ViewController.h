//
//  ViewController.h
//  WeiZhiBo
//
//  Created by YH on 2017/3/21.
//  Copyright © 2017年 YH. All rights reserved.
//

typedef NS_ENUM(NSInteger, MessageType) {
    
    MessageTypeOpen=1,
    MessageTypeSendMessage,
    MessageTypeClose
};

typedef NS_ENUM(NSInteger, AlertViewType) {
    
    AlertViewTypeSendParents,
    AlertViewTypeQuitPlayView,
    AlertViewTypeStopPlay
    
};

typedef NS_ENUM(NSInteger, MessageSocketType) {
    MessageSocketTypeDefualtMessage=1,
    MessageSocketTypeLivePeople,
    MessageSocketTypeThumbNumebr
    
};

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "AOKANLiveManager.h"

@class StreamingViewModel;

@interface ViewController : UIViewController

@property (strong, nonatomic) NSArray *userClassInfo;
@property (strong, nonatomic) NSString *userId;
@property (assign, nonatomic) UserRole userRole;

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *openId;
@property (nonatomic, strong) NSString *schoolId;
@property (nonatomic, strong) NSString *schoolName;
@property (nonatomic, strong) NSString *cameraDataId;
@property (nonatomic, strong) NSString *pushUrl;
@property (nonatomic, strong) NSString *onlyId;

@property (nonatomic, strong) AOKANLiveManager *liveManager;
@property (nonatomic, strong) StreamingViewModel* model;


@end

