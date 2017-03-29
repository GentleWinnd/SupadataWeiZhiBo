//
//  NSDictionary+Extension.h
//  AgriculturalCollegeStu
//
//  Created by YH on 2017/1/6.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extension)

+ (NSDictionary *)safeDictionary:(NSDictionary *)dictionary;

//convertToJSONData
+ (NSString*)convertToJSONData:(id)infoDict;

//dictionaryWithJsonString
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
@end
