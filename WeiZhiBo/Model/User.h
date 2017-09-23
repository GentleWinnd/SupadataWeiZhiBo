//
//  User.m
//  KTMUser
//
//  Created by tongrd on 15/12/10.
//  Copyright (c) 2015年 tongrd. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ACCESS_TOKEN @"AccessToken"
#define EXPIRES_IN @"expires_in"
#define REFRESH_TOKEN @"refresh_token"
#define ACCESS_TOKEN_DATE @"access_token_date"

@interface User : NSObject<NSCoding>

@property (nonatomic, retain) NSString * userName;  //用户昵称
@property (nonatomic, retain) NSString * userPass;  //用户密码
@property (nonatomic, retain) NSString * userID;    //用户ID
@property (nonatomic, copy) NSString * IMUserID;    //聊天ID
@property (nonatomic, assign) UserRole userRole;   //用户角色

@property (nonatomic, copy) NSString *avater;
@property (nonatomic, retain) NSData   * userIcon;  //用户头像
@property (nonatomic, retain) NSString * nickName;  //用户真实姓名
@property (nonatomic, retain) NSString * userPhone; //用户手机
@property (nonatomic, retain) NSString * userToken; //登陆token
@property (nonatomic, assign) BOOL loginStatus;     //登陆状态
@property (nonatomic, retain) NSDate * userQuitTime;//用户退出时间
@property (nonatomic, copy) NSString *Description;//用户描述
@property (nonatomic, copy) NSString *period;//用户课程级数
@property (nonatomic, copy) NSString *CourseType;//课程类型

@property (nonatomic, copy) NSString *openId;
@property (nonatomic, copy) NSString *openToken;



@property (nonatomic, retain) NSString *accessToken; // access token
@property (nonatomic, assign) int expiresIn; // access token 有效时间
@property (nonatomic, retain) NSString *refreshToken; // refresh token
@property (nonatomic, retain) NSDate *accessTokenDate; // get access token date

@end
