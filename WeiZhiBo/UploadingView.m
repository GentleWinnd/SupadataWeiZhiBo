//
//  UploadingView.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/8/18.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "UploadingView.h"

@implementation UploadingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)cancleBtnAction:(UIButton *)sender {
    
    if (self.cancleBtnBlock) {
        self.cancleBtnBlock();
    }
}

@end
