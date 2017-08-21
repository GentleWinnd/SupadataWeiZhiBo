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
#import "XibWKWebView.h"
#import "UserData.h"
#import "User.h"
#import <WebKit/WebKit.h>
#import "AppDelegate.h"
#import "TRDAnimationIndicator.h"
#import <CoreMotion/CoreMotion.h>
#import "StreamingViewModel.h"
#import "RecorderViewController.h"

@interface HeEducationH5ViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler, UINavigationControllerDelegate, UIScrollViewDelegate, TRDAnimationIndicatorDelegate>
{
    WKWebView *WWebView;
    NSString *CSchoolId;
    NSString *CSchoolName;
    NSArray *classesArray;
    NSURLConnection *theConnection;
    TRDAnimationIndicator *loadIndicator;
    CMMotionManager *motionManager;
    UIDeviceOrientation _deviceOrientation;
    UIButton *playBtn;
}
@property (assign, nonatomic) NSUInteger loadCount;
@property (strong, nonatomic) IBOutlet UIButton *overBtn;

@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet UIImageView *backImage;
@property (strong, nonatomic) IBOutlet UIView *curveView;


@property (strong, nonatomic) IBOutlet UIButton *vedioBtn;
@property (strong, nonatomic) IBOutlet UIImageView *vedioBackView;
@property (strong, nonatomic) IBOutlet UIButton *liveBtn;
@property (strong, nonatomic) IBOutlet UIButton *recordBtn;

@property (strong, nonatomic) IBOutlet XibWKWebView *WWebView;

@end

@implementation HeEducationH5ViewController

#pragma mark - testVersion

- (void)testAPPVersion {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [WZBNetServiceAPI getAPPVersionWithParameters:@{@"flag":@"1"} success:^(id reponseObject) {
        
        NSString *version = [NSString safeString:reponseObject[@"versionnumber"]];
        NSString *description = [NSString safeString:reponseObject[@"description"]];
        
        if (version) {
            int proVersion = [appCurVersion stringByReplacingOccurrencesOfString:@"." withString:@""].intValue;
            int currentVersion = [version stringByReplacingOccurrencesOfString:@"." withString:@""].intValue;
            if (currentVersion > proVersion) {
                [self alertViewMessage:description];
            }
        }
    } failure:^(NSError *error) {
        [KTMErrorHint showNetError:error inView:self.view];
    }];
}

- (void)alertViewMessage:(NSString *)messageStr {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发现新版本" message:messageStr preferredStyle:UIAlertControllerStyleAlert];
    
    //修改按钮的颜色，同上可以使用同样的方法修改内容，样式
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL  URLWithString:@"itms-apps://itunes.apple.com/app/id1221856921"]]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1221856921"]];
            [self deleteWebCache];
        } else {
            [Progress progressShowcontent:@"更新出现错误" currView:self.view];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    // 添加按钮
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UIWebViewDelegate

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chanegsBackBtnActive) name:@"activeFromBack" object:nil];

//    AppDelegate *appDe = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    appDe.shouldChangeOrientation = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.delegate = self;
    self.title = @"微直播";
    [self performSelector:@selector(startNetNotice) withObject:nil afterDelay:12.0f];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(begainFullScreen) name:UIWindowDidBecomeVisibleNotification object:nil];//进入全屏
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endFullScreen) name:UIWindowDidBecomeHiddenNotification object:nil];//退出全屏
    [self initWKWebView];
    [self createLoadIndicator];
    
    if (self.appToken) {
        self.backBtn.hidden = YES;
        self.backImage.hidden = YES;

        [self getAppTokenByThirdApp];
    } else {
        [loadIndicator startAnimation];
        [self startLoadWebView];
    }
    
    [self testAPPVersion];
    
//    [self initDeviceOrientation];
}

- (void)chanegsBackBtnActive {
    self.fromBack = YES;
    self.backBtn.hidden = NO;
    self.backImage.hidden = NO;
}

#pragma mark - 开始网络监听

- (void)startNetNotice {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.startNteNotice = YES;
}

#pragma mark - 创建加载动画

- (void)createLoadIndicator {

    loadIndicator = [[TRDAnimationIndicator alloc] initWithFrame:WWebView.frame];
    loadIndicator.delegate = self;
    [self.view addSubview:loadIndicator];
}

- (void)reloadDataWithAnimationView:(TRDAnimationIndicator *)Indicator {
    if (!self.appToken) {
        [loadIndicator startAnimation];
        [WWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resource/html/teacher/?user=%@#/tab/live",HOST_URL,self.userId]]]];
    } else {
        [self getAppTokenByThirdApp];
    }
}


#pragma mark - 通过APPtoken获取登录验证码
- (void)getAppTokenByThirdApp {
    [loadIndicator startAnimation];
    [WZBNetServiceAPI getAppLoginTokenByThirdAppWithParameters:@{@"appToken":self.appToken,
                                                                 @"flag":@"2"}
                                                       success:^(id reponseObject) {
                                                           if ([reponseObject[@"status"] integerValue] ==1) {
                                                               [self savedUserInfo:reponseObject];
                                                               [self startLoadWebView];

                                                           } else {
                                                               [Progress progressShowcontent:@"出现意外错误" currView:self.view];
                                                               [loadIndicator stopAnimationWithLoadText:@"加载失败了" withType:NO];
                                                           }
                                                       } failure:^(NSError *error) {
                                                           [loadIndicator stopAnimationWithLoadText:@"加载失败了" withType:NO];
                                                           [KTMErrorHint showNetError:error inView:self.view ];
                                                       }];
    
}

#pragma mark - 保存用户数据

- (void)savedUserInfo:(NSDictionary *) reponseObject {
    
    NSDictionary *userInfo = [NSDictionary safeDictionary:reponseObject[@"data"][@"user"]];
    
    self.accessToken = [NSString safeString:userInfo[@"uAccessToken"]];
    self.openId = [NSString safeString:userInfo[@"uOpenId"]];
    
    self.userClassInfo = [NSArray safeArray:reponseObject[@"data"][@"school"]];
    if (self.userClassInfo.count == 0) {
        [Progress progressShowcontent:@"该老师暂未录入班级信息" currView:self.view];
    }
    self.userId = userInfo[@"uId"];
    
    User *user = [[User alloc] init];
    user.userName = [NSString safeString:userInfo[@"uName"]];
    user.userPass = [NSString safeString:userInfo[@"uPass"]];
    user.userID = [NSString stringWithFormat:@"%@",self.userId];
    user.nickName = [NSString safeString:userInfo[@"uNickName"]];
    user.userRole = self.userRole;
    
    [UserData storeUserData:user];
}


#pragma mark - 初始化webview

- (void)initWKWebView {
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.userContentController = [[WKUserContentController alloc] init];
    //    window.webkit.messageHandlers.Supadata.postMessage({body:'schoolId'})
    config.preferences.minimumFontSize = 0;
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);document.cookie = 'fromapp=ios';document.cookie = 'channel=appstore';";
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [config.userContentController addUserScript:wkUScript];
    
    // Set any configuration parameters here, e.g.
    // myConfiguration.dataDetectorTypes = WKDataDetectorTypeAll;
    
    WWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) configuration:config];

    WWebView.UIDelegate = self;
    WWebView.navigationDelegate = self;
    WWebView.allowsBackForwardNavigationGestures = NO;
    WWebView.scrollView.delegate = self;
    [self.view insertSubview:WWebView atIndex:0];
}


#pragma mark - 开始网络加载

- (void)startLoadWebView {
    
    NSURL *repURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@resource/html/teacher/?user=%@#/tab/live",HOST_URL,self.userId]];
//    NSURL *repURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@resource/html/teacher/?user=%@#/tab/live",@"http://pengxiuxiao.55555.io/ssm/",self.userId]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:repURL];
    
    // 在此处获取返回的cookie
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    NSMutableString *cookieValue = [NSMutableString stringWithFormat:@""];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        [cookieDic setObject:cookie.value forKey:cookie.name];
    }
    // cookie重复，先放到字典进行去重，再进行拼接
    for (NSString *key in cookieDic) {
        NSString *appendString = [NSString stringWithFormat:@"%@=%@;", key, [cookieDic valueForKey:key]];
        [cookieValue appendString:appendString];
    }
    [request addValue:cookieValue forHTTPHeaderField:@"Cookie"];
    
    [WWebView loadRequest: request];
    // 通过JS与webview内容交互
    WKUserContentController *userCC = WWebView.configuration.userContentController;
    // 注入JS对象名称AppModel，当JS通过AppModel来调用时，
    // 我们可以在WKScriptMessageHandler代理中接收到
    [userCC addScriptMessageHandler:self name:@"Supadata"];
    [userCC addScriptMessageHandler:self name:@"userType"];

    if (theConnection) {
        [theConnection cancel];
        //        SAFE_RELEASE(theConnection);
        NSLog(@"safe release connection");
    }
    theConnection= [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    [WWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {//禁止h5页面缩放
    return nil;
}

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    self.loadCount ++;
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [loadIndicator stopAnimation];
    self.loadCount --;
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    [loadIndicator stopAnimationWithLoadText:@"点击重新加载" withType:NO];
    self.loadCount --;
}

/**
 *  在发送请求之前，决定是否跳转
 *
 *  @param webView          实现该代理的webview
 *  @param navigationAction 当前navigation
 *  @param decisionHandler  是否调转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
//    if (navigationAction.navigationType==WKNavigationTypeFormSubmitted) {                  //判断是返回类型
//        if (webView.backForwardList.backList.count>0) {                                  //得到栈里面的list
//            WKBackForwardListItem * item = webView.backForwardList.currentItem;          //得到现在加载的list
//            for (WKBackForwardListItem * backItem inwebView.backForwardList.backList) { //循环遍历，得到你想退出到
//                //添加判断条件
//                [webView goToBackForwardListItem:[webView.backForwardList.backListfirstObject]];
//            }
//        }
//    }
    
    NSString *url = navigationAction.request.URL.absoluteString;
    NSArray *contents = [url componentsSeparatedByString:@"/"];
    NSString *lastStr = contents.lastObject;
    if (self.appToken) {
        if (self.fromBack == NO) {
            self.backBtn.hidden = NO;
            self.backImage.hidden = NO;
            if ([lastStr isEqualToString:@"live"]) {
                self.backBtn.hidden = YES;
                self.backImage.hidden = YES;
            }
            
            if ([lastStr isEqualToString:@"camera"]) {
                self.backBtn.hidden = YES;
                self.backImage.hidden = YES;
                
            }
            if ([lastStr isEqualToString:@"square"]) {
                self.backBtn.hidden = YES;
                self.backImage.hidden = YES;
                
            }
            if ([lastStr isEqualToString:@"playback"]) {
                self.backBtn.hidden = YES;
                self.backImage.hidden = YES;
                
            }
            if ([lastStr isEqualToString:@"selected"]) {
                self.backBtn.hidden = YES;
                self.backImage.hidden = YES;
                
            }
            if ([lastStr isEqualToString:@""]) {
                self.backBtn.hidden = YES;
                self.backImage.hidden = YES;
                
            }
        }
       
    }
    
  
    //live/camera/square/playback/selected
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    // 获取cookie,并设置到本地
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
    
//    NSLog(@"\n====================================\n");
//    //读取wkwebview中的cookie 方法1
//    for (NSHTTPCookie *cookie in cookies) {
//        //        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//        NSLog(@"wkwebview中的cookie:%@", cookie);
//    }
//    NSLog(@"\n====================================\n");
//    //读取wkwebview中的cookie 方法2 读取Set-Cookie字段
//    NSString *cookieString = [[response allHeaderFields] valueForKey:@"Set-Cookie"];
//    NSLog(@"wkwebview中的cookie:%@", cookieString);
//    NSLog(@"\n====================================\n");
//    //看看存入到了NSHTTPCookieStorage了没有
//    NSHTTPCookieStorage *cookieJar2 = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (NSHTTPCookie *cookie in cookieJar2.cookies) {
//        NSLog(@"NSHTTPCookieStorage中的cookie%@", cookie);
//    }
//    NSLog(@"\n====================================\n");

    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark - 删除啊缓存
- (void)deleteWebCache {
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        
        NSSet *websiteDataTypes
        = [NSSet setWithArray:@[
                                WKWebsiteDataTypeDiskCache,
                                //WKWebsiteDataTypeOfflineWebApplicationCache,
                                WKWebsiteDataTypeMemoryCache,
                                //WKWebsiteDataTypeLocalStorage,
                                //WKWebsiteDataTypeCookies,
                                //WKWebsiteDataTypeSessionStorage,
                                //WKWebsiteDataTypeIndexedDBDatabases,
                                //WKWebsiteDataTypeWebSQLDatabases
                                ]];
        //// All kinds of data
        //NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        //// Date from
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        //// Execute
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            // Done
        }];
        
    } else {
        
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
        
    }
    
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
        
    } else if ([message.name isEqualToString:@"userType"]) {
        NSLog(@"%@", message.body);

        NSInteger userType = [message.body integerValue];
        if (userType == 1) {
            playBtn.hidden = NO;
//            [Progress progressShowcontent:@"您是该校教师，可以进行直播哦。" currView:self.view];
        } else {
            [Progress progressShowcontent:@"您在该校不是教师身份，不能进行直播哦。" currView:self.view];
            playBtn.hidden = YES;
        }
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
    [loadIndicator stopAnimation];
    if (theConnection) {
        //        SAFE_RELEASE(theConnection);
        NSLog(@"safe release connection");
    }
//    if (loadNotFinishCode == NSURLErrorCancelled)  {
//            return;
//    }
    if (error.code == 22) {//The operation couldn’t be completed. Invalid argument
        //        [self openNextLink];

        NSLog(@"22");}
    else if (error.code == -1001) {//The request timed out.  webview code -999的时候会收到－1001，这里可以做一些超时时候所需要做的事情，一些提示什么的
        //        [self openNextLink];
        NSLog(@"-1001");
        
    }
    else if (error.code == -1005) {//The network connection was lost.
        //        [self openNextLink];
        NSLog(@"-1005");

    }
    else if (error.code == -1009){ //The Internet connection appears to be offline
        //do nothing
        NSLog(@"-1009");

        
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
}
- (IBAction)overViewBtnAction:(UIButton *)sender {
    [self hiddenVedioBtnView:YES];
    sender.hidden = !sender.hidden;
    self.vedioBtn.selected = !sender.hidden;
}


- (IBAction)vedioBtnAction:(UIButton *)sender {
    
    if (sender.tag == 1) {//视频按钮
        [self hiddenVedioBtnView:sender.selected];
        sender.selected = !sender.selected;

    } else if (sender.tag == 2) {//直播按钮
        [self liveBtnAction];
        [self hiddenVedioBtnView:YES];
    } else if (sender.tag == 3) {//录播按钮
        [self hiddenVedioBtnView:YES];
        [self recorderView];
    }
    self.overBtn.hidden = sender.hidden;
    
}

- (void)hiddenVedioBtnView:(BOOL)hidden {

    self.vedioBackView.hidden = hidden;
    self.liveBtn.hidden = hidden;
    self.recordBtn.hidden = hidden;
}

- (void)recorderView {
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.shouldChangeOrientation = YES;

    RecorderViewController *recoderView = [[RecorderViewController  alloc] init];
    recoderView.userClassInfo = classesArray;
    recoderView.userRole = self.userRole;
    recoderView.userId = self.userId;
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:recoderView];
    nav.navigationBarHidden = YES;
    [self presentViewController:nav animated:NO completion:^{
    }];
    
}

#pragma mark- 直播按钮事件

- (void)liveBtnAction {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if (classesArray.count >0) {
        

        StreamingViewModel* vmodel = [[StreamingViewModel alloc] initWithPushUrl:@""];
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        app.shouldChangeOrientation = YES;
        
        ViewController *VC = [board instantiateViewControllerWithIdentifier:@"ViewController"];
        VC.userClassInfo = classesArray;
        VC.userId = self.userId;
        VC.userRole = self.userRole;
        VC.accessToken = self.accessToken;
        VC.openId = self.openId;
        VC.schoolId = CSchoolId;
        VC.schoolName = CSchoolName;
        VC.model = vmodel;
//        [vmodel setupSession:AVCaptureVideoOrientationLandscapeRight delegate:VC];

        if (CSchoolId.length == 0) {
            [Progress progressShowcontent:@"请选择学校" currView:self.view];
            return;
        }

        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:VC];
        nav.navigationBarHidden = YES;
        [self presentViewController:nav animated:NO completion:^{
        }];
        
    } else {
        [Progress progressShowcontent:@"您在该校不是教师身份，不能进行直播哦。" currView:self.view];
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
        if (self.appToken) {
            if (self.fromBack == NO) {
                self.backImage.hidden = YES;
                self.backBtn.hidden = YES;
  
            }
        }
    }else{
        [self.view resignFirstResponder];
        //        [self.navigationController popViewControllerAnimated:YES];
        NSString *alerMessage = self.appToken?@"是否关闭应用！":@"是否要退出登录！";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:alerMessage preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (self.appToken) {
                [self exitApplication];
            } else {
                LogInViewController *logView = [[LogInViewController alloc] init];
                [self restoreRootViewController:logView];
            }
            
        }]];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
}

- (void)exitApplication {
    UIButton *playBtn = [self.view viewWithTag:110];
    playBtn.hidden = YES;
    [UIView animateWithDuration:0.01f animations:^{
        self.curveView.hidden = NO;
        WWebView.frame = CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT, 0, 0);
    } completion:^(BOOL finished) {
        abort();
    }];
    //exit(0);
    
}


#pragma mark - 初始化设备旋转监听管理

- (void)initDeviceOrientation {
    //----- SETUP DEVICE ORIENTATION CHANGE NOTIFICATION -----1
    //    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    //    [device beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
    //    NSNotificationCenter *notificatioCenter = [NSNotificationCenter defaultCenter]; //Get the notification centre for the app
    //    [notificatioCenter addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:device];
    motionManager = [[CMMotionManager alloc] init];
    if (motionManager.deviceMotionAvailable) {
        motionManager.deviceMotionUpdateInterval = 1;
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                           withHandler:^(CMDeviceMotion *data, NSError *error) {
                                               double rotation = atan2(data.gravity.x,data.gravity.y)*180/M_PI;
                                               if (rotation>135 || rotation<-135) {
                                                   [self orientationChangedWithDeviceOrientation:UIDeviceOrientationPortrait];
                                               } else if (rotation>-135 && rotation<-45) {
                                                   [self orientationChangedWithDeviceOrientation:UIDeviceOrientationLandscapeLeft];
                                               } else if (rotation>-45 && rotation<45) {
                                                   [self orientationChangedWithDeviceOrientation:UIDeviceOrientationPortraitUpsideDown];
                                               } else {
                                                   [self orientationChangedWithDeviceOrientation:UIDeviceOrientationLandscapeRight];
                                               }
                                           }];
    }
    
}

#pragma mark - 更具设备旋转方向设置旋转角度  uiioiu
- (void)orientationChangedWithDeviceOrientation:(UIDeviceOrientation ) orientation {
    //UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == _deviceOrientation) {
        return;
    }
    _deviceOrientation = orientation;
    switch (orientation) {
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
//            [self endFullScreen];
            
            break;
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            
            break;
        case UIDeviceOrientationLandscapeLeft:      // Device oriented horizontally, home button on the right
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
//            [self begainFullScreen];
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
//            [self begainFullScreen];

            break;
        default:
            break;
    }
}

#pragma - mark  进入全屏
-(void)begainFullScreen {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.shouldChangeOrientation = YES;
    
    [[UIDevice currentDevice] setValue:@"UIInterfaceOrientationLandscapeLeft" forKey:@"orientation"];
    
    int count = [UIApplication sharedApplication].windows.count;
    NSLog(@"%@", [UIApplication sharedApplication].windows.lastObject.subviews.firstObject);
    NSLog(@"key=%@",[UIApplication sharedApplication].windows);
    //强制zhuan'p：
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)] && count==4) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeLeft;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}


#pragma - mark 退出全屏
-(void)endFullScreen {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.shouldChangeOrientation = NO;
    
    //强制归正：
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val =UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    //    [WWebView.scrollView setContentOffset:CGPointMake(0, -32)];
    [MobClick beginLogPageView:@"H5View"];
}

- (void)viewDidDisappear:(BOOL)animated {

    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"H5View"];
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
