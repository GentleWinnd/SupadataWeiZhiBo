//
//  HistoryRecoderViewController.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/6/22.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryRecoderViewController : UIViewController
@property (strong, nonatomic) NSMutableArray *historyRecoderArr;//历史视频记录

@property (strong, nonatomic) NSString *userId;
@property (assign, nonatomic) UserRole userRole;

@property (nonatomic, strong) NSString *schoolId;
@property (nonatomic, strong) NSString *schoolName;

@end
