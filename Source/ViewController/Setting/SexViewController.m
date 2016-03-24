//
//  SexViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/12.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "SexViewController.h"
#import "AgeViewController.h"

@interface SexViewController ()

@end

@implementation SexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"我的资料";
    self.view.backgroundColor = kThemeGrayColor;
    self.navigationItem.leftBarButtonItem.title = @"";
    
    // 设置
    UIBarButtonItem *rightBarButton=[[UIBarButtonItem alloc] initWithTitle:@"跳过" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick:)];
    if(self.isJump)
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    UIButton *btnman = [[UIButton alloc] initWithFrame:CGRectMake((ScreenWidth - 110)/2, 60, 110, 110)];
    [btnman addTarget:self action:@selector(btnfaleClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnman setBackgroundImage:[UIImage imageNamed:@"man"] forState:UIControlStateNormal];
    [self.view addSubview:btnman];
    
    UILabel *lblman = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth - 110)/2, 60 + 120, 110, 20)];
    lblman.text = @"男";
    lblman.font = [UIFont systemFontOfSize:18];
    lblman.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lblman];
    
    UIButton *btnwoman = [[UIButton alloc] initWithFrame:CGRectMake((ScreenWidth - 110)/2, 60 + 180, 110, 110)];
    [btnwoman addTarget:self action:@selector(btnMefaleClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnwoman setBackgroundImage:[UIImage imageNamed:@"woman"] forState:UIControlStateNormal];
    [self.view addSubview:btnwoman];
    
    UILabel *lblwomen = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth - 110)/2, 60 + 120 + 180, 110, 20)];
    lblwomen.text = @"女";
    lblwomen.font = [UIFont systemFontOfSize:18];
    lblwomen.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lblwomen];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSInteger first = [[[NSUserDefaults standardUserDefaults] objectForKey:@"firstDownload"] integerValue];
    if (first == 1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.size = CGSizeMake(40, 40);
        button.alpha = 0;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = item;
    }
    
}


- (void)btnfaleClick:(id)sender
{
    NSString *sexValue = @"男";
    CurrentUser.sex = sexValue;
    
//    //修改数据库信息
//    BasicInfomationModel *changeModel = [DBManager selectBasicInfomation];
//    changeModel.gender = sexValue;
//    BOOL change = [DBManager insertOrReplaceBasicInfomation:changeModel];
//    if (!change) {
//        DLog(@"修改性别失败");
//    }
    
    [self PushToVC];
}

- (void)btnMefaleClick:(id)sender
{
    NSString *sexValue = @"女";
    CurrentUser.sex = sexValue;
    
//    //修改数据库信息
//    BasicInfomationModel *changeModel = [DBManager selectBasicInfomation];
//    changeModel.gender = sexValue;
//    BOOL change = [DBManager insertOrReplaceBasicInfomation:changeModel];
//    if (!change) {
//        DLog(@"修改性别失败");
//    }
    
    [self PushToVC];
}

- (void)rightBarButtonClick:(id)sender
{
    [self PushToVC];
}

- (void)PushToVC{
    AgeViewController *VC = [[AgeViewController alloc] init];
    VC.isJump = self.isJump;
    [self.navigationController pushViewController:VC animated:YES];
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
