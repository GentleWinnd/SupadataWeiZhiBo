//
//  SourseDataCache.h
//  AgriculturalCollegeStu
//
//  Created by YH on 2017/1/9.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SourseDataCache : NSObject


/**
 get video task sourse

 @return videotask sourse
 */
+ (NSArray *)getVideoTaskSousrse;


/**
 save video task sourse

 @param VSourse task info
 @return cached result
 */
+ (BOOL)saveVideoSourse:(NSArray *)VSourse;

#pragma mark - app version Info 
// save version info
+ (BOOL)saveAPPVersionInfo:(NSDictionary *)versionInfo;
// get version info
+ (NSDictionary *)getAPPVersionInfo;

#pragma mark - app course info
+ (BOOL)saveRecentCourseInfo:(NSDictionary *)course;
+ (NSDictionary *)getRecentCourseInfo;

/*****************************app activity Info***************************/
#pragma mark - Selectd Course info
+ (BOOL)saveSelectdCourseInfo:(NSDictionary *)activity;
+ (NSDictionary *)getSelectdCourseInfo;

/*****************************app tool info******************************/
#pragma mark - app tools info
+ (BOOL)saveAppToolsInfo:(NSDictionary *)toolInfo;
+ (NSString *)getAPPFeedBackEmail;
+ (BOOL)getAPPDebugMode;

/*****************************app crash log info******************************/
#pragma mark - crash log
+ (BOOL)saveAppCrashLogInfo:(NSString *)crashLog;
+ (NSString *)getAPPCrashLogInfo;
+ (BOOL)removeCrashLog;

/*****************************app notice log info******************************/
#pragma mark - notice log
+ (BOOL)saveAppNoticeInfo:(NSDictionary *) notice readed:(BOOL)readed;
+ (NSArray *)getUnreadNotices;
+ (NSArray *)getAllNotice;
+ (BOOL)changeNoticeState;
+ (BOOL)removeNotice:(NSDictionary *) notice;



@end
