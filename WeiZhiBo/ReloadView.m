//
//  reloadView.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/30.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "ReloadView.h"

@implementation ReloadView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (IBAction)reloadbtn:(UIButton *)sender {
    
    if (_reloadView) {
        self.reloadView();
    }
}


- (void)setLoadState:(LoadFailStatu)loadState {

    self.loadImageView.image = [UIImage imageNamed:[self getLoadImgaeStr:loadState]];
}

- (NSString *)getLoadImgaeStr:(LoadFailStatu)loadState {
    NSString *str = nil;
    switch (loadState) {
        case LoadFailStatuNet:
            str = @"";
            break;
        case LoadFailStatuData:
            str = @"";
            break;
        case LoadFailStatuNoData:
            str = @"";
            break;

        default:
            break;
    }
    return str;
}

@end
