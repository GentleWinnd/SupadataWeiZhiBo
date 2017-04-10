//
//  ViewController.h
//  WeiZhiBo
//
//  Created by YH on 2017/3/21.
//  Copyright © 2017年 YH. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "V8HorizontalPickerView.h"
@class StreamingViewModel;

@interface ViewController : UIViewController<V8HorizontalPickerViewDelegate,V8HorizontalPickerViewDataSource>
{
    BOOL         _isPreviewing;
    NSString   * _pushUrl;

    unsigned long long  _startTime;
    unsigned long long  _lastTime;
    
    NSString*       _logMsg;
    NSString*       _tipsMsg;

}
@property (strong, nonatomic) NSArray *userClassInfo;
@property (strong, nonatomic) NSString *phoneNUM;
@property(nonatomic, strong) StreamingViewModel* model;


@end


@interface ContentView : UIView
@property (strong, nonatomic) IBOutlet UIImageView *redDotImage;

@property (strong, nonatomic) IBOutlet UILabel *rateLabel;
@property (strong, nonatomic) IBOutlet UILabel *thumbsUpLabel;
@property (strong, nonatomic) IBOutlet UILabel *watchLabel;
@property (strong, nonatomic) IBOutlet UILabel *shotingTimeLable;


@end

@interface ClassNameView : UIView

@property (strong, nonatomic) NSArray *userClassInfo;
@property (strong, nonatomic) IBOutlet UIPickerView *classPickerView;
@property (copy, nonatomic) void(^ getClassInfo)(BOOL success, NSDictionary *classInfo, NSString *schoolId, NSString *schoolName);
@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) NSString *classId;
@property (strong, nonatomic) NSString *schoolName;
@property (strong, nonatomic) NSString *schoolId;
@property (strong, nonatomic) NSDictionary *classInfo;

@end
