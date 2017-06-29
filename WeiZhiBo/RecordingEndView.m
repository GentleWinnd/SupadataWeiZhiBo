//
//  RecordingEndView.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/6/22.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "RecordingEndView.h"

@implementation RecordingEndView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setBtnLayer:self.uploadBtn];
    [self setBtnLayer:self.reomveBtn];
    [self setBtnLayer:self.backRecoderBtn];
    
    
}

- (void)setBtnLayer:(UIButton *) btn {

    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 22;
    btn.layer.borderColor = MAIN_DACK_BLUE_ALERT.CGColor;
    btn.layer.borderWidth = 1;
    
}


- (IBAction)btnAction:(UIButton *)sender {
    if (sender.tag == 1) {// upload
        sender.backgroundColor = MAIN_DACK_BLUE_ALERT;
        self.reomveBtn.backgroundColor = [UIColor clearColor];
        self.backRecoderBtn.backgroundColor = [UIColor clearColor];
        
    } else if (sender.tag == 2) {// remove
        sender.backgroundColor = MAIN_DACK_BLUE_ALERT;
        self.uploadBtn.backgroundColor = [UIColor clearColor];
        self.backRecoderBtn.backgroundColor = [UIColor clearColor];
    
    } else {// back
        sender.backgroundColor = MAIN_DACK_BLUE_ALERT;
        self.reomveBtn.backgroundColor = [UIColor clearColor];
        self.uploadBtn.backgroundColor = [UIColor clearColor];
    }
    if (self.endViewBtnBlock) {
        self.endViewBtnBlock(sender.tag);
    }
}



@end
