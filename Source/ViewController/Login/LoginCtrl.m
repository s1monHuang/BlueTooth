//
//  LoginCtrl.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/3.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "LoginCtrl.h"
#import "ForgotPasswordCtrl.h"
#import "RegisterCtrl.h"
#import "OperateViewModel.h"

#import "UserEntity.h"
#import "UserManager.h"

@interface LoginCtrl ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btn_register;
@property (weak, nonatomic) IBOutlet UIButton *btn_login;
@property (weak, nonatomic) IBOutlet UIButton *btn_FindPwd;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UIImageView *usernamebgbox;
@property (weak, nonatomic) IBOutlet UIImageView *passwordbgbox;

@property (nonatomic,strong) OperateViewModel *operateVM;

@property (strong, nonatomic)  UITextField *txtUserAccount;
@property (strong, nonatomic)  UITextField *txtUserPassword;

- (IBAction)btnLoginClick:(id)sender;
- (IBAction)btnRegisterClick:(id)sender;
- (IBAction)btnFindPwdClick:(id)sender;


@end

@implementation LoginCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"登录";
    self.view.backgroundColor = kThemeGrayColor;
    self.operateVM = [OperateViewModel viewModel];
    self.iconImage.image = [UIImage imageNamed:@"logo"];
    self.usernamebgbox.image = [UIImage imageNamed:@"loginbox"];
    self.passwordbgbox.image = [UIImage imageNamed:@"loginbox"];
    
    self.usernamebgbox.userInteractionEnabled = YES;
    self.passwordbgbox.userInteractionEnabled = YES;
    
    // 用户
    UIImageView *usericon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 13, 20, 20)];
    usericon.image = [UIImage imageNamed:@"user"];
    [self.usernamebgbox addSubview:usericon];
    self.txtUserAccount = [[UITextField alloc] initWithFrame:CGRectMake(50, 8, 300, 30)];
    self.txtUserAccount.text = @"377977004@qq.com";
    self.txtUserAccount.placeholder = @"请输入用户名";
    [self.usernamebgbox addSubview:self.txtUserAccount];
    
    
    // 用户
    UIImageView *passwordicon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 13, 20, 20)];
    passwordicon.image = [UIImage imageNamed:@"password"];
    [self.passwordbgbox addSubview:passwordicon];
    self.txtUserPassword = [[UITextField alloc] initWithFrame:CGRectMake(50, 8, 300, 30)];
    self.txtUserPassword.text = @"111111";
    self.txtUserPassword.placeholder = @"请输入密码";
    [self.passwordbgbox addSubview:self.txtUserPassword];
    
}

- (IBAction)btnLoginClick:(id)sender {
    @weakify(self);
    if (self.txtUserAccount.text.length > 0 && [self.txtUserAccount.text rangeOfString:@"@"].location != NSNotFound ) {
        [self.operateVM loginWithUserName:self.txtUserAccount.text password:self.txtUserPassword.text];
    }else
    {
        [MBProgressHUD showHUDByContent:@"账号格式不正确" view:self.view afterDelay:2];
    }
    self.operateVM.finishHandler = ^(BOOL finished, id userInfo) { // 网络数据回调
        @strongify(self);
        if (finished) {
            [[UserManager defaultInstance] saveUser:userInfo];
            [[AppDelegate defaultDelegate] exchangeRootViewControllerToMain];
            
        } else {
            [self showHUDText:userInfo];
        }
    };
    
}

- (IBAction)btnRegisterClick:(id)sender {
    
    RegisterCtrl *VC = [[RegisterCtrl alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
    
}

- (IBAction)btnFindPwdClick:(id)sender {
    ForgotPasswordCtrl *ctl = [[ForgotPasswordCtrl alloc] init];
    [self.navigationController pushViewController:ctl animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
