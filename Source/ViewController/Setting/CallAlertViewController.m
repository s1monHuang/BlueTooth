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
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.text = @"来电提醒";
        _callSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _callSwitch.onTintColor = KThemeGreenColor;
        [_callSwitch setOn:NO];
        [_callSwitch addTarget:self action:@selector(openCallAlert:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = _callSwitch;
        
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
