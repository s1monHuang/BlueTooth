//
//  prenventLostController.m
//  BlueToothBracelet
//
//  Created by Hsn on 16/6/29.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "prenventLostController.h"

@interface prenventLostController ()<UITableViewDelegate, UITableViewDataSource>


@property (nonatomic , strong) UITableView *tableView;

@property (nonatomic , strong) UISwitch *lostSwitch;

@property (nonatomic , strong) NSArray *distanceArray;

@property (nonatomic , strong) UIView *coverView;


@end

@implementation prenventLostController

static NSString *identifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"防丢提醒";
    self.view.backgroundColor = kThemeGrayColor;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44 * 4)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    [self setUpHeaderView];
    _distanceArray = @[@"近距离",@"中距离",@"远距离"];
}

- (void)setUpHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    _tableView.tableHeaderView = headerView;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 44)];
    label.text = @"防丢失";
    label.font = [UIFont systemFontOfSize:20];
    label.textColor = [UIColor lightGrayColor];
    [headerView addSubview:label];
    _lostSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth - 64, 10, 44, 44)];
    _lostSwitch.onTintColor = KThemeGreenColor;
    [_lostSwitch setOn:NO];
    [_lostSwitch addTarget:self action:@selector(openPreventLost:) forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:_lostSwitch];
    _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 44 * 3)];
    _coverView.backgroundColor = [UIColor lightGrayColor];
    _coverView.alpha = 0.5;
    [_tableView addSubview:_coverView];
    
}

- (void)openPreventLost:(id)sender
{
    UISwitch *uiSwitch = (UISwitch *)sender;
        if (uiSwitch.on) {
            [_coverView removeFromSuperview];
        } else {
            [_tableView addSubview:_coverView];
        }
    
    [[BluetoothManager share] lostDevice:uiSwitch.on];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.text = _distanceArray[indexPath.row];
        if (indexPath.row == 1) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            
        }else{
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *cells = [tableView visibleCells];
    for (UITableViewCell *cell in cells) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
    }
    UITableViewCell *selectCell = [_tableView cellForRowAtIndexPath:indexPath];
    [selectCell setAccessoryType:UITableViewCellAccessoryCheckmark];
    switch (indexPath.row) {
        case 1:
        {
            [[NSUserDefaults standardUserDefaults] setObject:@(80) forKey:PREVENTLOST];
        }
            
            break;
        case 2:
        {
           [[NSUserDefaults standardUserDefaults] setObject:@(90) forKey:PREVENTLOST];
        }
            
            break;
        case 3:
        {
            [[NSUserDefaults standardUserDefaults] setObject:@(100) forKey:PREVENTLOST];
        }
            
            break;
            
        default:
            break;
    }
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
