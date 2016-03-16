//
//  nickNameController.m
//  BlueToothBracelet
//
//  Created by azz on 16/3/16.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "nickNameController.h"

@interface nickNameController ()
@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;

@end

@implementation nickNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!self.nickName) {
        self.nickName(_nickNameTextField.text);
    }
}

- (IBAction)btnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)returnNickName:(nickNameCallBack)nickName
{
    self.nickName = nickName;
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
