//
//  WZBNetService.h
//  WeiZhiBo
//
//  Created by YH on 2017/3/23.
//  Copyright © 2017年 YH. All rights reserved.
//
/*********************API address*********************/
//接口地址：http://live.sch.supadata.cn/ssm/pc/phoneLogin
#define HOST_URL @"http://live.sch.supadata.cn/ssm/"
//#define HOST_URL @"http://live.sch.supadata.cn:9080/"
//#define HOST_URL @"http://baihongyu1234567.xicp.io/ssm/pc/"

#import <Foundation/Foundation.h>

@interface WZBNetServiceAPI : NSObject

/************************* user ***********************/

// 登录用户
+ (void)postLoginWithParameters:(id)parameters
                        success:(void(^)(id responseObject))success
                        failure:(void(^)(NSError *error))failure;
//通过和宝贝进去

+ (void)postLoginByHeBabyWithParameters:(id)parameters
                                success:(void(^)(id responseObject))success
                                failure:(void(^)(NSError *error))failure;

//注册直播手机
+ (void)postRegisterPhoneMicroLiveWithParameters:(id)parameters
                                         success:(void(^)(id reponseObject))success
                                         failure:(void(^)(NSError *error))failure;
@end
