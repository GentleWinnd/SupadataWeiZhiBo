//
//  DeviceDetailManager.h
//  AgriculturalCollegeStu
//
//  Created by YH on 2017/2/22.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceDetailManager : NSObject

/**
 get SystemVersion
 
 @return <#return value description#>
 */
+ (NSString *)getSystemVersion;

/**
 get SystemName
 
 @return <#return value description#>
 */
+ (NSString *)getSystemName;

/**
 get SystemLocalizedModel
 
 @return <#return value description#>
 */
+ (NSString *)getSystemLocalizedModel;

/**
 get DeviceModel
 
 @return <#return value description#>
 */
+ (NSString *)getSystemDeviceModel;

/**
 get DeviceName

 @return <#return value description#>
 */
+ (NSString *)getSystemDeviceName;


/**
 get devicePlatForm
 
 @return <#return value description#>
 */

+ (NSString *)getDevicePlatForm;
@end
