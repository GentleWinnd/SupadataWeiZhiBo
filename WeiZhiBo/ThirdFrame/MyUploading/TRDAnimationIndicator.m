//
//  TRDAnimationIndicator.m
//  KTMExpertCheck
//
//  Created by Jarvan on 15/9/21.
//  Copyright (c) 2015年 kaitaiming. All rights reserved.
//

#import "TRDAnimationIndicator.h"


@interface TRDAnimationIndicator ()
{
    NSTimer *timer;
    int currentTime;
    CGRect proframe;
}
@end
@implementation TRDAnimationIndicator

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        proframe = frame;
        CGFloat width = frame.size.width;
        CGFloat height = frame.size.height;
        
        self.backgroundColor = MAIN_GRAYAWHITE_BACKGROUND;
        self.userInteractionEnabled = YES;
        self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1"]];
        CGRect frame = self.imageView.frame;
        frame.size = CGSizeMake(CGRectGetWidth(frame)*0.8, CGRectGetHeight(frame)*0.8);
        self.imageView.frame = frame;
        
        self.imageView.center = CGPointMake(width/2, height/2-30);
        
        [self addSubview:self.imageView];
        //设置动画帧
        self.imageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"1"],
                                         [UIImage imageNamed:@"2"],
                                         [UIImage imageNamed:@"3"],
                                         [UIImage imageNamed:@"4"],
                                         [UIImage imageNamed:@"5"],
                                          
                                          [UIImage imageNamed:@"6"],
                                          [UIImage imageNamed:@"7"],
                                          [UIImage imageNamed:@"8"],
                                          [UIImage imageNamed:@"9"],
                                          [UIImage imageNamed:@"10"],

                                          [UIImage imageNamed:@"11"],
                                          [UIImage imageNamed:@"12"],
                                          [UIImage imageNamed:@"13"],

                                          nil ];
        self.Infolabel = [[UILabel alloc] init];
        self.Infolabel.frame = CGRectMake(0, 0,100, 20);
        self.Infolabel.center = CGPointMake(width/2, height/2+CGRectGetHeight(self.imageView.frame)/2+20-30);
        self.Infolabel.backgroundColor = [UIColor clearColor];
        self.Infolabel.textAlignment = NSTextAlignmentCenter;
        self.Infolabel.textColor = MAIN_LIGHTBLACK_TEXT;
        self.Infolabel.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:self.Infolabel];
        
        currentTime = 0;
    }
    return self;
}

- (void)startAnimation {
    CGFloat width = proframe.size.width;
    CGFloat height = proframe.size.height;
    UIImage *image = [UIImage imageNamed:@"1"];
    CGRect frame =  self.imageView.frame;
    self.imageView.frame = CGRectMake(frame.origin.x, frame.origin.y, image.size.width, image.size.height);
    self.Infolabel.center = CGPointMake(width/2, height/2+CGRectGetHeight(self.imageView.frame)/2+20-30);

    [self doAnimation];
}

- (void)stopAnimation {
    [self.imageView stopAnimating];
    [self removeFromSuperview];
    [self stopTimer];

}

-(void)doAnimation {
    self.Infolabel.text = @"宝宝努力加载中...";
    // 设置动画总时间
    self.imageView.animationDuration = 1.6f;
    // 设置重复次数,0表示无限次
    self.imageView.animationRepeatCount = 0;
    // 开始动画
    [self.imageView startAnimating];
//    [self createTimer];
}

- (void)stopAnimationWithLoadText:(NSString *)text withType:(BOOL)type; {
    self.Infolabel.text = text;
//    [self stopTimer];
    if(type) {
        [UIView animateWithDuration:0.3f animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self.imageView stopAnimating];
            [self removeFromSuperview];
            self.alpha = 1;
        }];
    } else {
        UIImage *image = [UIImage imageNamed:@"jaizaishibai"];
        CGRect frame =  self.imageView.frame;
        self.imageView.frame = CGRectMake(frame.origin.x, frame.origin.y, image.size.width, image.size.height);
        self.Infolabel.center = CGPointMake(image.size.width/2, image.size.height/2+60+20-30);
        
        [self.imageView stopAnimating];
        [self.imageView setImage:image];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadData:)];
        [self addGestureRecognizer:tapGesture];
        self.userInteractionEnabled = YES;
    }
}

- (void)loadData:(UIGestureRecognizer *)gesture  {
    [self.delegate reloadDataWithAnimationView:self];
}

#pragma mark - create timer
- (void)createTimer {
    if (timer) {
        [timer fire];
        return;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0f/3 target:self selector:@selector(startTimer) userInfo:@"什么鬼" repeats:YES];
}

- (void)startTimer {
    currentTime++;

    if (currentTime%3==1) {
        self.Infolabel.text = @"加载中.";
    }
    if (currentTime%3==2) {
        self.Infolabel.text = @"加载中..";

    }
    if (currentTime%3==0) {
        self.Infolabel.text = @"加载中...";

    }
}

- (void)stopTimer {
    [timer invalidate];
    timer = nil;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
