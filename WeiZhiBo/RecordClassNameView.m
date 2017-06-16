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
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) IBOutlet UIButton *clearBtn;

@end
static NSString *CellIdOfClass = @"cellIdOfClass";


@implementation RecordClassNameView

- (void)awakeFromNib {
    [super awakeFromNib];
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
    self.classNameTab.layer.cornerRadius = 3;
    self.classNameTab.layer.masksToBounds = YES;
    [self.classNameTab registerNib:[UINib nibWithNibName:@"ClassNameTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdOfClass];
    [self.classNameTab flashScrollIndicators];
    [self hiddenClassNameTableView:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.userClassInfo.count == 1?0:self.userClassInfo.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return HEIGHT_6_ZSCALE(48);
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
    cell.classNameLabel.textColor = MAIN_MIDDLEBLACK_TEXT;
    
    
    if (indexPath.row == _selectedIndexPath.row) {
        cell.classNameLabel.textColor = MaIN_LIGHTBLUE_CLASSNAME;
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *classInfo = [NSDictionary safeDictionary:self.userClassInfo[indexPath.row]];
    self.className = [NSString safeString:classInfo[@"className"]];
    self.classId = [NSString safeNumber:classInfo[@"classId"]];
    self.classInfo = [NSDictionary safeDictionary:classInfo];
    
    
    ClassNameTableViewCell *SCell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
    SCell.classNameLabel.textColor = MAIN_MIDDLEBLACK_TEXT;
    _selectedIndexPath = indexPath;
    ClassNameTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.classNameLabel.textColor = MaIN_LIGHTBLUE_CLASSNAME;
    self.classNameTextfeild.text = self.className;
    
    [self hiddenClassNameTableView:YES];
    //    if (self.getClassInfo) {
    //        self.getClassInfo(YES,self.classInfo);
    //    }
    //
}

- (void)setUserClassInfo:(NSArray *)userClassInfo {
    _userClassInfo = userClassInfo;
    
    if (userClassInfo.count>0) {
        NSDictionary *classInfo = [NSDictionary safeDictionary:self.userClassInfo[0]];
        self.className = [NSString safeString:classInfo[@"className"]];
        self.classId = [NSString safeNumber:classInfo[@"classId"]];
        self.classInfo = [NSDictionary safeDictionary:classInfo];
        self.classNameTextfeild.text = self.className;
        
        if (userClassInfo.count != 1) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            ClassNameTableViewCell *cell = [self.classNameTab cellForRowAtIndexPath:indexPath];
            cell.classNameLabel.textColor = MaIN_LIGHTBLUE_CLASSNAME;
            self.classNameTextfeild.text = self.className;
            [self.classNameTab reloadData];
//            self.singleClassLabel.hidden = YES;
        } else {
//            self.singleClassLabel.hidden = NO;
//            [self.singleClassLabel setTitle:self.className forState:UIControlStateNormal];
//            [self.singleClassLabel setTitleColor:MaIN_LIGHTBLUE_CLASSNAME forState:UIControlStateNormal];
        }
        
    } else {
//        self.singleClassLabel.hidden = YES;
    }
    
}

#pragma mark - selectedCLass
- (IBAction)cancelBtnAction:(UIButton *)sender {
    if (sender.tag == 11) {//取消
        if (self.getClassInfo) {
            self.getClassInfo(NO,self.classInfo);
        }
        
    } else {//确定
        if (self.getClassInfo) {
            self.getClassInfo(YES,self.classInfo);
            self.title = self.proTitle;
        }
    }
}

- (IBAction)singleClassLabelAction:(UIButton *)sender {
    [self hiddenClassNameTableView:YES];
}


- (IBAction)sendMeesageAction:(UIButton *)sender {
    sender.selected = !sender.selected;
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

- (IBAction)noticeAllSchool:(UIButton *)sender {
    sender.selected = !sender.selected;
    
}
- (IBAction)unfoldClassTable:(UIButton *)sender {
    [self hiddenClassNameTableView:NO];
}

- (void)hiddenClassNameTableView:(BOOL) hidden {
    
    CGSize tableSize = CGSizeMake(0, 0);
    self.maskVIew.hidden = hidden;
    if (self.userClassInfo.count == 1) {
//        self.singleClassLabel.hidden = hidden;
    }
    if (hidden == NO) {
        //        NSInteger length = [self getClassNameMaxLength];
        //        NSInteger height = HEIGHT_6_ZSCALE(48)*self.userClassInfo.count;
        //        NSInteger WSpace = length > (SCREEN_WIDTH - WIDTH_6_ZSCALE(266))?SCREEN_WIDTH - WIDTH_6_ZSCALE(266):length;
        //        NSInteger HSpace = height > (SCREEN_HEIGHT - HEIGHT_6_ZSCALE(88))?(SCREEN_HEIGHT - HEIGHT_6_ZSCALE(88)):height;
        //        tableSize = CGSizeMake(WSpace+60, HSpace);
        tableSize = CGSizeMake(WIDTH_6_ZSCALE(390), HEIGHT_6_ZSCALE(230));
    }
    
    [UIView animateWithDuration:0.8f animations:^{
        self.tabelWidth.constant = tableSize.width;
        self.tabelHeight.constant = tableSize.height;
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
