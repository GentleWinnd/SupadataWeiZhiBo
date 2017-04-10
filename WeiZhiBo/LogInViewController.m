//
//  LogInViewController.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/21.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "LogInViewController.h"
#import "ViewController.h"
#import "HeEducationH5ViewController.h"


@interface LogInViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *accountField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) MBProgressManager *progressM;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _accountField.text = @"13770623329";
    _passwordField.text = @"abc123";
}


- (IBAction)loginClickAction:(UIButton *)sender {
    
    NSString *account = _accountField.text;
    NSString *pw = _passwordField.text;
    
    if (account.length == 0) {
        [Progress progressShowcontent:@"请输入手机号"];
        return;
    } else if (pw.length == 0) {
        [Progress progressShowcontent:@"请输入密码"];
        return;
    }
    
    NSDictionary *parameter = @{@"phone":account,
                                @"password":pw,
                                @"flag":@"2"};
    
    _progressM = [[MBProgressManager alloc] init];
    [_progressM loadingWithTitleProgress:@""];
    
   [WZBNetServiceAPI postLoginWithParameters:parameter success:^(id responseObject) {
       if ([responseObject[@"status"] intValue] == 1) {//登陆成功
           NSDictionary *logInfo = [NSDictionary safeDictionary:responseObject[@"data"]];
           [self loginByHeBaby:@{@"access_token":logInfo[@"uAccessToken"],
                                 @"open_id":logInfo[@"uOpenId"]}];

       } else {
           [_progressM hiddenProgress];
           [Progress progressShowcontent:@"账户或密码错误，请检查"];
       }
   } failure:^(NSError *error) {
       [_progressM hiddenProgress];
       [KTMErrorHint showNetError:error inView:self.view];
       
   }];
}



- (void)loginByHeBaby:(NSDictionary *) parameter {
    
    
    [WZBNetServiceAPI postLoginByHeBabyWithParameters:parameter success:^(id responseObject) {
        [_progressM hiddenProgress];
        if ([responseObject[@"status"] intValue] == 1) {//登陆成功
            dispatch_async(dispatch_get_main_queue(), ^{
                [Progress progressShowcontent:@"登陆成功"];
                
            });

            HeEducationH5ViewController *heView = [[HeEducationH5ViewController alloc] init];
            heView.userClassInfo = [NSArray safeArray:responseObject[@"data"][@"school"]];
            heView.phoneNUM = responseObject[@"data"][@"user"][@"uId"];
          
            [self restoreRootViewController:heView];
            
        } else {
            [Progress progressShowcontent:@"账户或密码错误，请检查"];
        }
    } failure:^(NSError *error) {
        [_progressM hiddenProgress];
        [KTMErrorHint showNetError:error inView:self.view];
        
    }];

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

- (IBAction)securatyTextBtn:(UIButton *)sender {
    _passwordField.secureTextEntry = sender.selected;
    sender.selected = !sender.selected;
    
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
