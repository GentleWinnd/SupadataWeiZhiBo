//
//  ContentView.m
//  WeiZhiBo
//
//  Created by YH on 2017/4/10.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "ContentView.h"

@implementation ContentView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self hiddenDoingView:YES];
}

- (void)hiddenDoingView:(BOOL)hidden {

    self.redDotImage.hidden = hidden;
    self.shotingTimeLable.hidden = hidden;
    self.rateLabel.hidden = hidden;
    self.thumbsUpLabel.hidden = hidden;
    self.watchLabel.hidden = hidden;
    self.thumbImg.hidden = hidden;
    self.watchImg.hidden = hidden;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
