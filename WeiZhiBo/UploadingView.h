//
//  UploadingView.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/8/18.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBCycleView.h"
@interface UploadingView : UIView

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UIButton *cancleBtn;
@property (strong, nonatomic) IBOutlet TBCycleView *circlProgress;
@property (strong, nonatomic) IBOutlet UILabel *ratelabel;
@property (strong, nonatomic) IBOutlet UILabel *uploadStateLabel;
@property (strong, nonatomic) IBOutlet UILabel *allTime;
@property (strong, nonatomic) IBOutlet UILabel *classNameLabel;

@property (copy, nonatomic) void (^cancleBtnBlock)();

@end
