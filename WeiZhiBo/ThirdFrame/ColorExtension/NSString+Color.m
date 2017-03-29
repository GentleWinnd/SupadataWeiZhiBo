//
//  NSString+Color.m
//  ProfessionalSurveyDamage
//
//  Created by fangling on 15/11/19.
//  Copyright © 2015年 kaitaiming. All rights reserved.
//

#import "NSString+Color.h"

@implementation NSString (Color)

- (UIColor *)toColor {
    return [UIColor colorWithHexString:self];
}

@end
