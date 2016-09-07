//
//  RegisterCtrl.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/3.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "RegisterCtrl.h"
#import "OperateViewModel.h"
#import "nickNameController.h"

@interface RegisterCtrl ()
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *securityLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (nonatomic,strong) OperateViewModel *operateVM;

@property (nonatomic,strong) OperateViewModel *operateVM1;

@property (nonatomic , assign) NSInteger firstDownload;

@property (nonatomic , copy) NSString *userName;

@property (nonatomic , copy) NSString *password;

@end

@implementation RegisterCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = BTLocalizedString(@"注册");
    self.view.backgroundColor = kThemeGrayColor;
    self.operateVM = [OperateViewModel viewModel];
    self.operateVM1 = [OperateViewModel viewModel];
    _accountLabel.text = BTLocalizedString(@"账户");
    _securityLabel.text = BTLocalizedString(@"密码");
    [_registerBtn setTitle:BTLocalizedString(@"注册") forState:UIControlStateNormal];
    _userNameTextField.placeholder = BTLocalizedString(@"请输入邮箱");
    _passwordTextField.placeholder = BTLocalizedString(@"请输入密码");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickRegister:(id)sender {
    if ([_userNameTextField.text rangeOfString:@"@"].location == NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:BTLocalizedString(@"提示")
                                                        message:BTLocalizedString(@"账号格式不正确")
                                                       delegate:nil
                                              cancelButtonTitle:BTLocalizedString(@"确定")
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }else
    {
        __weak RegisterCtrl *blockSelf = self;
        [self.operateVM registerWithUserName:_userNameTextField.text passsword:_passwordTextField.text];
        _userName = _userNameTextField.text;
        _password = _passwordTextField.text;
        self.operateVM.finishHandler = ^(BOOL finished, id userInfo){
            if (finished) {
                [MBProgressHUD showHUDByContent:BTLocalizedString(@"注册成功") view:blockSelf.view afterDelay:1];
                CurrentUser.userId = userInfo;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //注册成功后登陆
                    [blockSelf setPersonalInformationView];
//                    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:blockSelf.userName,@"userName" ,blockSelf.password, @"password" , nil];
//                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                    [userDefaults setObject:@(1) forKey:FIRSTDOWNLAOD];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:registerSuccessToLogin object:nil userInfo:userDict];
//                    [blockSelf.navigationController popViewControllerAnimated:YES];
                });
                
            }else{
                [MBProgressHUD showHUDByContent:userInfo view:UI_Window afterDelay:2];
            }
        };
    }
    
}

- (void)setPersonalInformationView
{
    __weak RegisterCtrl *blockSelf = self;
    _firstDownload = 1;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(1) forKey:FIRSTDOWNLAOD];
    [userDefaults synchronize];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:UI_Window animated:YES];
    hud.labelText = BTLocalizedString(@"登录中...");
    [[NSUserDefaults standardUserDefaults] setObject:_userName forKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] setObject:_password forKey:@"password"];
    
    [self.operateVM1 loginWithUserName:_userName password:_password];
    self.operateVM1.finishHandler = ^(BOOL finished, id userInfo){
        [MBProgressHUD hideAllHUDsForView:UI_Window animated:YES];
        if (finished) {
            
            [[UserManager defaultInstance] saveUser:userInfo];
            nickNameController *nickNameCtl = [[nickNameController alloc] init];
            [blockSelf.navigationController pushViewController:nickNameCtl animated:YES];
        }else{
             [MBProgressHUD showHUDByContent:BTLocalizedString(@"登录失败") view:blockSelf.view afterDelay:1];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [blockSelf.navigationController popViewControllerAnimated:YES];
            });
        }
        

    };
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
