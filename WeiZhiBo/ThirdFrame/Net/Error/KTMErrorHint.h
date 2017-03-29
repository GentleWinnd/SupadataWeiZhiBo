//
//  KTMErrorHint.h
//  KTMExpertCheck
//
//  Created by Jarvan on 15/9/30.
//  Copyright © 2015年 kaitaiming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface KTMErrorHint : NSObject
//网络错误
+ (void)showNetError:(NSError *)error inView:(UIView *)superView;

@end
