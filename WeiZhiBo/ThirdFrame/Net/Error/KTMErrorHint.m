//
//  KTMErrorHint.m
//  KTMExpertCheck
//
//  Created by Jarvan on 15/9/30.
//  Copyright © 2015年 kaitaiming. All rights reserved.
//

#import "KTMErrorHint.h"
#import "KTMError.h"
#import "Progress.h"

@implementation KTMErrorHint
//网络错误
+ (void)showNetError:(NSError *)error inView:(UIView *)superView {
    NSString *errorMessage = [KTMError netError:error];
    [Progress progressShowcontent:errorMessage currView:superView];
}

@end
