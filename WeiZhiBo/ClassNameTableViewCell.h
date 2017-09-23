//
//  ClassNameTableViewCell.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/4/17.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClassNameTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *classNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *selectedBtn;
@property (strong, nonatomic) void(^setSelected)(BOOL sel);


@end
