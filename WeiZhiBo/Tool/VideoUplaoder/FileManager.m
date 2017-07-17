//
//  FileManager.m
//  UploadPauseAndResume
//
//  Created by KTM-Mac-003 on 16/9/12.
//  Copyright © 2016年 KTM-Mac-003. All rights reserved.
//
#define KTMFILEFRAGMENT @"fileFragment"


#import "FileManager.h"


@implementation FileManager

#pragma mark - 保存上传文件分片信息

- (void)storeFileOperation:(FileStreamOperation*)fileOperation {
    NSData * theData = [NSKeyedArchiver archivedDataWithRootObject:fileOperation];
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:theData forKey:KTMFILEFRAGMENT];
    [userDefaults synchronize];
}

#pragma mark - 获取文件的分片信息

- (FileStreamOperation *)getFileOperation {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * theData = [userDefaults objectForKey:KTMFILEFRAGMENT];
    FileStreamOperation *fileOperation = [NSKeyedUnarchiver unarchiveObjectWithData:theData];
    return fileOperation;
}

#pragma mark - 删除文件的分片信息

- (void)removeFileOperation {
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:KTMFILEFRAGMENT];
}

@end
