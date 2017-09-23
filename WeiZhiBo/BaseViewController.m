//
//  BaseViewController.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/9/15.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "BaseViewController.h"
#import "TRDAnimationIndicator.h"

@interface BaseViewController ()<TRDAnimationIndicatorDelegate>
{
    TRDAnimationIndicator *loadIndicator;
}
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}





#pragma mark - 创建加载动画

- (void)createLoadIndicator {
    
    loadIndicator = [[TRDAnimationIndicator alloc] initWithFrame:self.view.bounds];
    loadIndicator.delegate = self;
    [self.view addSubview:loadIndicator];
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
