//
//  InputView.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/4/19.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "InputView.h"


@interface InputView()<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *senderBtn;

@end



@implementation InputView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textView.delegate = self;

}

- (void)textViewDidChange:(UITextView *)textView {
    float textViewWidth=self.textView.frame.size.width;//取得文本框高度
    NSString *content=textView.text;
    NSDictionary *dict=@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]};
    CGSize contentSize=[content sizeWithAttributes:dict];//计算文字长度
    float numLine=ceilf(contentSize.width/textViewWidth); //计算当前文字长度对应的行数
    _messageStr = textView.text;
    [self.delegate inputViewTextChanged:numLine];

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [textView resignFirstResponder];
    
        if (self.sendMessage) {
            self.sendMessage(_messageStr);
        }
        
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}


- (IBAction)sendBtnAction:(UIButton *)sender {
    
//    if (self.sendMessage) {
//        self.sendMessage(self.messageStr);
//        [self.textView resignFirstResponder];
//    }
    
}




@end
