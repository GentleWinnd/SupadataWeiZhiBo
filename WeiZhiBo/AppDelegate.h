//
//  AppDelegate.h
//  WeiZhiBo
//
//  Created by YH on 2017/3/21.
//  Copyright © 2017年 YH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *MainVC;
@property (assign, nonatomic) BOOL shouldChangeOrientation;


@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

