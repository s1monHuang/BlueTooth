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

@end

@implementation RegisterCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"注册";
    self.view.backgroundColor = kThemeGrayColor;
    
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
        
        self.operateVM.finishHandler = ^(BOOL finished, id userInfo){
            if (finished) {
                [MBProgressHUD showHUDByContent:@"注册成功" view:blockSelf.view afterDelay:2];
            }else{
                
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
