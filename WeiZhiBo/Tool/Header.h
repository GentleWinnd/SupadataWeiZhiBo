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

//依照iPhone6屏幕比例缩放
#define HEIGHT_6_ZSCALE(H) (SCREEN_HEIGHT/667)*H
#define WIDTH_6_ZSCALE(W) (SCREEN_WIDTH/365)*W

/**
 Generate weakOject
 
 @param o need weak object
 @return weakObject
 */
#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;

#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

#define IOS8x ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)



#endif /* Header_h */
