//
//  RecorderViewController.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/6/15.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import <UIKit/UIKit.h>

@interface RecorderViewController : UIViewController

@property (strong, nonatomic) NSArray *userClassInfo;
@property (strong, nonatomic) NSString *userId;
@property (assign, nonatomic) UserRole userRole;

@property (nonatomic, strong) NSString *schoolId;
@property (nonatomic, strong) NSString *schoolName;


@end

