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

