//
//  RecordClassNameView.h
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/6/15.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordClassNameView : UIView

@property (strong, nonatomic) IBOutlet UITableView *classNameTab;
@property (strong, nonatomic) IBOutlet UITextField *classTitleTextFeild;
@property (strong, nonatomic) IBOutlet UIButton *choiceClassBtn;
@property (strong, nonatomic) IBOutlet UITextField *classNameTextfeild;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *classViewWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *classViewHeight;
@property (strong, nonatomic) IBOutlet UIButton *maskVIew;


@property (copy, nonatomic) void(^ getClassInfo)(BOOL success, NSArray *selClassArr, NSString *titleStr);

@property (strong, nonatomic) NSArray *userClassInfo;

@property (strong, nonatomic) NSMutableArray *selectedArray;
@property (strong, nonatomic) NSString *proTitle;
@property (strong, nonatomic) NSString *title;


@property (assign, nonatomic) BOOL firstEdite;
@property (assign, nonatomic) UserRole userRole;

@end
