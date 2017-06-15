//
//  CLassNameView.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/6/15.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLassNameView : UIView

@property (strong, nonatomic) NSArray *userClassInfo;
@property (strong, nonatomic) IBOutlet UITableView *classNameTab;
@property (strong, nonatomic) IBOutlet UIButton *sendMessageBtn;
@property (strong, nonatomic) IBOutlet UIButton *noticeAllSchoolBtn;
@property (strong, nonatomic) IBOutlet UILabel *sendMessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *noticeAllSchoolLabel;


@property (strong, nonatomic) IBOutlet UITextField *classTitleTextFeild;
@property (strong, nonatomic) IBOutlet UIButton *choiceClassBtn;
@property (strong, nonatomic) IBOutlet UITextField *classNameTextfeild;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tabelWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tabelHeight;
@property (strong, nonatomic) IBOutlet UIButton *maskVIew;
@property (strong, nonatomic) IBOutlet UIButton *singleClassLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendMessageLeadingSpace;


@property (copy, nonatomic) void(^ getClassInfo)(BOOL success, NSDictionary *classInfo);
@property (strong, nonatomic) NSString *className;
@property (strong, nonatomic) NSString *classId;
@property (strong, nonatomic) NSDictionary *classInfo;
@property (strong, nonatomic) NSString *proTitle;
@property (strong, nonatomic) NSString *title;
@property (assign, nonatomic) BOOL firstEdite;
@property (assign, nonatomic) UserRole userRole;


@end
