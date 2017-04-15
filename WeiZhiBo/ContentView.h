//
//  ContentView.h
//  WeiZhiBo
//
//  Created by YH on 2017/4/10.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContentView : UIView


@property (strong, nonatomic) IBOutlet UIImageView *redDotImage;

@property (strong, nonatomic) IBOutlet UILabel *rateLabel;
@property (strong, nonatomic) IBOutlet UILabel *thumbsUpLabel;
@property (strong, nonatomic) IBOutlet UILabel *watchLabel;
@property (strong, nonatomic) IBOutlet UILabel *shotingTimeLable;
@property (strong, nonatomic) IBOutlet UILabel *classLabel;
@property (strong, nonatomic) IBOutlet UIImageView *watchImg;
@property (strong, nonatomic) IBOutlet UIImageView *thumbImg;

- (void)hiddenDoingView:(BOOL)hidden;
@end
