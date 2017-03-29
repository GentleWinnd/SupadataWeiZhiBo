//
//  SchoolNameView.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/24.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "SchoolNameView.h"

@implementation SchoolNameView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        
        self.schoolView = [[UILabel alloc] initWithFrame:self.bounds];
        self.schoolView.textColor = MainTextColor_Black;
        self.schoolView.font = [UIFont systemFontOfSize:12];
        self.schoolView.textAlignment = NSTextAlignmentLeft;
        self.schoolView.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
        self.schoolView.backgroundColor = MainThemeColor_LightBlue;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-1, CGRectGetWidth(self.frame), 1)];
        line.backgroundColor = RulesLineColor_LightGray;
        
        [self addSubview:self.schoolView];
        [self addSubview:line];
        
        
    }
    return  self;
}

@end
