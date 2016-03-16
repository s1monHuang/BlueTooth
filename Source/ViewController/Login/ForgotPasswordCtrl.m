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


@end

@implementation ForgotPasswordCtrl

- (void)viewDidLoad
{
    self.title = @"找回密码";
    self.view.backgroundColor = kThemeGrayColor;
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
                [MBProgressHUD showHUDByContent:userInfo view:blockSelf.view afterDelay:2];
            }else{
                
            }
        };
    }

}

@end
