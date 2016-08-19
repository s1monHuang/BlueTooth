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
@property (weak, nonatomic) IBOutlet UIButton *sendEmailBtn;
@property (weak, nonatomic) IBOutlet UIImageView *inputIcon;

@property (nonatomic , strong) OperateViewModel *operateVM;

@property (nonatomic , strong) UIImageView *iconView;

@property (nonatomic , strong) UILabel *detailLabel;

@property (nonatomic , strong) UIButton *resendBtn;

@end

@implementation ForgotPasswordCtrl

- (void)viewDidLoad
{
    self.title = NSLocalizedString(@"找回密码", nil);
    self.view.backgroundColor = kThemeGrayColor;
    self.operateVM = [OperateViewModel viewModel];
    
    _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - 20, 30, 40, 40)];
    
    _iconView.alpha = 0;
    [self.view addSubview:_iconView];
    
    _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth / 2 - 120, 80, 240, 30)];
    _detailLabel.textAlignment = NSTextAlignmentCenter;
    _detailLabel.alpha = 0;
    _detailLabel.textColor = [UIColor grayColor];
    [self.view addSubview:_detailLabel];
    
    _resendBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 130, kScreenWidth - 30, 35)];
    _resendBtn.backgroundColor = KThemeGreenColor;
    [_resendBtn setTitle:NSLocalizedString(@"重新发送密码到邮箱", nil) forState:UIControlStateNormal];
    [_resendBtn addTarget:self action:@selector(resendEmail) forControlEvents:UIControlEventTouchUpInside];
    _resendBtn.alpha = 0;
    [self.view addSubview:_resendBtn];
    
    _emailTextField.placeholder = NSLocalizedString(@"请输入邮箱", nil);
    [_sendEmailBtn setTitle:NSLocalizedString(@"重新发送密码到邮箱", nil) forState:UIControlStateNormal];
    
}

- (IBAction)forgotPassword:(id)sender {
    if ([_emailTextField.text rangeOfString:@"@"].location == NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil)
                                                        message:NSLocalizedString(@"账号格式不正确", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
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
                blockSelf.sendEmailBtn.alpha = 0;
                blockSelf.inputIcon.alpha = 0;
                blockSelf.iconView.alpha = 1;
                blockSelf.detailLabel.text = userInfo;
                blockSelf.iconView.image = [UIImage imageNamed:@"chenggong"];
                blockSelf.detailLabel.alpha = 1;
                
            }else{
                blockSelf.emailTextField.alpha = 0;
                blockSelf.sendEmailBtn.alpha = 0;
                blockSelf.inputIcon.alpha = 0;
                blockSelf.iconView.alpha = 1;
                blockSelf.detailLabel.text = userInfo;
                blockSelf.iconView.image = [UIImage imageNamed:@"shibai"];
                blockSelf.detailLabel.alpha = 1;
                blockSelf.resendBtn.alpha = 1;
//                [MBProgressHUD showHUDByContent:userInfo view:blockSelf.view afterDelay:2];
            }
        };
    }

}

- (void)resendEmail
{
//    __weak ForgotPasswordCtrl *blockSelf = self;
//    [self.operateVM forgetPasswordWithEmail:_emailTextField.text];
//    
//    self.operateVM.finishHandler = ^(BOOL finished, id userInfo){
//        if (finished) {
//            blockSelf.emailTextField.alpha = 0;
//            blockSelf.sendEmailBtn.alpha = 0;
//            blockSelf.inputIcon.alpha = 0;
//            blockSelf.iconView.alpha = 1;
//            blockSelf.detailLabel.text = userInfo;
//            blockSelf.detailLabel.alpha = 1;
//        }else{
//            blockSelf.emailTextField.alpha = 0;
//            blockSelf.sendEmailBtn.alpha = 0;
//            blockSelf.inputIcon.alpha = 0;
//            blockSelf.iconView.alpha = 1;
//            blockSelf.detailLabel.text = userInfo;
//            blockSelf.detailLabel.alpha = 1;
//            blockSelf.resendBtn.alpha = 1;
//        }
//    };
    _resendBtn.alpha = 0;
    self.emailTextField.alpha = 1;
    self.sendEmailBtn.alpha = 1;
    self.inputIcon.alpha = 1;
    self.iconView.alpha = 0;
    self.detailLabel.alpha = 0;
}


@end
