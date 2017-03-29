//
//  Progress.h
//  ScreeMainTest
//
//  Created by sbtd on 14/11/27.
//  Copyright (c) 2014年 sbtd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Progress : NSObject

+ (void)progressPlease:(NSString *)please showView:(UIView *)showView;

+ (void)progressShowcontent:(NSString *)content currView:(UIView *)view;

/**
 show content in window

 @param content <#content description#>
 */
+ (void)progressShowcontent:(NSString *)content;
@end
