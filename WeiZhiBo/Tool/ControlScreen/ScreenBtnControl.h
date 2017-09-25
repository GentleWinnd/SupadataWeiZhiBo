//
//  ScreenBtnControl.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/9/8.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ZYLButtonDelegate <NSObject>

/**
 * 开始触摸
 */
- (void)touchesBeganWithPoint:(CGPoint)point;

/**
 * 结束触摸
 */
- (void)touchesEndWithPoint:(CGPoint)point;

/**
 * 移动手指
 */
- (void)touchesMoveWithPoint:(CGPoint)point;


@end

@interface ScreenBtnControl : UIButton

/**
 * 传递点击事件的代理
 */
@property (weak, nonatomic) id <ZYLButtonDelegate> touchDelegate;


@end
