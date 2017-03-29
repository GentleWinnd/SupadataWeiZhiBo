//
//  KTMError.m
//  KTMExpertCheck
//
//  Created by fangling on 15/10/6.
//  Copyright © 2015年 kaitaiming. All rights reserved.
//

#import "KTMError.h"

@implementation KTMError

//网络错误
+ (NSString *)netError:(NSError *)error {
    NSString *errorString;
    NSInteger errorCode = [error code];
    if (errorCode == -1009) {
        errorString = @"当前网络不可用，请检查你的网络设置";
    } else if (errorCode == -1001) {
        errorString = @"网络连接超时";
    } else if (errorCode == -1004){
        errorString = @"网络未连接，请检查网络设置";
    }else if (errorCode == -1005) {
        errorString = @"网络连接断开";
    } else {
        errorString = @"未知错误";
    }

    return errorString;
}

@end
