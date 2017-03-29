//
//  userData.m
//  KTMExpertCheck
//
//  Created by tongrd on 15/11/4.
//  Copyright © 2015年 kaitaiming. All rights reserved.
//
#define USER_DATA @"userData"

#import "UserData.h"
#import "User.h"

@implementation UserData


#pragma mark - save login data

+ (void)saveLoginData:(NSDictionary *)loginData {
    User *user = [[User alloc] init];
    user.userName = [loginData valueForKey:USERNAME];
    user.userPass = [loginData valueForKey:PASSWORD];
    user.accessToken = [loginData valueForKey:ACCESS_TOKEN];
    user.expiresIn = [[loginData valueForKey:EXPIRES_IN] intValue];
    user.refreshToken = [loginData valueForKey:REFRESH_TOKEN];
    user.accessTokenDate = [loginData valueForKey:ACCESS_TOKEN_DATE];
    [self storeUserData:user];
}

#pragma mark -  save refresh token data

+ (void)saveRefreshTokenData:(NSDictionary *)refreshData {
    User *user = [self getUser];
    user.accessToken = [refreshData valueForKey:ACCESS_TOKEN];
    user.expiresIn = [[refreshData valueForKey:EXPIRES_IN] intValue];
    user.refreshToken = [refreshData valueForKey:REFRESH_TOKEN];
    user.accessTokenDate = [refreshData valueForKey:ACCESS_TOKEN_DATE];
    [self storeUserData:user];
}

#pragma mark -  get

#pragma mark -  get user

+ (User *)getUser {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * theData = [userDefaults objectForKey:USER_DATA];
    User *user = [NSKeyedUnarchiver unarchiveObjectWithData:theData];
    return user;
}

#pragma mark -  save user data

+ (void)saveUserData:(NSDictionary *)userData {
    User * user = [[User alloc] init];
    user.loginStatus = YES;
    user.userName = [userData valueForKey:USERNAME];
    user.userPass = [userData valueForKey:PASSWORD];
    user.userID = [userData valueForKey:USERID];
    user.nickName = [userData valueForKey:NICKNAME];
    
    [self storeUserData:user];
}


#pragma mark -  save user info

+ (void)saveUserInfo:(NSDictionary *)userInfo {
    User *user = [self getUser];
    user.userID = [userInfo valueForKey:@"id"];
    user.userName = [userInfo valueForKey:@"userName"];
    [self storeUserData:user];
}

#pragma mark -  reveive user data

+ (void)receiveData:(NSDictionary *)data password:(NSString *)password {
    User * user = [[User alloc] init];
    user.loginStatus = YES;
    user.userName = [data objectForKey:@"loginName"];
    user.userPass = password;
    user.userID = [data objectForKey:@"id"];
    user.nickName = [data objectForKey:@"nickName"];
    
    [self storeUserData:user];
}

#pragma mark -  store user data

+ (void)storeUserData:(User *)KTMUser {
    NSData * theData = [NSKeyedArchiver archivedDataWithRootObject:KTMUser];
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:theData forKey:USER_DATA];
    [userDefaults synchronize];
}

#pragma mark -  get user ID

+ (NSString *)getUserID {
    User *user = [self getUser];
    return user.userID;
}

#pragma mark -  get user name

+ (NSString *)getUserName {
    User *user = [self getUser];
    return user.userName;
}

#pragma mark -  get userRole

+ (UserRole)getUserRole {
    User *user = [self getUser];
    return user.userRole;
}

#pragma mark -  get access token

+ (NSString *)getAccessToken {
    User *user = [self getUser];
    return user.accessToken;
}

#pragma mark -  get access token date

+ (NSDate *)getAccessTokenDate {
    User *user = [self getUser];
    return user.accessTokenDate;
}

#pragma mark -  get refresh token

+ (NSString *)getRefreshToken {
    User *user = [self getUser];
    return user.refreshToken;
}

#pragma mark -  saved user role

+ (void)savedUserRole:(UserRole )role {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * theData = [userDefaults objectForKey:USER_DATA];
    User * user = [NSKeyedUnarchiver unarchiveObjectWithData:theData];
    user.userRole = role;
    [self storeUserData:user];
}

#pragma mark -  saved user role

+ (void)saveUserHeaderPortrait:(NSData *)imageData {
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * theData = [userDefaults objectForKey:USER_DATA];
    User * user = [NSKeyedUnarchiver unarchiveObjectWithData:theData];
    user.userIcon = imageData;
    [self storeUserData:user];
}

#pragma mark -  saved user gesture pass

+ (void)savedUserGesturePass:(NSString *)gesturePass {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * theData = [userDefaults objectForKey:USER_DATA];
    User * user = [NSKeyedUnarchiver unarchiveObjectWithData:theData];

    [self storeUserData:user];
}


#pragma mark -  deleted user gesture pass 

+ (void)deletedUserGesturePass {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * theData = [userDefaults objectForKey:USER_DATA];
    User * user = [NSKeyedUnarchiver unarchiveObjectWithData:theData];

    [self storeUserData:user];
}

#pragma mark -  get user password 

+ (NSString *)getUserPassword {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * theData = [userDefaults objectForKey:USER_DATA];
    User * user = [NSKeyedUnarchiver unarchiveObjectWithData:theData];
    return user.userPass;
}

#pragma mark -  saved user quit time

+ (void)savedUserQuitTimer:(NSDate *)quitTime {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * theData = [userDefaults objectForKey:USER_DATA];
    User * user = [NSKeyedUnarchiver unarchiveObjectWithData:theData];
    user.userQuitTime = quitTime;
    [self storeUserData:user];
}

#pragma mark -  get user quit time

+ (NSDate *)getUserQuitTime {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSData * theData = [userDefaults objectForKey:USER_DATA];
    User * user = [NSKeyedUnarchiver unarchiveObjectWithData:theData];
    return user.userQuitTime;
}


#pragma mark -  remove user data

+ (void)removeUserData {
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault removeObjectForKey:USER_DATA];
}

@end
