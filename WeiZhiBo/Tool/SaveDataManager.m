//
//  SaveDataManager.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/6/26.
//  Copyright © 2017年 YH. All rights reserved.
//
#define RECODER_CLASS_INFO @"recoderVideo"
#define RECODER_UPLOAD_STATE @"uploadState"
#define RECODER_TITLE @"recoderTitle"

#define USER @"user"

#import "SaveDataManager.h"
#import "UserData.h"

static NSString *fileName = @"WeizhiboRecoderVideo.plist";

@implementation SaveDataManager

+ (instancetype)shareSaveRecoder {

    static SaveDataManager *saveManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        saveManager = [[SaveDataManager alloc] init];
        [self creatPlist];

    });
    return saveManager;
}

#pragma creat plist
+ (void)creatPlist {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //get full path
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *plistPath = [documentDirectory stringByAppendingPathComponent:fileName];
    
    //determine whether the file has been created
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        
    } else {//if no plist file is automatically created
        NSMutableDictionary *plist = [[NSMutableDictionary alloc] init];
        //[plist setValue:@"12" forKey:SELECT_REGION];
        [plist writeToFile:plistPath atomically:YES];
    }
}

#pragma mark - plist path
- (NSString *)getPath {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

- (NSString *)getPathWithFileName:(NSString *)fileName {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

- (BOOL)fileIsExistWithFileName:(NSString *)fileName {
    NSString *filePath = [self getPathWithFileName:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return YES;
    }
    return NO;
}

- (NSString *)getUserId {
    
    return [UserData getUser].userID;
}

/********************** region **********************/

- (void)saveRecoderClassInfo:(NSDictionary *)recoderClass {

    NSString *path = [self getPath];
    NSString *userKey = [NSString stringWithFormat:@"%@",[self getUserId]];
    
    NSMutableDictionary *plist = [[[NSMutableDictionary alloc] initWithContentsOfFile:path] mutableCopy];
    
    [plist setValue:recoderClass forKey:userKey];
    [plist writeToFile:path atomically:YES];
}

- (NSDictionary *)getRecoderClassInfo {
    NSString *path = [self getPath];
    NSString *userKey = [NSString stringWithFormat:@"%@",[self getUserId]];
    
    NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:path];
    return plist[userKey];
}


#pragma mark - save and get region

- (void)saveRecoderVodeoClass:(NSArray *)classArr withVideoId:(NSString *)videoId {//保存视频的班级
   
    NSString *videoIdKey = [NSString stringWithFormat:@"%@",videoId];
    NSMutableDictionary *userInfo  = [NSMutableDictionary dictionaryWithDictionary:[self getRecoderClassInfo]];
    NSMutableDictionary *recoderInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo[videoIdKey]];
    
    [recoderInfo setValue:classArr forKey:RECODER_CLASS_INFO];
    
    [userInfo setValue:recoderInfo forKey:videoIdKey];
    [self saveRecoderClassInfo:userInfo];
}

- (void)saveRecoderTitle:(NSString *)title withVideoId:(NSString *)videoId {//保存视频的标题
    NSString *videoIdKey = [NSString stringWithFormat:@"%@",videoId];
    NSMutableDictionary *userInfo  = [NSMutableDictionary dictionaryWithDictionary:[self getRecoderClassInfo]];
    NSMutableDictionary *recoderInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo[videoIdKey]];
    
    [recoderInfo setValue:title forKey:RECODER_TITLE];
    
    [userInfo setValue:recoderInfo forKey:videoIdKey];
    [self saveRecoderClassInfo:userInfo];

}

- (void)saveRecoderUploadState:(BOOL )state withVideoId:(NSString *)videoId {//保存视频的上传状态
    NSString *videoIdKey = [NSString stringWithFormat:@"%@",videoId];
    NSMutableDictionary *userInfo  = [NSMutableDictionary dictionaryWithDictionary:[self getRecoderClassInfo]];
    NSMutableDictionary *recoderInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo[videoIdKey]];
    
    [recoderInfo setValue:[NSNumber numberWithBool:state] forKey:RECODER_UPLOAD_STATE];
    
    [userInfo setValue:recoderInfo forKey:videoIdKey];
    [self saveRecoderClassInfo:userInfo];
}


#pragma mark - get recoder video data

- (NSArray *)getVideoClassesWithVideoId:(NSString *)videoId {//获取本次视频对应的班级
    NSString *videoIdKey = [NSString stringWithFormat:@"%@",videoId];

    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:[self getRecoderClassInfo]];
    NSDictionary *recoderInfo = [NSDictionary dictionaryWithDictionary:userInfo[videoIdKey]];
    return [recoderInfo valueForKey:RECODER_CLASS_INFO];
}

- (BOOL)getRecoderUploadStateWithVideoId:(NSString *)videoId {//获取视频的上传状态

    NSString *videoIdKey = [NSString stringWithFormat:@"%@",videoId];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:[self getRecoderClassInfo]];
    NSDictionary *recoderInfo = [NSDictionary dictionaryWithDictionary:userInfo[videoIdKey]];
    return [[recoderInfo valueForKey:RECODER_UPLOAD_STATE] boolValue];

}

- (NSString *)getRecoderTitleWithVideoId:(NSString *)videoId {//获取视频的标题
    NSString *videoIdKey = [NSString stringWithFormat:@"%@",videoId];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:[self getRecoderClassInfo]];
    NSDictionary *recoderInfo = [NSDictionary dictionaryWithDictionary:userInfo[videoIdKey]];
    return [recoderInfo valueForKey:RECODER_TITLE];
}

#pragma mark - remove recoder video class

- (void)removeRecoderVideoWithVideoId:(NSString *)videoId {
    NSString *videoIdKey = [NSString stringWithFormat:@"%@",videoId];

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[self getRecoderClassInfo]];
    [userInfo removeObjectForKey:videoIdKey];
    [self saveRecoderClassInfo:userInfo];
}



@end
