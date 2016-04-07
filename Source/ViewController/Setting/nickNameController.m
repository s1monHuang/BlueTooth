//
//  nickNameController.m
//  BlueToothBracelet
//
//  Created by azz on 16/3/16.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "nickNameController.h"
#import "SexViewController.h"

@interface nickNameController ()

@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;

@property (nonatomic , assign) NSInteger first;

@end

@implementation nickNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"昵称";
    self.view.backgroundColor = kThemeGrayColor;
    self.navigationItem.leftBarButtonItem.title = @"";
    
    UIButton *btnPre = [[UIButton alloc] initWithFrame:CGRectMake(0, ScreenHeight - 50 - 64, ScreenWidth/2, 50)];
    [btnPre addTarget:self action:@selector(btnPreClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnPre setTitle:@"上一步" forState:UIControlStateNormal];
    [btnPre setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnPre setBackgroundImage:[UIImage imageNamed:@"square-button2"] forState:UIControlStateNormal];
    [self.view addSubview:btnPre];
    
    UIButton *btnNext = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2, ScreenHeight - 50 - 64, ScreenWidth/2, 50)];
    [btnNext addTarget:self action:@selector(btnNextClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnNext setTitle:@"下一步" forState:UIControlStateNormal];
    [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNext setBackgroundImage:[UIImage imageNamed:@"square-button1"] forState:UIControlStateNormal];
    [self.view addSubview:btnNext];
    
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _first = [[[NSUserDefaults standardUserDefaults] objectForKey:@"firstDownload"] integerValue];
    if (_first == 1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.size = CGSizeMake(40, 40);
        button.alpha = 0;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = item;
    }
    
}


- (IBAction)btnClick:(id)sender {
    
    NSString *nickName = _nickNameTextField.text;
    if (!nickName || nickName.length < 4 || nickName.length > 16 ) {
        [MBProgressHUD showHUDByContent:@"昵称长度必须为4-16个字符！" view:UI_Window afterDelay:2];
        return;
    }
    CurrentUser.nickName = nickName;
    NSInteger first = [[[NSUserDefaults standardUserDefaults] objectForKey:@"firstDownload"] integerValue];
    if (first == 1) {
        [self PushToVC];
    }else{
    [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)btnPreClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnNextClick:(id)sender
{
    NSString *nickName = _nickNameTextField.text;
    if (!nickName || nickName.length < 4 || nickName.length > 16 ) {
        [MBProgressHUD showHUDByContent:@"昵称长度必须为4-16个字符！" view:UI_Window afterDelay:2];
        return;
    }
    CurrentUser.nickName = _nickNameTextField.text;
    [self PushToVC];
}

- (void)rightBarButtonClick:(id)sender
{
    [self PushToVC];
}

- (void)PushToVC
{
    if (_first == 1) {
        SexViewController *VC = [[SexViewController alloc] init];
        NSString *nickName = _nickNameTextField.text;
        if (!nickName || nickName.length < 4 || nickName.length > 16 ) {
            [MBProgressHUD showHUDByContent:@"昵称长度必须为4-16个字符！" view:UI_Window afterDelay:2];
            return;
        }
        CurrentUser.nickName = nickName;
        [self.navigationController pushViewController:VC animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_nickNameTextField resignFirstResponder];
}

@end
