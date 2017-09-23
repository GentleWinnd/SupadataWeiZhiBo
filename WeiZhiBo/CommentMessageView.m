

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
#import "UserData.h"

@interface CommentMessageView()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *messageTable;

@property (strong, nonatomic) NSMutableArray *contentArr;
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
    _contentArr = [NSMutableArray arrayWithCapacity:0];
    [self creatMessageTable];
}

- (void)reloadMessageTable {
    [_contentArr removeAllObjects];
    [_contentArr addObjectsFromArray:self.messageArray];
    
    if (_contentArr.count == 1 || _contentArr.count == 0) {
        [_messageTable reloadData];
    } else {
        [_messageTable insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.contentArr.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_messageTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.contentArr.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
  
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
    return self.contentArr.count;
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
    
    
    NSDictionary *messageInfo = [NSDictionary safeDictionary:self.contentArr[indexPath.row]];
    UITableViewCell *cell;
    NSString *name = [UserData getUser].nickName;
    NSString *userName = [NSString safeString:messageInfo[@"userName"]];
    BOOL isTeacher = [name isEqualToString:userName];
    
    NSString *nameStr = [NSString stringWithFormat:@"%@:",userName];
    NSString *message = [NSString safeString:messageInfo[@"content"]];;

    if (isTeacher) {
        MessageTableViewCell *TCell = [tableView dequeueReusableCellWithIdentifier:CellIdTeacher forIndexPath:indexPath];
        TCell.messageLabel.attributedText = [self setAttributeString:message subString:nameStr isTeacher:YES];
        cell =TCell;
    } else {
        ParentsTableViewCell *PCell = [tableView dequeueReusableCellWithIdentifier:CellIdParents forIndexPath:indexPath];
        PCell.messageLabel.attributedText = [self setAttributeString:message subString:nameStr isTeacher:NO];
        cell = PCell;
    }
    
    return cell;
}


- (NSAttributedString*)setAttributeString:(NSString *)string subString:(NSString *)subStr isTeacher:(BOOL)isTeacher {

    NSString *contentStr = [NSString stringWithFormat:@"%@ %@",subStr,string];
    NSMutableAttributedString *MString = [[NSMutableAttributedString alloc] initWithString:contentStr];

    if ([subStr isEqualToString:@""]) {
        
        return MString;
    
    } else {
        UIColor *textColor = isTeacher ?MAIN_BLUE_MESSAGE:MAIN_WHITE;
        
        NSRange trueNameRange = [contentStr rangeOfString:subStr];
        [MString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:trueNameRange];
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
