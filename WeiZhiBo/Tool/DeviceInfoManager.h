//
//  DeviceInfoManager.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/9/1.
//  Copyright © 2017年 YH. All rights reserved.
//


#import <Foundation/Foundation.h>
#include <sys/param.h>
#include <sys/mount.h>


@interface DeviceInfoManager : NSObject


/**
 获取设备的剩余内存

 @return 剩余内存大小
 */
+ (NSString *) freeDiskSpaceInBytes;
+ (NSString *) freeDiskSpaceInMBS;
/**
 获取设备的总空间
 
 @return 内存大小
 */
+ (NSString *) totalDiskSpaceInBytes;
+ (NSString *) folderSizeAtPath:(NSString*) folderPath;//某个文件夹占用空间的大小

@end
