//
//  NSString+Date.m
//  KTMExpertCheck
//
//  Created by fangling on 15/8/25.
//  Copyright (c) 2015年 kaitaiming. All rights reserved.
//

#import "NSString+Date.h"

@implementation NSString (Date)

//日期格式yyyy-MM-dd
+ (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:date];
}

//日期格式yyyy-MM-dd HH:mm:ss
+ (NSString *)stringFromCompleteDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

//数字转日期
+ (NSString *)stringFromCompleteDateWithMillisecond:(NSInteger)millisecond {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)(millisecond/1000)];
    return [self stringFromCompleteDate:date];
}

//日期字符串
+ (NSString *)stringFromDateString:(NSString *)dateString{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *date = [formatter dateFromString:dateString];
    return [self stringFromCompleteDate:date];
}

//日期字符串 yyyy-MM-dd'T'HH:mm:ssZZZZZ
+ (NSString *)stringFromZZZZDateString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    NSDate *date = [formatter dateFromString:dateString];
    return [self stringFromCompleteDate:date];
}

//当前日期生成string
+ (NSString *)stringFromCurrentDate {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    return [formatter stringFromDate:date];

}

//日期格式yyyy-MM-dd 转成date
+ (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter dateFromString:dateString];
}

@end
