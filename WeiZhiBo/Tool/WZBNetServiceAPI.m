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


//获取观看人数接口
//地址：ssm/Linevideo/getLiveInfo
//参数：id 直播摄像头id
//返回结果：linevideo对象
//点赞人数：givePraise
//观看人数：livePeople
//注册直播手机
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

//群发短信
//ssm/Linevideo/sendMessage
//access_token
//open_id
//flag 安卓端传1，IOS端传2
//classId
//className 学校+班级名字
/*
 @"access_token":@"0fc010d482d83c68ae2bfdf498ff108f",
 @"open_id":@"38fbb5cf11a22e96747eb07421056cce",
 @"flag=1&classId":@"10606073",
 @"className":@"11111"
 */
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
    
    NSString *urlStr = [NSString stringWithFormat:@"rootSchool/liveNotice?id=%@&flag=%@&calssId=%@&sumTime=%@&userId=%@",parameters[@"id"],parameters[@"flag"],parameters[@"classid"],parameters[@"sumTime"],parameters[@"userId"]];
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



@end
