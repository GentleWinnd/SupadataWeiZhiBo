//
//  Progress.m
//  ScreeMainTest
//
//  Created by sbtd on 14/11/27.
//  Copyright (c) 2014年 sbtd. All rights reserved.
//

#import "Progress.h"
#import "MBProgressHUD.h"

@implementation Progress

+ (void)progressPlease:(NSString *)please showView:(UIView *)showView {
    if ([please isEqualToString:@"success"]) {
        MBProgressHUD *hub = (MBProgressHUD *)[showView viewWithTag:109];
        hub.removeFromSuperViewOnHide = YES;
        [hub hide:YES afterDelay:0.01];
    } else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:showView animated:YES];
        hud.tag = 109;
        //hud.mode = MBProgressHUDModeCustomView;
        hud.backgroundColor =[UIColor clearColor];
        hud.labelText = [NSString stringWithFormat:@"%@,请稍后...", please];
        hud.margin = 10.f;
    }
}

+ (void)progressShowcontent:(NSString *)content currView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = content;
    hud.labelColor = [UIColor whiteColor];
    hud.labelFont = [UIFont boldSystemFontOfSize:13.0f];
    hud.color = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5];
    hud.cornerRadius = 6;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.0];
}

+ (void)progressShowcontent:(NSString *)content {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = content;
    hud.labelColor = [UIColor whiteColor];
    hud.labelFont = [UIFont boldSystemFontOfSize:13.0f];
    hud.color = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.5];
    hud.cornerRadius = 6;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1.0];
}


@end
