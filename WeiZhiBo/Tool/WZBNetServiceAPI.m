//
//  WZBNetServiceAPI.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/23.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "KTMWebService.h"
#import "WZBNetServiceAPI.h"

@implementation WZBNetServiceAPI

// 登录用户
+ (void)postLoginWithParameters:(id)parameters
                       success:(void(^)(id responseObject))success
                       failure:(void(^)(NSError *error))failure {
    NSString *urlStr = @"appInfo/login";
    NSString *URLString = [NSString stringWithFormat:@"%@%@", HOST_URL, urlStr];
    [KTMWebService CMGetWithURL:URLString parameters:parameters sucess:^(id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

//通过和宝贝进去验证登录

+ (void)postLoginByHeBabyWithParameters:(id)parameters
                                success:(void(^)(id responseObject))success
                                failure:(void(^)(NSError *error))failure {//setAccess_token("0fc010d482d83c68ae2bfdf498ff108f
    NSString *urlStr = [NSString stringWithFormat:@"pc/pLogin?flag=%@&access_token=%@&open_id=%@",@"2",parameters[@"access_token"],parameters[@"open_id"]];
    NSString *URLString = [NSString stringWithFormat:@"%@%@", HOST_URL, urlStr];
    [KTMWebService CMGetWithURL:URLString parameters:nil sucess:^(id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

//注册直播手机
+ (void)postRegisterPhoneMicroLiveWithParameters:(id)parameters
                                         success:(void(^)(id reponseObject))success
                                         failure:(void(^)(NSError *error))failure {
    
    NSString *urlStr = @"camera/getPhonePushUrl";
    NSString *URLString = [NSString stringWithFormat:@"%@%@", HOST_URL, urlStr];
    [KTMWebService CMGetWithURL:URLString parameters:parameters sucess:^(id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - get login tohen by third app

+ (void)getAppLoginTokenByThirdAppWithParameters:(id)parameters
                                         success:(void(^)(id reponseObject))success
                                         failure:(void(^)(NSError *error))failure {
    
    NSString *urlStr = @"pc/appLogin";
    NSString *URLString = [NSString stringWithFormat:@"%@%@", HOST_URL, urlStr];
    [KTMWebService CMGetWithURL:URLString parameters:parameters sucess:^(id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

// get watch people number

+ (void)getWatchingNumberWithParameters:(id)parameters
                                success:(void(^)(id reponseObject))success
                                failure:(void(^)(NSError *error))failure {
    
    NSString *urlStr = [NSString stringWithFormat:@"Linevideo/getLiveInfo?id=%@",parameters[@"id"]];
    NSString *URLString = [NSString stringWithFormat:@"%@%@", HOST_URL, urlStr];
    [KTMWebService CMGetWithURL:URLString parameters:parameters sucess:^(id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


//sendGroupMessage

+ (void)getGroupSendMassageWithParameters:(id)parameters
                                  success:(void(^)(id reponseObject))success
                                  failure:(void(^)(NSError *error))failure {
    
//    NSString *urlStr = [NSString stringWithFormat:@"Linevideo/sendMessage?access_token=%@&open_id=%@&flag=%@&classId=%@&className=%@",parameters[@"access_token"],parameters[@"open_id"],parameters[@"flag"],parameters[@"classId"],parameters[@"className"]];
     NSString *urlStr = [NSString stringWithFormat:@"Linevideo/sendMessage"];
    NSString *URLString = [NSString stringWithFormat:@"%@%@", HOST_URL, urlStr];
    [KTMWebService CMGetWithURL:URLString parameters:parameters sucess:^(id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

//上传直播状态
+ (void)postZhiBoStateMessageWithParameters:(id)parameters
                                    success:(void(^)(id reponseObject))success
                                    failure:(void(^)(NSError *error))failure {
 
    NSString *urlStr = [NSString stringWithFormat:@"camera/liveNotice?id=%@&flag=%@&calssId=%@&sumTime=%@&userId=%@&liveTitle=%@&userName=%@&schoolId=%@&liveType=%@&count=%@",parameters[@"id"],parameters[@"flag"],parameters[@"classId"],parameters[@"sumTime"],parameters[@"userId"],parameters[@"liveTitle"],parameters[@"userName"],parameters[@"schoolId"],parameters[@"liveType"],parameters[@"count"]];
    NSString *URLString = [NSString stringWithFormat:@"%@%@", HOST_URL, urlStr];
    NSString *URL = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSString *URLString = [NSString stringWithFormat:@"%@%@", HOST_URL,@"rootSchool/liveNotice"];

    [KTMWebService CMGetWithURL:URL parameters:nil sucess:^(id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

//测试版本号

+ (void)getAPPVersionWithParameters:(id)parameters
                            success:(void(^)(id reponseObject))success
                            failure:(void(^)(NSError *error))failure {
    
    NSString *urlStr = [NSString stringWithFormat:@"appInfo/getNewestIOSInfo?flag=%@",[parameters allValues].lastObject];
    NSString *URLString = [NSString stringWithFormat:@"%@%@", HOST_URL,urlStr];
    
    [KTMWebService CMGetWithURL:URLString parameters:nil sucess:^(id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}



@end
