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
    
    self.title = NSLocalizedString(@"注册", nil);
    self.view.backgroundColor = kThemeGrayColor;
    self.operateVM = [OperateViewModel viewModel];
    self.operateVM1 = [OperateViewModel viewModel];
    _accountLabel.text = NSLocalizedString(@"账户", nil);
    _securityLabel.text = NSLocalizedString(@"密码", nil);
    [_registerBtn setTitle:NSLocalizedString(@"注册", nil) forState:UIControlStateNormal];
    _userNameTextField.placeholder = NSLocalizedString(@"请输入邮箱", nil);
    _passwordTextField.placeholder = NSLocalizedString(@"请输入密码", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickRegister:(id)sender {
    if ([_userNameTextField.text rangeOfString:@"@"].location == NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil)
                                                        message:NSLocalizedString(@"账号格式不正确", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
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
                [MBProgressHUD showHUDByContent:NSLocalizedString(@"注册成功", nil) view:blockSelf.view afterDelay:1];
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:UI_Window animated:YES];
    hud.labelText = NSLocalizedString(@"登录中...", nil);
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
             [MBProgressHUD showHUDByContent:NSLocalizedString(@"登录失败", nil) view:blockSelf.view afterDelay:1];
            
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
