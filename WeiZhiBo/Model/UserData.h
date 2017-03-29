//
//  userData.h
//  KTMExpertCheck
//
//  Created by tongrd on 15/11/4.
//  Copyright © 2015年 kaitaiming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"


#define USERNAME @"username" //token
#define USERID @"id"
#define PASSWORD @"password"
#define NICKNAME @"nickName"

@class User;

@interface UserData : NSObject

#pragma mark - save
/**
 * save login data
 */
+ (void)saveLoginData:(NSDictionary *)loginData;

/**
 * save refresh token data
 */
+ (void)saveRefreshTokenData:(NSDictionary *)refreshData;

#pragma mark - get

/**
 * get user
 */
+ (User *)getUser;
+ (void)saveUserData:(NSDictionary *)userData;

+ (void)saveUserInfo:(NSDictionary *)userInfo;

+ (NSString *)getAccessToken;

+ (NSDate *)getAccessTokenDate;

+ (NSString *)getRefreshToken;

/**
 *  receive the data returned after a successful user login
 */
+ (void)receiveData:(NSDictionary *)data password:(NSString *)password;

/**
 *  storing user data
 */
+ (void)storeUserData:(User *)KTMUser;

/**
 *  empty the user data
 */
+ (void)removeUserData;

/**
 *  get the user ID
 */
+ (NSString *)getUserID;

/*
 *  get the user login name
 */
+ (NSString *)getUserName;

/**
 * get user password
 */
+ (NSString *)getUserPassword;

/**
 * saved user role
 */

+ (void)savedUserRole:(UserRole )role;

/**
 * save user quit time
 */
+ (void)savedUserQuitTimer:(NSDate *)quitTime;

/**
 * get user quit time
 */
+ (NSDate *)getUserQuitTime;

+ (void)saveUserHeaderPortrait:(NSData*)imageData;


@end
