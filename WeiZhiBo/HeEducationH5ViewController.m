//
//  HeEducationH5ViewController.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/29.
//  Copyright © 2017年 YH. All rights reserved.
//


#import "AFNetworkReachabilityManager.h"
#import "HeEducationH5ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <MediaPlayer/MediaPlayer.h>

#import "LogInViewController.h"
#import "ViewController.h"
#import "ReloadView.h"
#import "UserData.h"
#import "User.h"
#import <WebKit/WebKit.h>

@protocol JSObjcDelegate <JSExport>//设置代理方法暴露给JS

- (void)getSchoolId:(NSString *)schoolId;

@end


@interface HeEducationH5ViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,UINavigationControllerDelegate,JSObjcDelegate>
{
    WKWebView *webView;
    NSString *CSchoolId;
    NSString *CSchoolName;
    NSArray *classesArray;
    MBProgressManager *loadProgress;
    NSURLConnection *theConnection;

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
    if (self.appToken) {
        [self getAppTokenByThirdApp];
    } else {
        [self initWKWebView];
    }
    
    [self customPlayBtn];
    [self setBackBtn];
//    [self AFNReachability];
    //开始播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayerStart) name:@"" object:nil];
    
    //结束播放
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedPlay) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    
    //     [notificationCenter addObserver:self selector:@selector(moviePlayerLoadStateDidChange) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    //    [self initDeviceOrientation];

}

- (void)moviePlayerStart {
    
    
    NSLog(@"satrt");
}

- (void)finishedPlay {
    NSLog(@"finished");
    
}

#pragma mark - 通过APPtoken获取登录验证码
- (void)getAppTokenByThirdApp {

    [WZBNetServiceAPI getAppLoginTokenByThirdAppWithParameters:@{@"appToken":self.appToken,
                                                                 @"flag":@"2"}
                                                       success:^(id reponseObject) {
        if ([reponseObject[@"status"] integerValue] ==1) {
            NSDictionary *logInfo = [NSDictionary safeDictionary:reponseObject[@"data"]];
            self.accessToken = logInfo[@"uAccessToken"];
            self.openId = logInfo[@"uOpenId"];
            [self loginByHeBaby:@{@"access_token":logInfo[@"uAccessToken"],
                                  @"open_id":logInfo[@"uOpenId"]}];

        } else {
            [Progress progressShowcontent:@"出现意外错误" currView:self.view];
        }
    } failure:^(NSError *error) {
        [KTMErrorHint showNetError:error inView:self.view ];
    }];
    

}
- (void)loginByHeBaby:(NSDictionary *) parameter {
    
    
    [WZBNetServiceAPI postLoginByHeBabyWithParameters:parameter success:^(id responseObject) {
        if ([responseObject[@"status"] intValue] == 1) {//登陆成功
            
            NSDictionary *userInfo = [NSDictionary safeDictionary:responseObject[@"data"][@"user"]];
            
            self.userClassInfo = [NSArray safeArray:responseObject[@"data"][@"school"]];
            self.userId = userInfo[@"uId"];
            
            [self initWKWebView];
            User *user = [[User alloc] init];
            user.userName = [NSString safeString:userInfo[@"uName"]];
            user.userPass = [NSString safeString:userInfo[@"uPass"]];
            user.userID = [NSString stringWithFormat:@"%@",self.userId];
            user.nickName = [NSString safeString:userInfo[@"uNickName"]];
            
            [UserData storeUserData:user];

        } else {
            [Progress progressShowcontent:@"出现意外错误" currView:self.view];
        }
    } failure:^(NSError *error) {
        [KTMErrorHint showNetError:error inView:self.view];
        
    }];
    
}

#pragma mark - 初始化webview

- (void)initWKWebView {
     WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // 设置偏好设置
    config.preferences = [[WKPreferences alloc] init];
    // 默认为0
    config.preferences.minimumFontSize = 10;
    // 默认认为YES
    config.preferences.javaScriptEnabled = YES;
    // 在iOS上默认为NO，表示不能自动通过窗口打开
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    // web内容处理池，由于没有属性可以设置，也没有方法可以调用，不用手动创建
    config.processPool = [[WKProcessPool alloc] init];
    
    // 通过JS与webview内容交互
    config.userContentController = [[WKUserContentController alloc] init];
    
    // 注入JS对象名称AppModel，当JS通过AppModel来调用时，
    // 我们可以在WKScriptMessageHandler代理中接收到
    [config.userContentController addScriptMessageHandler:self name:@"Supadata"];
    
    
    //    window.webkit.messageHandlers.Supadata.postMessage({body:'schoolId'})
    
     webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];

    [self.view addSubview:webView];
    
//    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view);
//        make.right.equalTo(self.view);
//        make.top.equalTo(self.view);
//        make.bottom.equalTo(self.view);
//    }];
    
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    
    NSURL *repURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://live.sch.supadata.cn/ssm//resource/html/teacher/?user=%@#/tab/camera",self.userId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:repURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3];
    [webView loadRequest: request];
    
    if (theConnection) {
        [theConnection cancel];
        //        SAFE_RELEASE(theConnection);
        NSLog(@"safe release connection");
    }
    theConnection= [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];

}

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    loadProgress = [[MBProgressManager alloc] init];
    [loadProgress loadingWithTitleProgress:@"加载中..."];
    UIView *reloadView = [self.view viewWithTag:112];
    if (reloadView) {
        [reloadView removeFromSuperview];
    }

}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [loadProgress hiddenProgress];
    
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    NSLog(@"%@",navigationResponse.response.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSLog(@"%@",navigationAction.request.URL.absoluteString);
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"Supadata"]) {
        // 打印所传过来的参数，只支持NSNumber, NSString, NSDate, NSArray,
        // NSDictionary, and NSNull类型
        NSLog(@"%@", message.body);
        [self getSchoolId:message.body];
        
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (theConnection) {
        //        SAFE_RELEASE(theConnection);
        NSLog(@"safe release connection");
    }
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]]){
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
        if ((([httpResponse statusCode]/100) == 2)){
            NSLog(@"connection ok");
        }
        else{
            NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:nil];
            if ([error code] == 404){
                NSLog(@"404");
                //                [self openNextLink];
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    if (theConnection) {
        //        SAFE_RELEASE(theConnection);
        NSLog(@"safe release connection");
    }
    //    if (loadNotFinishCode == NSURLErrorCancelled)  {
    //        return;
    //    }
    if (error.code == 22) {//The operation couldn’t be completed. Invalid argument
        //        [self openNextLink];
        [self loadFaild];
        NSLog(@"22");}
    else if (error.code == -1001) {//The request timed out.  webview code -999的时候会收到－1001，这里可以做一些超时时候所需要做的事情，一些提示什么的
        //        [self openNextLink];
        NSLog(@"-1001");
        [self loadFaild];

    }
    else if (error.code == -1005) {//The network connection was lost.
        //        [self openNextLink];
        NSLog(@"-1005");
        [self loadFaild];

    }
    else if (error.code == -1009){ //The Internet connection appears to be offline
        //do nothing
        NSLog(@"-1009");
        [self loadFaild];

    }
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

#pragma mark loadFaild

- (void)loadFaild {
    
    [loadProgress hiddenProgress];
    [self createReloadView];
}

#pragma mark - 创建没有数据view

- (void)createReloadView {
    ReloadView *reloadView = [[NSBundle mainBundle] loadNibNamed:@"ReloadView" owner:nil options:nil].firstObject;
    reloadView.frame = CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT);
    reloadView.reloadView = ^(){
        if (webView) {
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://live.sch.supadata.cn/ssm//resource/html/teacher/?user=%@#/tab/camera",self.userId]]]];
        }
    };
    reloadView.tag = 112;
    [self.view addSubview:reloadView];

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
        
        ViewController *VC = [board instantiateViewControllerWithIdentifier:@"ViewController"];
        VC.userClassInfo = classesArray;
        VC.userId = self.userId;
        VC.accessToken = self.accessToken;
        VC.openId = self.openId;
        VC.schoolId = CSchoolId;
        VC.schoolName = CSchoolName;
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController pushViewController:VC animated:YES];
        
    }
}

#pragma mark - 创建播放按钮

- (void)customPlayBtn {
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.frame = CGRectMake(SCREEN_WIDTH - 18 - 95, 30+60, 97, 40);
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


/****************************/
- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    if (viewController != self) {
        [self rotateVC:M_PI_2];
    } else {
        [self rotateVC:-M_PI_2];
    }
}

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
    buttom.frame = CGRectMake(0, 0, 10, 23);
//    buttom.imageEdgeInsets = UIEdgeInsetsMake(0, -, 0, 0);
    [buttom setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [buttom addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem  *back = [[UIBarButtonItem alloc] initWithCustomView:buttom];

    self.navigationItem.leftBarButtonItem = back;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = NO;

}


#pragma mark - WKUIDelegate
// 创建一个新的WebView
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    return [[WKWebView alloc]init];
}
// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    completionHandler(@"http");
}
// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    completionHandler(YES);
}
// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"%@",message);
    completionHandler();
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
