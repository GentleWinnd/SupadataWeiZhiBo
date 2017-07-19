//
//  LogInViewController.m
//  WeiZhiBo
//
//  Created by YH on 2017/3/21.
//  Copyright © 2017年 YH. All rights reserved.
//
#import "HeEducationH5ViewController.h"
#import "LogInViewController.h"
#import "StreamingViewModel.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "UserData.h"
#import "User.h"


@interface LogInViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *accountField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;

@property (strong, nonatomic) IBOutlet UIImageView *PLIne;
@property (strong, nonatomic) IBOutlet UIImageView *Aline;
@property (strong, nonatomic) IBOutlet UIImageView *AImageView;
@property (strong, nonatomic) IBOutlet UIImageView *PImageView;


@property (strong, nonatomic) MBProgressManager *progressM;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *openId;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    [self setTextFeild];
}

- (void)setTextFeild {
    User *user = [UserData getUser];
    _accountField.text = user.userName;
    _passwordField.text = user.userPass;
    _passwordField.delegate = self;
    _accountField.delegate = self;
    
    [_accountField addTarget:self action:@selector(acountAction:) forControlEvents:UIControlEventEditingChanged];
    [_passwordField addTarget:self action:@selector(passwordAction:) forControlEvents:UIControlEventEditingChanged];

    [self setShowData];
}

- (void)acountAction:(UITextField *)textfeild {
    [self setShowData];
}

- (void)passwordAction:(UITextField *)textfeild {
    [self setShowData];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self setShowData];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    UIImage *Orangeimage = [UIImage imageNamed:@"line_orange"];
    
    if (textField == _accountField) {
        _AImageView.image = [UIImage imageNamed:@"tel_s"];
        _Aline.image = Orangeimage;
        if (_passwordField.text.length>0) {
            _loginBtn.selected = YES;
        } else {
            _loginBtn.selected = NO;
        }
    }
    
    if ( textField == _passwordField) {
        _PLIne.image = Orangeimage;
        _PImageView.image = [UIImage imageNamed:@"sec_s"];
        if (_accountField.text.length > 0) {
            _loginBtn.selected = YES;

        } else {
            _loginBtn.selected = NO;
        }
    }
}

#pragma mark - showSetData

- (void)setShowData {
    UIImage *GrayImage = [UIImage imageNamed:@"line_gray"];
    UIImage *Orangeimage = [UIImage imageNamed:@"line_orange"];
    
    BOOL canLogin = _accountField.text.length >0 && _passwordField.text.length >0?YES:NO;
    if (_accountField.text.length == 0) {
        _Aline.image = GrayImage;
        _AImageView.image = [UIImage imageNamed:@"tel_n"];
    } else {
        _AImageView.image = [UIImage imageNamed:@"tel_s"];
        _Aline.image = Orangeimage;
    }
    
    if (_passwordField.text.length == 0) {
        _PLIne.image = GrayImage;
        _PImageView.image = [UIImage imageNamed:@"sec_n"];
    
    } else {
        _PLIne.image = Orangeimage;
        _PImageView.image = [UIImage imageNamed:@"sec_s"];
    }
    
    _loginBtn.selected = canLogin;
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
           self.accessToken = logInfo[@"uAccessToken"];
           self.openId = logInfo[@"uOpenId"];
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

            [Progress progressShowcontent:@"登录成功" currView:self.view];

            [self performSelector:@selector(showMainView:) withObject:responseObject afterDelay:0.3];
            
        } else {
            [Progress progressShowcontent:@"账户或密码错误，请检查"];
        }
    } failure:^(NSError *error) {
        [_progressM hiddenProgress];
        [KTMErrorHint showNetError:error inView:self.view];
        
    }];

}


#pragma mark - show mainView

- (void)showMainView:(NSDictionary *)responseObject {
    User *user = [[User alloc] init];
    user.userName = self.accountField.text;
    user.userPass = self.passwordField.text;
    user.userID = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"user"][@"uId"]];
    user.nickName = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"user"][@"uNickName"]];
    [UserData storeUserData:user];

    BOOL isOnline = [NSString safeNumber:responseObject[@"data"][@"isonline"]].boolValue;
    if (isOnline) {
        HeEducationH5ViewController *heView = [[HeEducationH5ViewController alloc] init];
        heView.userClassInfo = [NSArray safeArray:responseObject[@"data"][@"school"]];
        heView.userId = responseObject[@"data"][@"user"][@"uId"];
        heView.accessToken = self.accessToken;
        heView.openId = self.openId;
        heView.userRole = UserRoleTeacher;
        
       [self restoreRootViewController:heView];

    } else {
        
        NSDictionary *schoolInfo = [NSArray  safeArray:responseObject[@"data"][@"school"]].firstObject;
        AppDelegate *app = [UIApplication sharedApplication].delegate;
        app.shouldChangeOrientation = YES;
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        StreamingViewModel* vmodel = [[StreamingViewModel alloc] initWithPushUrl:@""];
        [vmodel setupSession:AVCaptureVideoOrientationLandscapeRight delegate:self];

        NSString *schoolId = [NSString stringWithFormat:@"%@",schoolInfo[@"schoolId"]];
        ViewController *VC = [board instantiateViewControllerWithIdentifier:@"ViewController"];
        VC.userClassInfo = [NSArray safeArray:schoolInfo[@"classes"]];
        VC.userId = responseObject[@"data"][@"user"][@"uId"];
        VC.userRole = UserRoleTeacher;
        VC.accessToken = self.accessToken;
        VC.openId = self.openId;
        VC.schoolId = schoolInfo[@"schoolId"];
        VC.schoolName = schoolInfo[@"schoolName"];
        VC.model = vmodel;
        
        if (schoolId.length == 0) {
            [Progress progressShowcontent:@"请选择学校" currView:self.view];
            return;
        }

        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:VC];
        nav.navigationBarHidden = YES;
        [self presentViewController:nav animated:NO completion:^{

        }];
    }
}


// 登陆后淡入淡出更换rootViewController
- (void)restoreRootViewController:(UIViewController *)rootViewController {
    typedef void (^Animation)(void);
//    
//    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
//    navVC.navigationBarHidden = YES;
//    navVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
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
                    completion:^(BOOL finished) {

                    }];
}

- (IBAction)securatyTextBtn:(UIButton *)sender {
    _passwordField.secureTextEntry = sender.selected;
    sender.selected = !sender.selected;
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [MobClick endLogPageView:@"LoginView"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [MobClick beginLogPageView:@"LoginView"];

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
