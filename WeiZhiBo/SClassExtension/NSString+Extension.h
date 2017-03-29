//
//  NSString+Extension.h
//  KTMExpertCheck
//
//  Created by fangling on 15/9/9.
//  Copyright (c) 2015年 kaitaiming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

+ (NSString *)safeString:(NSString *)string;
+ (BOOL)isBlankString:(NSString *)string;
+ (BOOL)isBlankNumber:(NSNumber *)number;
+ (NSString *)safeNumber:(NSNumber *)number;

/**
 *  trim characters
 */
- (NSString *)stringByReplaceCharacterSet:(NSCharacterSet *)characterset withString:(NSString *)string;

@end
