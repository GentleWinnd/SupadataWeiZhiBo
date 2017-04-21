//
//  CommentMessageView.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/4/17.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentMessageView : UIView
@property (strong, nonatomic) IBOutlet UIButton *sendMssageBtn;

@property (strong, nonatomic) NSArray *messageArray;

@property (copy, nonatomic) void(^sendMessage)(BOOL selected);


- (void)reloadMessageTable;
@end
