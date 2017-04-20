//
//  HeEducationH5ViewController.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/29.
//  Copyright © 2017年 YH. All rights reserved.
//


#import "AFNetworkReachabilityManager.h"
#import "HeEducationH5ViewController.h"
#import "LogInViewController.h"
#import "ViewController.h"
#import "ReloadView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <JavaScriptCore/JavaScriptCore.h>//(此处为尖括号)
#import "AppDelegate.h"


@protocol JSObjcDelegate <JSExport>//设置代理方法暴露给JS

- (void)getSchoolId:(NSString *)schoolId;

@end


@interface HeEducationH5ViewController ()<UIWebViewDelegate,JSObjcDelegate>
{
    UIWebView *webView;
    NSString *CSchoolId;
    NSString *CSchoolName;
    NSArray *classesArray;
    MBProgressManager *loadProgress;
}

@property (nonatomic, strong) JSContext *jsContext;

@end

@implementation HeEducationH5ViewController


#pragma mark - UIWebViewDelegate

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.delegate = self;
    self.title = @"微直播";

    [self initWebView];
    [self customPlayBtn];
    [self setBackBtn];
//    [self AFNReachability];
    //开始播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerStart) name:@"" object:nil];
    
    //结束播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedPlay) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    
    //     [notificationCenter addObserver:self selector:@selector(moviePlayerLoadStateDidChange) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    //    [self initDeviceOrientation];

}

- (void)moviePlayerStart {
    
    
    NSLog(@"satrt");
}

- (void)finishedPlay {
    NSLog(@"finished");
}

#pragma mark - 创建播放按钮

- (void)customPlayBtn {

    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.frame = CGRectMake(SCREEN_WIDTH - 18 - 95, 30+60, 95, 33);
    [playBtn setImage:[UIImage imageNamed:@"zhibo"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    playBtn.hidden = YES;
    playBtn.tag = 110;
    [self.view addSubview:playBtn];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doHandlePanAction:)];
    [playBtn addGestureRecognizer:pan];
    
}

#pragma mark- 返回按钮事件

- (void)backBtnAction:(UIButton *)sender {


    if ([webView canGoBack]) {
        [webView goBack];
        
    }else{
        [self.view resignFirstResponder];
//        [self.navigationController popViewControllerAnimated:YES];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"是否要退出登录" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            LogInViewController *logView = [[LogInViewController alloc] init];
            [self restoreRootViewController:logView];

        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
        
    }
}

#pragma mark - pangesturehandle

- (void) doHandlePanAction:(UIPanGestureRecognizer *)paramSender{
    
    CGPoint point = [paramSender translationInView:self.view];
//    NSLog(@"X:%f;Y:%f",point.x,point.y);
    paramSender.view.center = [self playSizeupPanBoundary:CGPointMake(paramSender.view.center.x + point.x, paramSender.view.center.y + point.y)];
    [paramSender setTranslation:CGPointMake(0, 0) inView:self.view];
    
}

#pragma mark- 判断按钮是否画出边界

- (CGPoint) playSizeupPanBoundary:(CGPoint)point {
    CGFloat Width = point.x;
    CGFloat Height = point.y;
    CGFloat X = Width;
    CGFloat Y = Height;
    if (Width< 50) {
        X = 50;
    } else if (Width>SCREEN_WIDTH-50){
        X = SCREEN_WIDTH -50;
    }
    if (Height<18+64) {
        Y = 18+64;
    } if (Height>SCREEN_HEIGHT-68) {
        Y = SCREEN_HEIGHT-68;
    }
    
    
    return CGPointMake(X, Y);
}

#pragma mark- 直播按钮事件

- (void)playAction:(UIButton *)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if (classesArray.count >0) {
        AppDelegate * app = [UIApplication sharedApplication].delegate;
        app.shouldChangeOrientation = YES;

        ViewController *VC = [board instantiateViewControllerWithIdentifier:@"ViewController"];
        VC.userClassInfo = classesArray;
        VC.userId = self.userId;
        VC.accessToken = self.accessToken;
        VC.openId = self.openId;
        VC.schoolId = CSchoolId;
        VC.schoolName = CSchoolName;
        self.navigationController.navigationBarHidden = YES;
//        [self.navigationController pushViewController:VC animated:YES];
        
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:VC];
        
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - 初始化webview

- (void)initWebView {
    CGRect frame = self.view.bounds;
    webView = [[UIWebView alloc] initWithFrame:frame];
    webView.delegate = self;
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://live.sch.supadata.cn/ssm//resource/html/teacher/?user=630584331#/tab/camera"]]];
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://wangjunwei.uicp.io/ssm/resource/html/teacher/?user=%@#/tab/camera",self.phoneNUM]]]];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://live.sch.supadata.cn/ssm//resource/html/teacher/?user=%@#/tab/camera",self.userId]]]];
   
    [self.view addSubview:webView];

}

#pragma mark- webView代理方法

- (void)webViewDidStartLoad:(UIWebView *)webView {
    loadProgress = [[MBProgressManager alloc] init];
    [loadProgress loadingWithTitleProgress:@"加载中..."];
    UIView *reloadView = [self.view viewWithTag:112];
    if (reloadView) {
        [reloadView removeFromSuperview];
    }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [loadProgress hiddenProgress];

    self.jsContext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    self.jsContext[@"Supadata"] = self;//给js 注册对象，
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        [loadProgress hiddenProgress];
        NSLog(@"异常信息：%@", exceptionValue);
    };
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [loadProgress hiddenProgress];

    [self createReloadView];
    
}


#pragma mark - js回调函数

- (void)getSchoolId:(NSString *)schoolId {
    if (schoolId) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:110];
        btn.hidden = NO;
        CSchoolId = [NSString stringWithFormat:@"%@",schoolId];
        for (NSDictionary *schoolInfo in self.userClassInfo) {
            if ([[NSString stringWithFormat:@"%@",schoolInfo[@"schoolId"]] isEqualToString:CSchoolId]) {
                classesArray = [NSArray arrayWithArray:[NSArray safeArray:schoolInfo[@"classes"]]];
                CSchoolName = [NSString stringWithFormat:@"%@",schoolInfo[@"schoolName"]];
                if (classesArray.count == 0) {
                    [Progress progressShowcontent:@"获取学校班级信息失败" currView:self.view];
                }
                return;
            }
        }

    } else {
    
        [Progress progressShowcontent:@"未能获取学校" currView:self.view];
    }
   
//    NSLog(@"==== schollId=%@",schoolId);
}


#pragma mark - 创建没有数据view

- (void)createReloadView {
    ReloadView *reloadView = [[NSBundle mainBundle] loadNibNamed:@"ReloadView" owner:nil options:nil].firstObject;
    reloadView.frame = CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT);
//    reloadView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 -32);
    reloadView.reloadView = ^(){
        if (webView) {
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://live.sch.supadata.cn/ssm//resource/html/teacher/?user=%@#/tab/camera",self.userId]]]];
        }
    };
    reloadView.tag = 112;
    [self.view addSubview:reloadView];

}

/****************************/
//- (void)navigationController:(UINavigationController *)navigationController
//      willShowViewController:(UIViewController *)viewController
//                    animated:(BOOL)animated {
////    
////    if (viewController != self) {
////        [self rotateVC:M_PI_2];
////    } else {
////        [self rotateVC:-M_PI_2];
////    }
//}

- (void)rotateVC:(CGFloat)angle {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGPoint center = CGPointMake(screenSize.width / 2, screenSize.height / 2);
    self.navigationController.view.center = center;
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    if (angle < 0) {
        transform = CGAffineTransformIdentity;
    }
    self.navigationController.view.transform = transform;
    
    CGRect bounds = CGRectMake(0, 0, screenSize.height , screenSize.width);
    if (angle < 0) {
        bounds = CGRectMake(0, 0, screenSize.width , screenSize.height);
    }
    
    self.navigationController.view.bounds = bounds;
}

// 登陆后淡入淡出更换rootViewController
- (void)restoreRootViewController:(UIViewController *)rootViewController {
    typedef void (^Animation)(void);
    //
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    navVC.navigationBarHidden = YES;
    navVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    Animation animation = ^{
        BOOL oldState = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [UIApplication sharedApplication].keyWindow.rootViewController = navVC;
        [UIView setAnimationsEnabled:oldState];
    };
    
    [UIView transitionWithView:window
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:animation
                    completion:^(BOOL finished) {
                        
                    }];
}


//使用AFN框架来检测网络状态的改变
-(void)AFNReachability {
    //1.创建网络监听管理者
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    //2.监听网络状态的改变
    /*
     AFNetworkReachabilityStatusUnknown          = 未知
     AFNetworkReachabilityStatusNotReachable     = 没有网络
     AFNetworkReachabilityStatusReachableViaWWAN = 3G
     AFNetworkReachabilityStatusReachableViaWiFi = WIFI
     */
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"没有网络");
                [Progress progressShowcontent:@"当前网络不可用，请检查" currView:self.view];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"3G");
                [Progress progressShowcontent:@"您当前使用的是4G网络，直播时建议使用WiFi" currView:self.view];
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                [Progress progressShowcontent:@"当前是在WiFi环境下，您可以放心使用" currView:self.view];
                break;
                
            default:
                break;
        }
    }];
    
    //3.开始监听
    [manager startMonitoring];
}

- (void)setBackBtn {
    UIButton *buttom = [UIButton buttonWithType:UIButtonTypeCustom];
    buttom.frame = CGRectMake(0, 0, 60, 26);
    buttom.imageEdgeInsets = UIEdgeInsetsMake(0, -38, 0, 0);
    [buttom setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [buttom addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem  *back = [[UIBarButtonItem alloc] initWithCustomView:buttom];

    self.navigationItem.leftBarButtonItem = back;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
