//
//  NotificationManager.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/8/23.
//  Copyright © 2017年 YH. All rights reserved.
//
#define VIDEO_UPLOAD @"videoUpload"


#import <Foundation/Foundation.h>

@interface NotificationManager : NSObject
// 设置本地通知
+ (void)registerLocalNotificationAlertBody:(NSString *)alertStr description:(NSString *)descriptionStr;
// 取消某个本地推送通知
+ (void)cancelLocalNotificationWithKey:(NSString *)key;
//修改iconEdgeNumber
+ (void)setIconEdgeNumber;
@end
