//
//  NSString+Extension.m
//  KTMExpertCheck
//
//  Created by fangling on 15/9/9.
//  Copyright (c) 2015年 kaitaiming. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

+ (NSString *)safeString:(NSString *)string {
    if ([NSString isBlankString:string]) {
        return @"";
    }else{
        return string;
    }
}

+ (BOOL)isBlankString:(NSString *)string {
    
    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    if (    [string isEqual:nil]
        ||  [string isEqual:Nil]){
        return YES;
    }
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    if (0 == [string length]){
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    if([string isEqualToString:@"(null)"]){
        return YES;
    }
    if([string isEqualToString:@"<null>"]){
        return YES;
    }
    
    return NO;
}

+ (NSString *)safeNumber:(NSNumber *)number {
    if ([NSString isBlankNumber:number]) {
        return @"";
    }
    return [number stringValue];
}

+ (BOOL)isBlankNumber:(NSNumber *)number{
    NSString *string = [NSString stringWithFormat:@"%@", number];
    
    if ([string isEqualToString:@"0"]) {
        return YES;
    }
    
    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    if (    [string isEqual:nil]
        ||  [string isEqual:Nil]){
        return YES;
    }
    if (0 == [string length]){
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    if([string isEqualToString:@"(null)"]){
        return YES;
    }
    if([string isEqualToString:@"<null>"]){
        return YES;
    }

    return NO;
}

- (NSString *)stringByReplaceCharacterSet:(NSCharacterSet *)characterset withString:(NSString *)string {
    NSString *result = self;
    NSRange range = [result rangeOfCharacterFromSet:characterset];
    
    while (range.location != NSNotFound) {
        result = [result stringByReplacingCharactersInRange:range withString:string];
        range = [result rangeOfCharacterFromSet:characterset];
    }
    return result;
}


@end
