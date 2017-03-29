//
//  User.m
//  KTMUser
//
//  Created by tongrd on 15/12/10.
//  Copyright (c) 2015年 tongrd. All rights reserved.
//

#import "User.h"

@implementation User

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.userID forKey:@"userId"];
    [aCoder encodeObject:self.userPass forKey:@"userPass"];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.userRole] forKey:@"userRole"];
    [aCoder encodeObject:self.IMUserID forKey:@"IMUserID"];
    [aCoder encodeObject:self.avater forKey:@"avatar"];
    
    [aCoder encodeObject:self.nickName forKey:@"nickName"];
    [aCoder encodeBool:self.loginStatus forKey:@"loginStatus"];
    [aCoder encodeObject:self.userPhone forKey:@"userPhone"];
    [aCoder encodeObject:self.userIcon forKey:@"userIcon"];
    [aCoder encodeObject:self.userToken forKey:@"userToken"];
    [aCoder encodeObject:self.userQuitTime forKey:@"userQuitTime"];
    
    [aCoder encodeObject:self.accessToken forKey:ACCESS_TOKEN];
    [aCoder encodeObject:[NSNumber numberWithInt:self.expiresIn] forKey:EXPIRES_IN];
    [aCoder encodeObject:self.refreshToken forKey:REFRESH_TOKEN];
    [aCoder encodeObject:self.accessTokenDate forKey:ACCESS_TOKEN_DATE];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.userName = [aDecoder decodeObjectForKey:@"userName"];
        self.userID = [aDecoder decodeObjectForKey:@"userId"];
        self.userPass = [aDecoder decodeObjectForKey:@"userPass"];
        self.userRole = [[aDecoder decodeObjectForKey:@"userRole"] integerValue];
        self.IMUserID = [aDecoder decodeObjectForKey:@"IMUserID"];
        self.avater = [aDecoder decodeObjectForKey:@"avatar"];
        
        self.nickName = [aDecoder decodeObjectForKey:@"nickName"];
        self.loginStatus = [aDecoder decodeBoolForKey:@"loginStatus"];
        self.userPhone = [aDecoder decodeObjectForKey:@"userPhone"];
        self.userIcon = [aDecoder decodeObjectForKey:@"userIcon"];
        self.userToken = [aDecoder decodeObjectForKey:@"userToken"];
        self.userQuitTime = [aDecoder decodeObjectForKey:@"userQuitTime"];
        
        self.accessToken = [aDecoder decodeObjectForKey:ACCESS_TOKEN];
        self.expiresIn = [[aDecoder decodeObjectForKey:EXPIRES_IN] intValue];
        self.refreshToken = [aDecoder decodeObjectForKey:REFRESH_TOKEN];
        self.accessTokenDate = [aDecoder decodeObjectForKey:ACCESS_TOKEN_DATE];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@, %@, %d, %@, %@, %tu", _userID, _IMUserID, _userName , _userPass, _nickName, _userIcon, _userToken, _accessToken, _expiresIn, _refreshToken, _accessTokenDate,_userRole];
}

@end
