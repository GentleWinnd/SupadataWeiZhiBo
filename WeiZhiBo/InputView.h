//
//  InputView.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/4/19.
//  Copyright © 2017年 YH. All rights reserved.
//

@protocol InputViewDelegate <NSObject>

- (void)inputViewTextChanged:(NSInteger)lineNum;

@end

#import <UIKit/UIKit.h>

@interface InputView : UIView

@property (assign, nonatomic) id<InputViewDelegate>delegate;

@property (copy, nonatomic) void(^sendMessage)(NSString *inputMessage);

@property (strong, nonatomic) IBOutlet UITextView *textView;

@end
