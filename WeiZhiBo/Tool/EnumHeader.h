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
 */
typedef NS_ENUM(NSInteger, UserRole) {
    UserRoleTeacher,
    UserRoleStudent
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



#endif /* EnumHeader_h */
