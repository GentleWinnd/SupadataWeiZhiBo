//
//  NSString+Date.h
//  KTMExpertCheck
//
//  Created by fangling on 15/8/25.
//  Copyright (c) 2015年 kaitaiming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Date)
//日期格式yyyy-MM-dd
+ (NSString *)stringFromDate:(NSDate *)date;
//日期格式yyyy-MM-dd HH:mm:ss
+ (NSString *)stringFromCompleteDate:(NSDate *)date;
//数字转日期
+ (NSString *)stringFromCompleteDateWithMillisecond:(NSInteger)millisecond;
//日期字符串
+ (NSString *)stringFromDateString:(NSString *)dateString;

//日期字符串 yyyy-MM-dd'T'HH:mm:ssZZZZZ
+ (NSString *)stringFromZZZZDateString:(NSString *)dateString;
//当前日期生成string
+ (NSString *)stringFromCurrentDate;
//日期格式yyyy-MM-dd 转成date
+ (NSDate *)dateFromString:(NSString *)dateString;

@end
