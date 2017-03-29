//
//  KTMError.h
//  KTMExpertCheck
//
//  Created by fangling on 15/10/6.
//  Copyright © 2015年 kaitaiming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KTMError : NSObject

//网络错误
+ (NSString *)netError:(NSError *)error;

@end
