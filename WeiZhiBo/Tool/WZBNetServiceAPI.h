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
#define HOST_URL_IN @"http://live.sch.supadata.cn:9080/ssm/"
#define HOST_URL_LOCAL @"http://baihongyu1234567.xicp.io/ssm/"

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

//群发短信
+ (void)getGroupSendMassageWithParameters:(id)parameters
                                  success:(void(^)(id reponseObject))success
                                  failure:(void(^)(NSError *error))failure;

#pragma mark - get login tohen by third app

+ (void)getAppLoginTokenByThirdAppWithParameters:(id)parameters
                                         success:(void(^)(id reponseObject))success
                                         failure:(void(^)(NSError *error))failure;

//获取观看人数接口
+ (void)getWatchingNumberWithParameters:(id)parameters
                                success:(void(^)(id reponseObject))success
                                failure:(void(^)(NSError *error))failure;

//上传直播状态
+ (void)postZhiBoStateMessageWithParameters:(id)parameters
                                    success:(void(^)(id reponseObject))success
                                    failure:(void(^)(NSError *error))failure;
@end
