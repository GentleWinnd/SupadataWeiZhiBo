//
//  HeEducationH5ViewController.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/29.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "HeEducationH5ViewController.h"
#import "WebViewJavascriptBridge.h"
#import "LogInViewController.h"
#import "ViewController.h"
#import "ReloadView.h"

@interface HeEducationH5ViewController ()<UIWebViewDelegate,UINavigationControllerDelegate, WebViewJavascriptBridgeDelegate>
{
    UIWebView *webView;
    MBProgressManager *loadProgress;
    WebViewJavascriptBridge *bridge;
}
@end

@implementation HeEducationH5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.delegate = self;

    [self initWebView];
    [self customPlayBtn];
    [self createBackView];
}

- (void)customPlayBtn {

    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.frame = CGRectMake(SCREEN_WIDTH - 18 - 50, 30, 45, 45);
    [playBtn setImage:[UIImage imageNamed:@"zhibo"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    playBtn.hidden = YES;
    playBtn.tag = 110;
    [self.view addSubview:playBtn];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doHandlePanAction:)];
    [playBtn addGestureRecognizer:pan];
    
}

- (void)createBackView {
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(15, 30, 45, 45);
    backBtn.backgroundColor = [UIColor whiteColor];
    backBtn.layer.cornerRadius = 45/2;
    
    [backBtn setImage:[UIImage imageNamed:@"no.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(backPanAction:)];
    [backBtn addGestureRecognizer:pan];
    
}

- (void)backBtnAction:(UIButton *)sender {

    LogInViewController *logView = [[LogInViewController alloc] init];
    [self restoreRootViewController:logView];
}

- (void)backPanAction:(UIPanGestureRecognizer *)paramSender {
    
    CGPoint point = [paramSender translationInView:self.view];
    if (point.x>0) {
        
    }
//    NSLog(@"X:%f;Y:%f",point.x,point.y);
    paramSender.view.center = CGPointMake(paramSender.view.center.x + point.x, paramSender.view.center.y + point.y);
    [paramSender setTranslation:CGPointMake(0, 0) inView:self.view];

}

#pragma mark - pangesturehandle

- (void) doHandlePanAction:(UIPanGestureRecognizer *)paramSender{
    
    CGPoint point = [paramSender translationInView:self.view];
//    NSLog(@"X:%f;Y:%f",point.x,point.y);
    paramSender.view.center = CGPointMake(paramSender.view.center.x + point.x, paramSender.view.center.y + point.y);
    [paramSender setTranslation:CGPointMake(0, 0) inView:self.view];
    
}

- (void)playAction:(UIButton *)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ViewController *VC = [board instantiateViewControllerWithIdentifier:@"ViewController"];
    VC.userClassInfo = self.userClassInfo;
    VC.phoneNUM = self.phoneNUM;
    VC.accessToken = self.accessToken;
    VC.openId = self.openId;
//    [self presentViewController:VC animated:YES completion:nil];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)initWebView {
    CGRect frame = self.view.bounds;
    webView = [[UIWebView alloc] initWithFrame:frame];
    webView.delegate = self;
    bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    bridge.WJDelegate = self;
    //注册OC的方法给JS
    [bridge registerHandler:@"getSchoolId" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"======%@",data);
        
    }];
//    [bridge callHandler:<#(NSString *)#> data:<#(id)#>];
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://live.sch.supadata.cn/ssm//resource/html/teacher/?user=630584331#/tab/camera"]]];
//   [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.149:8080/ssm/resource/html/teacher/?user=630584331/tab/camera"]]];
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://wangjunwei.uicp.io:8080/ssm/resource/html/teacher/?user=630584331/tab/camera"]]];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://live.sch.supadata.cn/ssm//resource/html/teacher/?user=%@#/tab/camera",self.phoneNUM]]]];
    //http://193.168.1.149:8080/ssm/resource/html/teacher/?user=630584331/tab/camera
    //http://wangjunwei.uicp.io:8080/ssm/resource/html/teacher/?user=630584331/tab/camera
    [self.view addSubview:webView];

}

#pragma mark - WJDelegate
- (void)WJWebViewStartLoad:(UIWebView *)webView {
    
    loadProgress = [[MBProgressManager alloc] init];
    [loadProgress loadingWithTitleProgress:@"加载中..."];
    UIView *reloadView = [self.view viewWithTag:112];
    if (reloadView) {
        [reloadView removeFromSuperview];
    }

}

- (void)WJWebViewLoadFinished:(UIWebView *)webView {

    [loadProgress hiddenProgress];
    UIButton *btn = (UIButton *)[self.view viewWithTag:110];
    btn.hidden = NO;

}

- (void)WJWebViewLoadFailed:(UIWebView *)webView withError:(NSError *)error {
    [self createReloadView];

}


//- (void)webViewDidStartLoad:(UIWebView *)webView {
//    loadProgress = [[MBProgressManager alloc] init];
//    [loadProgress loadingWithTitleProgress:@"加载中..."];
//    UIView *reloadView = [self.view viewWithTag:112];
//    if (reloadView) {
//        [reloadView removeFromSuperview];
//    }
//}
//
//-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//
//    return YES;
//}
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [loadProgress hiddenProgress];
//    UIButton *btn = (UIButton *)[self.view viewWithTag:110];
//    btn.hidden = NO;
//    
//}
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    [self createReloadView];
//
//}

- (void)createReloadView {
    ReloadView *reloadView = [[ReloadView alloc] initWithFrame:CGRectMake(0, 0, 38, 48)];
    reloadView.reloadView = ^(){
        [webView reload];
    };
    reloadView.tag = 112;
    [self.view addSubview:reloadView];

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
