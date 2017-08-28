//
//  AppDelegate.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/21.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "AppDelegate.h"
#import "LogInViewController.h"
#import "AppLogMgr.h"
#import "HeEducationH5ViewController.h"
#import "RealReachability.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    LogInViewController *logView = [[LogInViewController alloc] init];
    _MainVC = logView;
    self.window.rootViewController = _MainVC;
    [self.window makeKeyAndVisible];

    [self setUMAnalysisTrace];//友盟统计

    [GLobalRealReachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChanged:)
                                                 name:kRealReachabilityChangedNotification
                                               object:nil];

    return YES;
}

#pragma mark - 友盟统计

- (void)setUMAnalysisTrace {

    UMConfigInstance.appKey = @"595b03228630f56a600002d0";

    [MobClick startWithConfigure:UMConfigInstance];//配置以上参数后调用此方法初始化SDK！
}

- (void)networkChanged:(NSNotification *)notification {
    
    if (self.startNteNotice == NO) {
        return;
    }
    
    RealReachability *reachability = (RealReachability *)notification.object;
    ReachabilityStatus status = [reachability currentReachabilityStatus];
    ReachabilityStatus previousStatus = [reachability previousReachabilityStatus];
    NSLog(@"networkChanged, currentStatus:%@, previousStatus:%@", @(status), @(previousStatus));
    
    if (status == RealStatusNotReachable) {
        [Progress progressShowcontent:@"当前网络不可用" ];
    }
    
    if (status == RealStatusViaWiFi) {
        [Progress progressShowcontent:@"当前WIFI环境"];
    }
    
    if (status == RealStatusViaWWAN) {
//        [Progress progressShowcontent:@"主人😲😲😲，您正在使用流量" currView:self.window];

    }
    
    WWANAccessType accessType = [GLobalRealReachability currentWWANtype];
    
    if (status == RealStatusViaWWAN)
    {
        if (accessType == WWANType2G)
        {
            [Progress progressShowcontent:@"当前2G网络"];
        }
        else if (accessType == WWANType3G)
        {
            [Progress progressShowcontent:@"当前3G网络"];
        }
        else if (accessType == WWANType4G)
        {
            [Progress progressShowcontent:@"当前4G网络"];
        }
        else
        {
            [Progress progressShowcontent:@"未知移动数据网络"];

        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enterBack" object:nil];

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"activeFromBack" object:nil];
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    
}

//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
//
//
//    return NO;
//}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSString *urlStr = [url absoluteString];
    /*
     URL Schemes?appToken=&userType=
     */
    if ([urlStr hasPrefix:@"jsLinkageHebaobei002://"]) {

        NSArray *paramArray = [urlStr componentsSeparatedByString:@"appToken="];
//        NSLog(@"=====%@",paramArray);
        NSString *cateStr = [NSString safeString:paramArray.lastObject];
        NSArray *contentsArr = [cateStr componentsSeparatedByString:@"&userType="];
        _apptoken = contentsArr.firstObject;
        
        HeEducationH5ViewController *h5View = [[HeEducationH5ViewController alloc] init];
        h5View.appToken = _apptoken;
        h5View.userRole = [[NSString safeString:contentsArr.lastObject] integerValue] == 0 ?1:[[NSString safeString:contentsArr.lastObject] integerValue];

        self.window.rootViewController = _MainVC;
        [self.window makeKeyAndVisible];
        
    }
    return NO;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier {
    return NO;
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"WeiZhiBo"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if (self.direction == SuportDirectionRight) {
        return UIInterfaceOrientationMaskLandscapeRight;
    } else if (self.direction == SuportDirectionPortrait){
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
    
    
}


@end
