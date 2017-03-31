//
//  HeEducationH5ViewController.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/29.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "HeEducationH5ViewController.h"
#import "ViewController.h"
#import "ReloadView.h"

@interface HeEducationH5ViewController ()<UIWebViewDelegate,UINavigationControllerDelegate>
{
    UIWebView *webView;
    MBProgressManager *loadProgress;
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
}

- (void)customPlayBtn {

    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playBtn.frame = CGRectMake(SCREEN_WIDTH - 18 - 45, 25, 45, 45);
    [playBtn setImage:[UIImage imageNamed:@"zhibo"] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    playBtn.hidden = YES;
    playBtn.tag = 110;
    [self.view addSubview:playBtn];
    
}

- (void)playAction:(UIButton *)sender {
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ViewController *VC = [board instantiateViewControllerWithIdentifier:@"ViewController"];
    VC.userClassInfo = self.userClassInfo;
    VC.phoneNUM = self.phoneNUM;
//    [self presentViewController:VC animated:YES completion:nil];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)initWebView {
    CGRect frame = self.view.bounds;
//    frame.origin.y = 20;
//    frame.size.height = SCREEN_HEIGHT-20;
    webView = [[UIWebView alloc] initWithFrame:frame];
    webView.delegate = self;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://live.sch.supadata.cn/ssm//resource/html/teacher/?user=630584331#/tab/camera"]]];
    [self.view addSubview:webView];

}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    loadProgress = [[MBProgressManager alloc] init];
    [loadProgress showProgress];
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
    UIButton *btn = (UIButton *)[self.view viewWithTag:110];
    btn.hidden = NO;
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self createReloadView];

}

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
