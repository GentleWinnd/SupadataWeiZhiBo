//
//  RecordClassNameView.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/6/15.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "RecordClassNameView.h"

#import "ClassNameTableViewCell.h"

@interface RecordClassNameView()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIView *classInfoView;
@property (strong, nonatomic) IBOutlet UIButton *cancleBtn;
@property (strong, nonatomic) IBOutlet UIButton *confirmBtn;
@property (strong, nonatomic) IBOutlet UIButton *clearBtn;

@property (strong, nonatomic) IBOutlet UIButton *allSelBtn;
@property (strong, nonatomic) IBOutlet UIButton *confirmSelBtn;

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end
static NSString *CellIdOfClass = @"cellIdOfClass";

@implementation RecordClassNameView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.classInfoView.layer.masksToBounds = YES;
    self.classInfoView.layer.cornerRadius = 3;
    self.selectedArray = [NSMutableArray arrayWithCapacity:0];
    _firstEdite = YES;
    _classTitleTextFeild.delegate = self;
    _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_classTitleTextFeild setValue:MAIN_LIGHT_WHITE_TEXTFEILD
                        forKeyPath:@"_placeholderLabel.textColor"];
    
    [self customCLassNameTableView];
}

- (void)setUserRole:(UserRole)userRole {
    
    if (userRole == UserRoleKindergartenLeader) {
        
    } else {
//        self.noticeAllSchoolBtn.hidden = YES;
//        self.noticeAllSchoolLabel.hidden = YES;
//        self.sendMessageLeadingSpace.constant = 0;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    self.clearBtn.hidden = NO;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _clearBtn.hidden = YES;
    _firstEdite = NO;
    _classTitleTextFeild.textColor = [UIColor whiteColor];
}

- (void)setProTitle:(NSString *)proTitle {
    _classTitleTextFeild.text = proTitle;
    _classTitleTextFeild.textColor = _firstEdite?MAIN_LIGHT_WHITE_TEXTFEILD:[UIColor whiteColor];
    _title = proTitle;
}

- (void)customCLassNameTableView {
    // 显示选中框
    self.classNameTab.backgroundColor = [UIColor whiteColor];
    self.classNameTab.dataSource = self;
    self.classNameTab.delegate = self;
    [self.classNameTab registerNib:[UINib nibWithNibName:@"ClassNameTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdOfClass];
    [self.classNameTab flashScrollIndicators];
    [self hiddenClassNameTableView:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.userClassInfo.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return HEIGHT_6_ZSCALE(50);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ClassNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdOfClass forIndexPath:indexPath];
    NSDictionary *classInfo = [NSDictionary safeDictionary:self.userClassInfo[indexPath.row]];
    NSString *classN = [NSString safeString:classInfo[@"className"]];
    if (classN.length == 0) {
        cell.classNameLabel.text = @"未命名班级";
    } else {
        cell.classNameLabel.text = classN;
    }
    if (self.selectedArray.count == 0) {
        cell.selectedBtn.selected = NO;
    } else {
        [self setClassCellSelectedState:cell classInfo:classInfo];

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ClassNameTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *classInfo = [NSDictionary safeDictionary:self.userClassInfo[indexPath.row]];
    cell.selectedBtn.selected =!cell.selectedBtn.selected;

    if (cell.selectedBtn.selected) {
        [self.selectedArray addObject:classInfo];
    } else {
        [self setClassCellSelectedState:cell classInfo:classInfo];
    }
    
}

- (void)setClassCellSelectedState:(ClassNameTableViewCell *)cell classInfo:(NSDictionary *)classInfo {

    NSArray *seleArr = [NSArray arrayWithArray:self.selectedArray];
    for (NSDictionary *classDic in seleArr) {
        if ([classInfo[@"classId"] integerValue]  == [classDic[@"classId"] integerValue]) {
            [self.selectedArray removeObject:classDic];
            break;
        }
    }
}

- (void)setUserClassInfo:(NSArray *)userClassInfo {
    _userClassInfo = userClassInfo;
    if (userClassInfo.count >0) {
        
        [self.classNameTab reloadData];
    }
    
}

#pragma mark - selectedCLass
- (IBAction)cancelBtnAction:(UIButton *)sender {
    NSString *titleStr = self.classTitleTextFeild.text.length>0?self.classTitleTextFeild.text:self.proTitle;
    if (sender.tag == 11) {//取消
        if (self.getClassInfo) {
            self.getClassInfo(NO,self.selectedArray, titleStr);
        }
        
    } else {//确定
        if (self.getClassInfo) {
            self.getClassInfo(YES,self.selectedArray,titleStr);
            self.title = self.proTitle;
        }
    }
}


- (IBAction)clearBtnAction:(UIButton *)sender {
    
    sender.hidden = YES;
    _classTitleTextFeild.textColor = [UIColor whiteColor];
    [_classTitleTextFeild becomeFirstResponder];
    _firstEdite = NO;
}

- (IBAction)maskBtnAction:(UIButton *)sender {
    [self hiddenClassNameTableView:YES];
}


- (IBAction)unfoldClassTable:(UIButton *)sender {
    [self hiddenClassNameTableView:NO];
}

- (void)hiddenClassNameTableView:(BOOL) hidden {
    
    CGSize tableSize = CGSizeMake(0, 0);
    self.maskVIew.hidden = hidden;
    self.classInfoView.hidden = hidden;
    if (hidden == NO) {
        tableSize = CGSizeMake(WIDTH_6_ZSCALE(408), HEIGHT_6_ZSCALE(246));
    }
    
    [UIView animateWithDuration:0.8f animations:^{
        self.classViewWidth.constant = tableSize.width;
        self.classViewHeight.constant = tableSize.height;
    }];
    
}

- (NSInteger)getClassNameMaxLength {
    
    NSInteger maxLength = 0;
    for (NSDictionary *classInfo in self.userClassInfo) {
        NSString *classN = [NSString safeString:classInfo[@"className"]];
        NSInteger length = [classN boundingRectWithSize:CGSizeMake(1000, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size.width;
        maxLength = maxLength>length?maxLength:length;
    }
    return maxLength;
}

- (IBAction)selectedCLassBtnAction:(UIButton *)sender {
    if (sender.tag == 118) {//全选
        sender.selected = !sender.selected;
        [self.selectedArray removeAllObjects];
        [self.selectedArray addObjectsFromArray:self.userClassInfo];
        [self.classNameTab reloadData];
        
    } else {//确定
        
        [self hiddenClassNameTableView:YES];
        NSString *firstName = [NSString safeString:[NSDictionary safeDictionary:self.selectedArray.firstObject][@"className"]];
        NSString *classNameStr = [NSString stringWithFormat:@"%@ (%@)",firstName,@(self.selectedArray.count)];
        self.classNameTextfeild.text = classNameStr;
    }
    
}


//#pragma mark - unfold or fold cell
//- (void)unFoldCell:(UIGestureRecognizer *)gesture {
//    NSInteger section = gesture.view.tag;
//    NSString *indexStr = [NSString stringWithFormat:@"%tu",section];
//    BOOL fold = ![unfoldInfo[indexStr] boolValue];
//    [unfoldInfo setValue:[NSNumber numberWithBool:fold] forKey:indexStr];
//    [_classNameTable reloadData];
//
//}


@end
