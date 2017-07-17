//
//  ClassNameTableViewCell.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/4/17.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "ClassNameTableViewCell.h"

@implementation ClassNameTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor clearColor];

}

- (IBAction)selectedBtnAction:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if (self.setSelected) {
        self.setSelected(sender.selected);
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
