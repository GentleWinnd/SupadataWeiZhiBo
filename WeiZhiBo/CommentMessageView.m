

//
//  CommentMessageView.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/4/17.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "CommentMessageView.h"
#import "MessageTableViewCell.h"
#import "ParentsTableViewCell.h"

@interface CommentMessageView()<UITableViewDelegate, UITableViewDataSource>

@end

static NSString *CellIdTeacher = @"cellIdOfTeacher";
static NSString *CellIdParents = @"cellIdOfParents";
@implementation CommentMessageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    [self creatMessageTable];
}


- (void)creatMessageTable {

    self.messageTable.delegate = self;
    self.messageTable.dataSource = self;
    [self.messageTable registerNib:[UINib nibWithNibName:@"MessageTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdTeacher];
    [self.messageTable registerNib:[UINib nibWithNibName:@"ParentsTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdParents];
    self.messageTable.rowHeight = UITableViewAutomaticDimension;
    self.messageTable.estimatedRowHeight = 45;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
/*
 
 "TbComment": {
 "userId": 123,
 "linevideoId": "fdg1gf1g54545415",(1老师，3家长)
 "videoType": 1,(视频类型，1：摄像头，2：精选')
 "commentType": 3,('评论类型，1：老师，3：家长')
 "upadateTime": 321,
 "livePeopel": 321,
 "content": "fsdjkgdaga",
 "userName": "李家长",
 "userPic": "http://aservice.139jy.cn/webshare/static/ucenter/user/64066/2100.jpg"
 }
 }
 
 */
    
    
    NSDictionary *messageInfo = [NSDictionary safeDictionary:self.messageArray[indexPath.row]];
    UITableViewCell *cell;
    BOOL isTeacher = [messageInfo[@"isTeacher"] boolValue];
    NSString *name = [NSString safeString:messageInfo[@"userName"]];
    NSString *message = [NSString safeString:messageInfo[@"content"]];;

    if (isTeacher) {
        MessageTableViewCell *TCell = [tableView dequeueReusableCellWithIdentifier:CellIdTeacher forIndexPath:indexPath];
        TCell.messageLabel.attributedText = [self setAttributeString:message subString:name isTeacher:YES];
        cell =TCell;
    } else {
        ParentsTableViewCell *PCell = [tableView dequeueReusableCellWithIdentifier:CellIdParents forIndexPath:indexPath];
        PCell.messageLabel.attributedText = [self setAttributeString:message subString:name isTeacher:NO];
        cell = PCell;
    }
    
    return cell;
}


- (NSAttributedString*)setAttributeString:(NSString *)string subString:(NSString *)subStr isTeacher:(BOOL)isTeacher {

    NSString *contentStr = [NSString stringWithFormat:@"%@:  %@",subStr,string];
    NSMutableAttributedString *MString = [[NSMutableAttributedString alloc] initWithString:contentStr];

    if ([subStr isEqualToString:@""]) {
//        
//        NSString *listStr = [NSString stringWithFormat:@"%@:%@",critics,commentContent];
//        
//        NSRange trueNameRange = [listStr rangeOfString:critics];
//        
//        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:listStr];
//        
//        [AttributedStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20.0] range:trueNameRange];
//        
//        [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:trueNameRange];
//        
//        self.commentLabel.attributedText = AttributedStr;
        return MString;
    
    } else {
        

        /*
         一开始这样取range并不能得到想要的结果
         */
        UIColor *textColor = isTeacher ?MAIN_BLUE_MESSAGE:MAIN_WHITE;
        
        NSRange trueNameRange = [subStr rangeOfString:contentStr];
        [MString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:trueNameRange];
//        [MString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, critics.length)];
        [MString addAttribute:NSForegroundColorAttributeName value:textColor range:trueNameRange];

        
    }
    return MString;
}

- (IBAction)sendMessageAction:(UIButton *)sender {
    
    if (_sendMessage) {
        self.sendMessage(sender.selected);
    }
    
    sender.selected = !sender.selected;
}

@end
