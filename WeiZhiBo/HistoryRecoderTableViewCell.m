//
//  HistoryRecoderTableViewCell.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/6/22.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "HistoryRecoderTableViewCell.h"

@implementation HistoryRecoderTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)uploadBtnAction:(UIButton *)sender {
    if (self.cellBtnAction) {
        if (sender.tag == 1111) {// upload
            self.cellBtnAction(NO);
        } else {// remove
            self.cellBtnAction(YES);
        }
  
    }
    
}


@end
