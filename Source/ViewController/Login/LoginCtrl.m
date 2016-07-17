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
#import "nickNameController.h"

@interface LoginCtrl ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btn_register;
@property (weak, nonatomic) IBOutlet UIButton *btn_login;
@property (weak, nonatomic) IBOutlet UIButton *btn_FindPwd;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UIImageView *usernamebgbox;
@property (weak, nonatomic) IBOutlet UIImageView *passwordbgbox;

@property (nonatomic,strong) OperateViewModel *operateVM;

@property (nonatomic , assign) NSInteger firstDownload;

- (IBAction)btnLoginClick:(id)sender;
- (IBAction)btnRegisterClick:(id)sender;
- (IBAction)btnFindPwdClick:(id)sender;


@end

@implementation LoginCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"登录";
    self.view.backgroundColor = kThemeGrayColor;
    self.operateVM = [[OperateViewModel alloc] init];
    self.iconImage.image = [UIImage imageNamed:@"logo"];
    self.usernamebgbox.image = [UIImage imageNamed:@"loginbox"];
    self.passwordbgbox.image = [UIImage imageNamed:@"loginbox"];
    
    self.usernamebgbox.userInteractionEnabled = YES;
    self.passwordbgbox.userInteractionEnabled = YES;
    
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    
    // 用户
    UIImageView *usericon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 13, 20, 20)];
    usericon.image = [UIImage imageNamed:@"user"];
    [self.usernamebgbox addSubview:usericon];
    self.txtUserAccount = [[UITextField alloc] initWithFrame:CGRectMake(50, 8, 300, 30)];
    
    self.txtUserAccount.placeholder = @"请输入用户名";
    [self.usernamebgbox addSubview:self.txtUserAccount];
    
    
    // 用户
    UIImageView *passwordicon = [[UIImageView alloc] initWithFrame:CGRectMake(15, 13, 20, 20)];
    passwordicon.image = [UIImage imageNamed:@"password"];
    [self.passwordbgbox addSubview:passwordicon];
    self.txtUserPassword = [[UITextField alloc] initWithFrame:CGRectMake(50, 8, 300, 30)];
    self.txtUserPassword.placeholder = @"请输入密码";
    [self.passwordbgbox addSubview:self.txtUserPassword];
    if (userName && password) {
        NSInteger isAppIn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"appDelegateToLogin"] integerValue];
        if (isAppIn == 1) {
            self.txtUserAccount.text = userName;
            self.txtUserPassword.text = password;
            [[NSUserDefaults standardUserDefaults] setObject:@2 forKey:@"appDelegateToLogin"];
        }
    }else{
#if DEBUG
       self.txtUserAccount.text = @"1989215@qq.com";
        self.txtUserPassword.text = @"123456";
#else
        self.txtUserAccount.text = @"";
        self.txtUserPassword.text = @"";
#endif
    }

    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerAndLogin:) name:registerSuccessToLogin object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.size = CGSizeMake(40, 40);
    button.alpha = 0;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = item;
    BOOL first = [[NSUserDefaults standardUserDefaults] objectForKey:FIRSTDOWNLAOD]?YES:NO;
    if (!first) {
        DLog(@"第一次登陆");
        _firstDownload = 1;
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:@(1) forKey:FIRSTDOWNLAOD];
        [userDefaults synchronize];
        
    }else{
        _firstDownload = [[[NSUserDefaults standardUserDefaults] objectForKey:FIRSTDOWNLAOD] integerValue];
    }
}

- (IBAction)btnLoginClick:(id)sender {
    
    if (self.txtUserAccount.text.length > 0 && [self.txtUserAccount.text rangeOfString:@"@"].location != NSNotFound ) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:UI_Window animated:YES];
        hud.labelText = @"登录中...";
        [self.operateVM loginWithUserName:self.txtUserAccount.text password:self.txtUserPassword.text];
        [[NSUserDefaults standardUserDefaults] setObject:self.txtUserAccount.text forKey:@"userName"];
        [[NSUserDefaults standardUserDefaults] setObject:self.txtUserPassword.text forKey:@"password"];
        
    }else
    {
        [MBProgressHUD showHUDByContent:@"账号格式不正确" view:UI_Window afterDelay:2];
    }
    
    __block LoginCtrl *blockSelf = self;
    self.operateVM.finishHandler = ^(BOOL finished, id userInfo) { // 网络数据回调
        
        if (finished) {
            [MBProgressHUD hideAllHUDsForView:UI_Window animated:YES];
            if (userInfo[@"nickName"] && userInfo[@"age"]) {
                
                blockSelf.firstDownload = 2;
                [[NSUserDefaults standardUserDefaults] setObject:@(blockSelf.firstDownload) forKey:FIRSTDOWNLAOD];
            }
            if (_firstDownload == 1) {
                [[UserManager defaultInstance] saveUser:userInfo];
                nickNameController *nickNameCtl = [[nickNameController alloc] init];
                [blockSelf.navigationController pushViewController:nickNameCtl animated:YES];
            }else{
                [[UserManager defaultInstance] saveUser:userInfo];
                BasicInfomationModel *info = [DBManager selectBasicInfomation];
                BasicInfomationModel *infoModel = [[BasicInfomationModel alloc] init];
                infoModel.nickName = CurrentUser.nickName;
                infoModel.gender = CurrentUser.sex;
                infoModel.age = CurrentUser.age;
                infoModel.height = [CurrentUser.high integerValue];
                infoModel.weight = [CurrentUser.weight integerValue];
                infoModel.distance = [CurrentUser.stepLong integerValue];
                BOOL Info = [DBManager insertOrReplaceBasicInfomation:infoModel];
                if (!Info) {
                    DLog(@"存入用户信息失败");
                }
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:DOWNLOADSUCCESS];
            [[AppDelegate defaultDelegate] exchangeRootViewControllerToMain];
            }
        } else {
            [MBProgressHUD hideAllHUDsForView:UI_Window animated:NO];
            [blockSelf showHUDText:userInfo];
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

- (void)registerAndLogin: (NSNotification *)sender
{
    __block LoginCtrl *blockSelf = self;
    NSString *userName = sender.userInfo[@"userName"];
    NSString *password = sender.userInfo[@"password"];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:UI_Window animated:YES];
    hud.labelText = @"登录中...";
    [self.operateVM loginWithUserName:userName password:password];
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"userName"];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
    self.operateVM.finishHandler = ^(BOOL finished, id userInfo) { // 网络数据回调
        if (finished) {
            [MBProgressHUD hideAllHUDsForView:UI_Window animated:YES];
            if (_firstDownload == 1) {
                [[UserManager defaultInstance] saveUser:userInfo];
                nickNameController *nickNameCtl = [[nickNameController alloc] init];
                [blockSelf.navigationController pushViewController:nickNameCtl animated:YES];
            }
        } else {
            [blockSelf showHUDText:userInfo];
        }
    };
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    [self.txtUserAccount resignFirstResponder];
    [self.txtUserPassword resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
