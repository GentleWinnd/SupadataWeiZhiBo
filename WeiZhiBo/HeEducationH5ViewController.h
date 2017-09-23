//
//  HeEducationH5ViewController.h
//  WeiZhiBo
//
//  Created by YH on 2017/3/29.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeEducationH5ViewController : UIViewController

@property (nonatomic, strong) NSArray *userClassInfo;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) UserRole userRole;

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *openId;

@property (nonatomic, strong) NSString *appToken;
@property (nonatomic, assign) BOOL fromBack;


@end
