//
//  ForgotPasswordCtrl.m
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/14.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "ForgotPasswordCtrl.h"
#import "OperateViewModel.h"

@interface ForgotPasswordCtrl()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (nonatomic , strong) OperateViewModel *operateVM;

@property (nonatomic , strong) UIImageView *iconView;

@property (nonatomic , strong) UILabel *detailLabel;

@property (nonatomic , strong) UIButton *resendBtn;

@end

@implementation ForgotPasswordCtrl

- (void)viewDidLoad
{
    self.title = @"找回密码";
    self.view.backgroundColor = kThemeGrayColor;
    
    _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - 20, 30, 40, 40)];
    _iconView.image = [UIImage imageNamed:@"star-green"];
    _iconView.alpha = 0;
    [self.view addSubview:_iconView];
    
    _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - 120, 80, 240, 30)];
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    _detailLabel.alpha = 0;
    [self.view addSubview:_detailLabel];
    
    _resendBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 130, kScreenWidth - 30, 35)];
    _resendBtn.backgroundColor = KThemeGreenColor;
    [_resendBtn setTitle:@"重新发送密码到邮箱" forState:UIControlStateNormal];
    [_resendBtn addTarget:self action:@selector(resendEmail) forControlEvents:UIControlEventTouchUpInside];
    _resendBtn.alpha = 0;
    [self.view addSubview:_resendBtn];
    
}

- (IBAction)forgotPassword:(id)sender {
    if ([_emailTextField.text rangeOfString:@"@"].location == NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"账号格式不正确"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }else
    {
        __weak ForgotPasswordCtrl *blockSelf = self;
        [self.operateVM forgetPasswordWithEmail:_emailTextField.text];
        
        self.operateVM.finishHandler = ^(BOOL finished, id userInfo){
            if (finished) {
//                [MBProgressHUD showHUDByContent:userInfo view:blockSelf.view afterDelay:2];
                 blockSelf.emailTextField.alpha = 0;
                
                
            }else{
                [MBProgressHUD showHUDByContent:userInfo view:blockSelf.view afterDelay:2];
            }
        };
    }

}

- (void)resendEmail
{
    __weak ForgotPasswordCtrl *blockSelf = self;
    [self.operateVM forgetPasswordWithEmail:_emailTextField.text];
    
    self.operateVM.finishHandler = ^(BOOL finished, id userInfo){
        if (finished) {
            [MBProgressHUD showHUDByContent:userInfo view:blockSelf.view afterDelay:2];
            
        }else{
            [MBProgressHUD showHUDByContent:userInfo view:blockSelf.view afterDelay:2];
        }
    };
}


@end
