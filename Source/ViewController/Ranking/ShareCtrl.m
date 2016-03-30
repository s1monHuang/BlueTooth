//
//  ShareCtrl.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/9.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "ShareCtrl.h"

@interface ShareCtrl ()

@end

@implementation ShareCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kThemeGrayColor;
//    UIImageView *sharebg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 214)];
//    sharebg.image = [UIImage imageNamed:@"share-bg"];
//    [self.view addSubview:sharebg];
//    
//    UIImageView *headerbg = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 100)/2, 50, 100, 100)];
//    headerbg.image = [UIImage imageNamed:@"portrait"];
//    [self.view addSubview:headerbg];
//    
//    UIImageView *rankbg = [[UIImageView alloc] initWithFrame:CGRectMake(26, 60, 60, 75)];
//    rankbg.image = [UIImage imageNamed:@"flag"];
//    [self.view addSubview:rankbg];
//    
//    UIImageView *flagbg = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 172)/2, 157, 172, 37)];
//    flagbg.image = [UIImage imageNamed:@"flag2"];
//    [self.view addSubview:flagbg];
//    
    UIButton *btnClosed = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 21 - 15, 20+10, 21, 21)];
    [btnClosed addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnClosed setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.view addSubview:btnClosed];
    
}

- (void)rightBarButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
