//
//  LogInViewController.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/21.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "LogInViewController.h"
#import "ViewController.h"


@interface LogInViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *accountField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _accountField.text = @"13901589251";
    _passwordField.text = @"dingjl";
}




- (IBAction)loginClickAction:(UIButton *)sender {
    
    NSString *account = _accountField.text;
    NSString *pw = _passwordField.text;
    
    if (account.length == 0) {
        [Progress progressShowcontent:@"请输入电话号码"];
        return;
    } else if (pw.length == 0) {
        [Progress progressShowcontent:@"请输入密码"];
        return;
    }
    
    NSDictionary *parameter = @{@"phone":account,
                                @"password":pw};
    
    
    MBProgressManager *progressM = [[MBProgressManager alloc] init];
    [progressM loadingWithTitleProgress:nil];
    
   [WZBNetServiceAPI postLoginWithParameters:parameter success:^(id responseObject) {
       [progressM hiddenProgress];
       if ([responseObject[@"status"] intValue] == 1) {//登陆成功
           UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
           
           ViewController *VC = [board instantiateViewControllerWithIdentifier:@"ViewController"];
           VC.userClassInfo = [NSArray safeArray:responseObject[@"data"][@"school"]];
           VC.phoneNUM = account;
           [self restoreRootViewController:VC];
           
       } else {
           [Progress progressShowcontent:@"账户或密码错误，请检查"];
       }
   } failure:^(NSError *error) {
       [progressM hiddenProgress];
       [KTMErrorHint showNetError:error inView:self.view];
       
   }];
    
    
}

// 登陆后淡入淡出更换rootViewController
- (void)restoreRootViewController:(UIViewController *)rootViewController {
    typedef void (^Animation)(void);
//    
//    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    rootViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    Animation animation = ^{
        BOOL oldState = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [UIApplication sharedApplication].keyWindow.rootViewController = rootViewController;
        [UIView setAnimationsEnabled:oldState];
    };
    
    [UIView transitionWithView:window
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:animation
                    completion:nil];
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
