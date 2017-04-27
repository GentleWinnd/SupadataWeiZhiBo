//
//  HeEducationH5ViewController.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/4/26.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "HeEducationH5ViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#import "LogInViewController.h"
#import "ViewController.h"
#import "ReloadView.h"
#import "UserData.h"
#import "User.h"
#import <WebKit/WebKit.h>
#import "AppDelegate.h"

@interface HeEducationH5ViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler, UINavigationControllerDelegate>
{
    WKWebView *WWebView;
    NSString *CSchoolId;
    NSString *CSchoolName;
    NSArray *classesArray;
    MBProgressManager *loadProgress;
    NSURLConnection *theConnection;
}
@property (assign, nonatomic) NSUInteger loadCount;

@property (strong, nonatomic) IBOutlet UIButton *backBtn;

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
        loadProgress = [[MBProgressManager alloc] init];
        loadProgress.showView = self.view;
        [loadProgress loadingWithTitleProgress:@"加载中..."];
    }
    
    [self customPlayBtn];
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
    loadProgress = [[MBProgressManager alloc] init];
    [loadProgress loadingWithTitleProgress:@"加载中..."];
    
    [WZBNetServiceAPI getAppLoginTokenByThirdAppWithParameters:@{@"appToken":self.appToken,
                                                                 @"flag":@"2"}
                                                       success:^(id reponseObject) {
                                                           if ([reponseObject[@"status"] integerValue] ==1) {
                                                               NSDictionary *userInfo = [NSDictionary safeDictionary:reponseObject[@"data"][@"user"]];
                                                               
                                                               self.accessToken = [NSString safeString:userInfo[@"uAccessToken"]];
                                                               self.openId = [NSString safeString:userInfo[@"uOpenId"]];
                                                               
                                                               self.userClassInfo = [NSArray safeArray:reponseObject[@"data"][@"school"]];
                                                               self.userId = userInfo[@"uId"];
                                                               
                                                               [self initWKWebView];
                                                               User *user = [UserData getUser];
                                                               if (user == nil) {
                                                                   user = [[User alloc] init];
                                                               }
                                                               user.userName = [NSString safeString:userInfo[@"uName"]];
                                                               user.userPass = [NSString safeString:userInfo[@"uPass"]];
                                                               user.userID = [NSString stringWithFormat:@"%@",self.userId];
                                                               user.nickName = [NSString safeString:userInfo[@"uNickName"]];
                                                               
                                                               [UserData storeUserData:user];
                                                           } else {
                                                               [Progress progressShowcontent:@"出现意外错误" currView:self.view];
                                                               [loadProgress hiddenProgress];
                                                           }
                                                       } failure:^(NSError *error) {
                                                           [loadProgress hiddenProgress];
                                                           [KTMErrorHint showNetError:error inView:self.view ];
                                                       }];
    
}

#pragma mark - 初始化webview

- (void)initWKWebView {
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = [[WKUserContentController alloc] init];
    //    window.webkit.messageHandlers.Supadata.postMessage({body:'schoolId'})
    
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [config.userContentController addUserScript:wkUScript];
    WWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) configuration:config];
    WWebView.UIDelegate = self;
    WWebView.navigationDelegate = self;
    [self.view addSubview:WWebView];
    
    
    NSURL *repURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@resource/html/teacher/?user=%@#/tab/live",HOST_URL,self.userId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:repURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3];
    [WWebView loadRequest: request];
    
    // 通过JS与webview内容交互
    WKUserContentController *userCC = config.userContentController;
    // 注入JS对象名称AppModel，当JS通过AppModel来调用时，
    // 我们可以在WKScriptMessageHandler代理中接收到
    [userCC addScriptMessageHandler:self name:@"Supadata"];
    
    if (theConnection) {
        [theConnection cancel];
        //        SAFE_RELEASE(theConnection);
        NSLog(@"safe release connection");
    }
    theConnection= [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    [WWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    
    UIView *reloadView = [self.view viewWithTag:112];
    if (reloadView) {
        [reloadView removeFromSuperview];
    }
    self.loadCount ++;
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [loadProgress hiddenProgress];
    [self performSelector:@selector(setWebViewContent) withObject:nil afterDelay:1.0];
    self.loadCount --;
}

- (void)setWebViewContent {
    
    [WWebView.scrollView setContentOffset:CGPointMake(0, 0)];
    //    WWebView.scrollView.scrollEnabled = NO;
    
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    [self createReloadView];
    self.loadCount --;
}


// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //    if (object == self.wkWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
    //        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
    //        if (newprogress == 1) {
    //            self.progressView.hidden = YES;
    //            [self.progressView setProgress:0 animated:NO];
    //        }else {
    //            self.progressView.hidden = NO;
    //            [self.progressView setProgress:newprogress animated:YES];
    //        }
    //    }
}

// 记得取消监听
- (void)dealloc {
    if (IOS8x) {
        [WWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
}

#pragma mark - webView代理

// 计算webView进度条
- (void)setLoadCount:(NSUInteger)loadCount {
    //    _loadCount = loadCount;
    //    if (loadCount == 0) {
    //        self.progressView.hidden = YES;
    //        [self.progressView setProgress:0 animated:NO];
    //    }else {
    //        self.progressView.hidden = NO;
    //        CGFloat oldP = self.progressView.progress;
    //        CGFloat newP = (1.0 - oldP) / (loadCount + 1) + oldP;
    //        if (newP > 0.95) {
    //            newP = 0.95;
    //        }
    //        [self.progressView setProgress:newP animated:YES];
    //    }
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
        [self.view bringSubviewToFront:btn];
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
        if (WWebView) {
            [WWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resource/html/teacher/?user=%@#/tab/live",HOST_URL,self.userId]]]];
        }
    };
    reloadView.tag = 112;
    [self.view addSubview:reloadView];
    
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
#pragma mark- 直播按钮事件

- (void)playAction:(UIButton *)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if (classesArray.count >0) {
        
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        app.shouldChangeOrientation = YES;
        
        ViewController *VC = [board instantiateViewControllerWithIdentifier:@"ViewController"];
        VC.userClassInfo = classesArray;
        VC.userId = self.userId;
        VC.accessToken = self.accessToken;
        VC.openId = self.openId;
        VC.schoolId = CSchoolId;
        VC.schoolName = CSchoolName;
        
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:VC];
        nav.navigationBarHidden = YES;
        [self presentViewController:nav animated:NO completion:^{
            [self setWebViewContent];
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

- (IBAction)backAction:(UIButton *)sender {
    
    
    if ([WWebView canGoBack]) {
        [WWebView goBack];
        
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


- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    //    [WWebView.scrollView setContentOffset:CGPointMake(0, -32)];
    [self setWebViewContent];
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
