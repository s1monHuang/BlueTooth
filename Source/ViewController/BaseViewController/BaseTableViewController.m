//
//  BaseTableViewController.m
//  DGroupDoctor
//
//  Created by zzzz on 15/7/12.
//  Copyright (c) 2015年 Dachen Tech. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    backItem(self.navigationItem.backBarButtonItem);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
