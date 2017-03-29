//
//  NSArray+Extension.m
//  AgriculturalCollegeStu
//
//  Created by YH on 2017/1/6.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "NSArray+Extension.h"

@implementation NSArray (Extension)
+ (NSArray*)safeArray:(NSArray *)array {
    if (array == nil || (NSNull *)array == [NSNull null]) {
        return [NSArray array];
    }
    return array;
}

@end
