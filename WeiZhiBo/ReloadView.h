//
//  reloadView.h
//  WeiZhiBo
//
//  Created by YH on 2017/3/30.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ReloadView : UIView

@property (nonatomic, copy) void (^ reloadView)();

@end
