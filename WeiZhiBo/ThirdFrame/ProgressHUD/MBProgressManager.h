//
//  MBProgressManager.h
//  AgriculturalCollegeStu
//
//  Created by YH on 2017/1/4.
//  Copyright © 2017年 YH. All rights reserved.
//

typedef NS_ENUM(NSInteger, MBProgressType) {
    MBProgressTypeLittleChrysanthemum,
    MBProgressTypeWithLoadingTitle,

};

#import <Foundation/Foundation.h>


@interface MBProgressManager : NSObject

@property (strong, nonatomic) UIView *showView;
@property (assign, nonatomic) MBProgressType progressType;


/**
 Show progress no text
 */
- (void)showProgress;
- (void)hiddenProgress;


/**
 show loading title Porgress

 @param title title
 */
- (void)loadingWithTitleProgress:(NSString *)title;

@end
