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
    NSString *urlStr = @"pc/phoneLogin";
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

//通过和宝贝进去

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
    
    NSString *urlStr = @"rootSchool/getPhonePushUrl";
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



@end
