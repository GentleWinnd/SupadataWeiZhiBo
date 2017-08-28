//
//  EnumHeader.h
//  AgriculturalCollegeStu
//
//  Created by YH on 2016/12/16.
//  Copyright © 2016年 YH. All rights reserved.
//

#ifndef EnumHeader_h
#define EnumHeader_h

/**
 用户角色

 - UserRoleTeacher: 教师
 - UserRoleStudent: 学生
 用户角色1:教师 2：学生 3：家长 4.年级组组长 5 校长 10其他高权限教师
 */
typedef NS_ENUM(NSInteger, UserRole) {
    UserRoleTeacher =1,
    UserRoleStudent = 2,
    UserRoleParents = 3,
    UserRoleGradeLeader =4,
    UserRoleKindergartenLeader =5,
    UserRoleAdministrator =10
};

/**
 任务类型
 
 - ClassAssignmentTypeDefault: 默认是测试
 - ClassAssignmentTypeTask: 作业
 */
typedef NS_ENUM(NSInteger, ClassAssignmentType) {
    ClassAssignmentTypeClassTest,
    ClassAssignmentTypeTemporaryTest,
    ClassAssignmentTypeHomeTask,
};

//source type
typedef NS_ENUM(NSInteger,SourceType) {
    SourceTypeAll=11,
    SourceTypeVedio,
    SourceTypeImage,
    SourceTypeFile,
    SourceTypeFlash,
    SourceTypeOther
};

//source type
typedef NS_ENUM(NSInteger,SuportDirection) {
    SuportDirectionPortrait=0,
    SuportDirectionRight,
    SuportDirectionAll,
   
};



#endif /* EnumHeader_h */
