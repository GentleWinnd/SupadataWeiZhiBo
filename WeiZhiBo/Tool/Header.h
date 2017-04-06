//
//  Header.h
//  WeiZhiBo
//
//  Created by YH on 2017/3/23.
//  Copyright © 2017年 YH. All rights reserved.
//

#ifndef Header_h
#define Header_h

//获取设备屏幕尺寸
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
//应用尺寸
#define APP_WIDTH [[UIScreen mainScreen]applicationFrame].size.width
#define APP_HEIGHT [[UIScreen mainScreen]applicationFrame].size.height

/**
 Generate weakOject
 
 @param o need weak object
 @return weakObject
 */
#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;

#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;


#endif /* Header_h */
