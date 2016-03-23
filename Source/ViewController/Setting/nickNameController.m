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


- (IBAction)btnClick:(id)sender {
    
    NSString *nickName = _nickNameTextField.text;
    CurrentUser.nickName = nickName;
//    [[NSNotificationCenter defaultCenter] postNotificationName:nickNameNotification object:nickName];
    
    [self.navigationController popViewControllerAnimated:YES];
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
