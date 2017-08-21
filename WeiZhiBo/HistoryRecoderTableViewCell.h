//
//  HistoryRecoderTableViewCell.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/6/22.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryRecoderTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *classLabel;
@property (strong, nonatomic) IBOutlet UIButton *uploadBtn;
@property (strong, nonatomic) IBOutlet UIButton *removeBtn;
@property (strong, nonatomic) IBOutlet UIButton *dotBtn;
@property (copy, nonatomic) void(^cellBtnAction)(BOOL remove);
@property (strong, nonatomic) IBOutlet UILabel *uploadRate;

@end
