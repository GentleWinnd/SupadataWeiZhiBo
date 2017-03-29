//
//  UIColor+HexString.h
//  ProfessionalSurveyDamage
//
//  Created by fangling on 15/11/19.
//  Copyright © 2015年 kaitaiming. All rights reserved.
//

/*
 
 Taken from this StackOverflow Answer: http://stackoverflow.com/a/7180905/224988
 
 */

#import <UIKit/UIKit.h>

@interface UIColor (HexString)

+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end
