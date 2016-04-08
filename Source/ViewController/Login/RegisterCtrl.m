//
//  RegisterCtrl.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/3.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "RegisterCtrl.h"
#import "OperateViewModel.h"

@interface RegisterCtrl ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (nonatomic,strong) OperateViewModel *operateVM;

@property (nonatomic , assign) NSInteger firstDownload;

@property (nonatomic , copy) NSString *userName;

@property (nonatomic , copy) NSString *password;

@end

@implementation RegisterCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"注册";
    self.view.backgroundColor = kThemeGrayColor;
    self.operateVM = [OperateViewModel viewModel];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickRegister:(id)sender {
    if ([_userNameTextField.text rangeOfString:@"@"].location == NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"账号格式不正确"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
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
                [MBProgressHUD showHUDByContent:@"注册成功" view:blockSelf.view afterDelay:2];
                CurrentUser.userId = userInfo;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //注册成功后登陆
                    NSDictionary *userDict = [NSDictionary dictionaryWithObjectsAndKeys:blockSelf.userName,@"userName" ,blockSelf.password, @"password" , nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:registerSuccessToLogin object:nil userInfo:userDict];
                    [blockSelf.navigationController popViewControllerAnimated:YES];
                });
                
            }else{
                [MBProgressHUD showHUDByContent:userInfo view:UI_Window afterDelay:2];
            }
        };
    }
    
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
