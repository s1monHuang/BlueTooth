//
//  CallAlertViewController.m
//  BlueToothBracelet
//
//  Created by azz on 16/4/7.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "CallAlertViewController.h"

@interface CallAlertViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic , strong) UITableView *tableView;

@property (nonatomic , strong) UISwitch *callSwitch;



@end

@implementation CallAlertViewController

static NSString *identifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"来电提醒";
    self.view.backgroundColor = kThemeGrayColor;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    _tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor whiteColor];
        UISwitch *callSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _callSwitch = callSwitch;
        [callSwitch setOn:NO];
        [callSwitch addTarget:self action:@selector(openCallAlert:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = callSwitch;
        
    }
    return cell;
}

- (void)openCallAlert:(id)sender
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
