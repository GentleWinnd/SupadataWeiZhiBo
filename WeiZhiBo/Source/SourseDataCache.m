//
//  SourseDataCache.m
//  AgriculturalCollegeStu
//
//  Created by YH on 2017/1/9.
//  Copyright © 2017年 YH. All rights reserved.
//
#define STUDENT_TAG @"studentTag"
#define TEACHER_TAG @"teacherTag"

#define VIDEO_TASK @"videoTask"
#define VERSION_INFO @"versionInfo"
#define COURSE_INFO @"courseInfo"
#define SELECTED_COURSE @"selectedCourse"
#define SYSTEM_TOOL_INFO @"systemToolInfo"
#define CRASH_LOG @"crashlog"


#define NOTICE @"Notice"
#define NOTICE_READ @"readNotice"
#define NOTICE_NO_READ @"unreadNotice"


#import "SourseDataCache.h"
#import "UserData.h"

@implementation SourseDataCache

#pragma creat plist
+ (void)creatPlist {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //get full path
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *plistPath;
    UserRole role = [UserData getUser].userRole;
    if (role == UserRoleTeacher) {
         plistPath = [documentDirectory stringByAppendingPathComponent:@"WeiZhiBoTeacherData.plist"];
    } else {
        plistPath = [documentDirectory stringByAppendingPathComponent:@"WeiZhiBoPatriarchData.plist"];
    }
    
    //determine whether the file has been created
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        
    } else {//if no plist file is automatically created
        NSMutableDictionary *plist = [[NSMutableDictionary alloc] init];
        //[plist setValue:@"12" forKey:SELECT_REGION];
        [plist writeToFile:plistPath atomically:YES];
    }
}


#pragma mark - get LibraryCaches path

+ (NSString *)getLibraryCachePath {
    [self creatPlist];
    NSString *libraryCacheDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *plistPath;
    UserRole role = [UserData getUser].userRole;
    if (role == UserRoleTeacher) {
        plistPath = [libraryCacheDirectory stringByAppendingPathComponent:@"WeiZhiBoTeacherData.plist"];
    } else {
        plistPath = [libraryCacheDirectory stringByAppendingPathComponent:@"WeiZhiBoPatriarchData.plist"];
    }
    return plistPath;
}

/***********************video data**********************/

#pragma mark - get video task sourse

+ (NSArray *)getUserInfo {
    
    NSString *path = [self getLibraryCachePath];
    NSDictionary *cachePlist = [[NSDictionary alloc] initWithContentsOfFile:path];
    return cachePlist[VIDEO_TASK];
}

#pragma mark - cached video task sourse

+ (BOOL)saveUserInfo:(NSArray *)VSourse {
    
    NSString *path = [self getLibraryCachePath];
    NSMutableDictionary *cachedDataInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [cachedDataInfo setValue:VSourse forKey:VIDEO_TASK];
    return [cachedDataInfo writeToFile:path atomically:YES];
}


/***********************app versions info***********************/
#pragma mark - app version

+ (BOOL)saveAPPVersionInfo:(NSDictionary *)versionInfo {
    NSString *path = [self getLibraryCachePath];
    
    NSMutableDictionary *cachedDataInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [cachedDataInfo setValue:versionInfo forKey:VERSION_INFO];
    return [cachedDataInfo writeToFile:path atomically:YES];
}

+ (NSDictionary *)getAPPVersionInfo {
    NSString *path = [self getLibraryCachePath];
    NSDictionary *cachePlist = [[NSDictionary alloc] initWithContentsOfFile:path];
    return cachePlist[VERSION_INFO];

}


/*****************************app course Info***************************/
#pragma mark - app course info
+ (BOOL)saveRecentCourseInfo:(NSDictionary *)course {
    NSString *path = [self getLibraryCachePath];
    
    NSMutableDictionary *cachedDataInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [cachedDataInfo setValue:course forKey:COURSE_INFO];
    
    return [cachedDataInfo writeToFile:path atomically:YES];

}

+ (NSDictionary *)getRecentCourseInfo {
    
    NSString *path = [self getLibraryCachePath];
    NSDictionary *cachePlist = [[NSDictionary alloc] initWithContentsOfFile:path];
    return cachePlist[COURSE_INFO];
    
}

/*****************************app Selectd Course Info***************************/
#pragma mark - Selectd Course info
+ (BOOL)saveSelectdCourseInfo:(NSDictionary *)activity {
    NSString *path = [self getLibraryCachePath];
    
    NSMutableDictionary *cachedDataInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [cachedDataInfo setValue:activity forKey:SELECTED_COURSE];
    
    return [cachedDataInfo writeToFile:path atomically:YES];
    
}

+ (NSDictionary *)getSelectdCourseInfo {
    
    NSString *path = [self getLibraryCachePath];
    NSDictionary *cachePlist = [[NSDictionary alloc] initWithContentsOfFile:path];
    return cachePlist[SELECTED_COURSE];
    
}

/*****************************app tool info******************************/

+ (BOOL)saveAppToolsInfo:(NSDictionary *)toolInfo {
    NSString *path = [self getLibraryCachePath];
    if (toolInfo == nil) {
        return NO;
    }
    NSMutableDictionary *cachedDataInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [cachedDataInfo setValue:toolInfo forKey:SYSTEM_TOOL_INFO];
    return [cachedDataInfo writeToFile:path atomically:YES];
}

+ (NSString *)getAPPFeedBackEmail {
    NSString *path = [self getLibraryCachePath];
    NSDictionary *cachePlist = [[NSDictionary alloc] initWithContentsOfFile:path];
    return cachePlist[SYSTEM_TOOL_INFO][@"FeedbackEmail"];
}

+ (BOOL)getAPPDebugMode {
    NSString *path = [self getLibraryCachePath];
    NSDictionary *cachePlist = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSNumber *debugMode = cachePlist[SYSTEM_TOOL_INFO][@"DebugMode"];
    return debugMode.boolValue;
}

/*****************************app crash log info******************************/
#pragma mark - crash log
+ (BOOL)saveAppCrashLogInfo:(NSString *) crashLog {
    NSString *path = [self getLibraryCachePath];
    if (crashLog == nil) {
        return NO;
    }
    NSMutableDictionary *cachedDataInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [cachedDataInfo setValue:crashLog forKey:CRASH_LOG];
    return [cachedDataInfo writeToFile:path atomically:YES];
}

+ (NSString *)getAPPCrashLogInfo {
    NSString *path = [self getLibraryCachePath];
    NSDictionary *cachePlist = [[NSDictionary alloc] initWithContentsOfFile:path];
    return cachePlist[CRASH_LOG];
}

+ (BOOL)removeCrashLog {
    NSString *path = [self getLibraryCachePath];
    NSMutableDictionary *cachedDataInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [cachedDataInfo setValue:@"" forKey:CRASH_LOG];
    return YES;
}

/*****************************app notice log info******************************/
#pragma mark - notice log
+ (BOOL)saveAppNoticeInfo:(NSDictionary *) notice readed:(BOOL)readed {
    NSString *path = [self getLibraryCachePath];
    if (notice == nil) {
        return NO;
    }
    NSString *typeKey = readed ?NOTICE_READ:NOTICE_NO_READ;
    NSMutableDictionary *cachedDataInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSMutableDictionary *noticeInfos = [NSMutableDictionary dictionaryWithDictionary:cachedDataInfo[NOTICE]];
    NSMutableArray *noticeArray = [NSMutableArray arrayWithArray:noticeInfos[typeKey]];
    [noticeArray addObject:notice];
    [noticeInfos setValue:noticeArray forKey:typeKey];
    [cachedDataInfo setValue:noticeInfos forKey:NOTICE];
    return [cachedDataInfo writeToFile:path atomically:YES];
}

+ (NSArray *)getAllNotice {
    NSString *path = [self getLibraryCachePath];
    NSDictionary *cachePlist = [[NSDictionary alloc] initWithContentsOfFile:path];
    NSMutableArray *allNotice = [NSMutableArray arrayWithCapacity:0];
    [allNotice addObjectsFromArray:cachePlist[NOTICE][NOTICE_NO_READ]];
    [allNotice addObjectsFromArray:cachePlist[NOTICE][NOTICE_READ]];
    return allNotice;
}

+ (NSArray *)getUnreadNotices {
    NSString *path = [self getLibraryCachePath];
    NSDictionary *cachePlist = [[NSDictionary alloc] initWithContentsOfFile:path];
    return cachePlist[NOTICE][NOTICE_NO_READ];
}

+ (BOOL)changeNoticeState {
    
    NSString *path = [self getLibraryCachePath];
    NSMutableDictionary *cachedDataInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSMutableDictionary *noticeInfos = [NSMutableDictionary dictionaryWithDictionary:cachedDataInfo[NOTICE]];
    
    NSMutableArray *noticeArray = [NSMutableArray arrayWithArray:noticeInfos[NOTICE_READ]];
    [noticeArray addObjectsFromArray:noticeInfos[NOTICE_NO_READ]];
    [noticeInfos removeObjectForKey:NOTICE_NO_READ];
    
    [noticeInfos setValue:noticeArray forKey:NOTICE_READ];
    [cachedDataInfo setValue:noticeInfos forKey:NOTICE];
    return [cachedDataInfo writeToFile:path atomically:YES];

}

+ (BOOL)removeNotice:(NSDictionary *) notice {
    NSString *path = [self getLibraryCachePath];
    NSMutableDictionary *cachedDataInfo = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    NSMutableArray *noticeArray = [NSMutableArray arrayWithArray:cachedDataInfo[NOTICE]];
    [noticeArray removeObject:notice];
    [cachedDataInfo setValue:noticeArray forKey:NOTICE];
    return YES;
}


#pragma mark - remove cache

+ (void)removedTaskCache {
    NSString *path = [self getLibraryCachePath];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:path error:nil];
}

@end
