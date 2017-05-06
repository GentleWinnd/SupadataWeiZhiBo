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
@class StreamingViewModel;

@interface ViewController : UIViewController
{
    BOOL         _isPreviewing;
    NSString   * _pushUrl;

    unsigned long long  _startTime;
    unsigned long long  _lastTime;
    
    NSString*       _logMsg;
    NSString*       _tipsMsg;

}
@property (strong, nonatomic) NSArray *userClassInfo;
@property (strong, nonatomic) NSString *userId;

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *openId;
@property (nonatomic, strong) NSString *schoolId;
@property (nonatomic, strong) NSString *schoolName;

@property (nonatomic, strong) StreamingViewModel* model;

@end


@interface ClassNameView : UIView

@property (strong, nonatomic) NSArray *userClassInfo;
@property (strong, nonatomic) IBOutlet UITableView *classNameTab;
@property (copy, nonatomic) void(^ getClassInfo)(BOOL success, NSDictionary *classInfo);
@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) NSString *classId;
@property (strong, nonatomic) NSDictionary *classInfo;
@property (strong, nonatomic) NSString *proTitle;
@property (strong, nonatomic) NSString *title;


@end
