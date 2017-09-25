//
//  ScreenBtnControl.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/9/8.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "ScreenBtnControl.h"

@implementation ScreenBtnControl

//触摸开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    //获取触摸开始的坐标
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    [self.touchDelegate touchesBeganWithPoint:currentP];
}

//触摸结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    [self.touchDelegate touchesEndWithPoint:currentP];
}

//移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    [self.touchDelegate touchesMoveWithPoint:currentP];
}


@end