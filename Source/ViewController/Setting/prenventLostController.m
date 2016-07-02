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

@property (nonatomic , assign) NSInteger selectedRow;


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
    _selectedRow = [self selectedDistance];
}

- (NSInteger)selectedDistance
{
    NSInteger selectedRow = [[[NSUserDefaults standardUserDefaults] objectForKey:LOSTSELECTEDDISTANCE] integerValue];
    if (!selectedRow) {
        selectedRow = 1;
    }
    return selectedRow;
}


- (BOOL)lostSwtichStatus
{
    BOOL switchStatus = [[[NSUserDefaults standardUserDefaults] objectForKey:LOSTSWTICHSTATUS] boolValue];
    if (!switchStatus) {
        switchStatus = NO;
    }
    return switchStatus;
}

- (void)setUpHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    _tableView.tableHeaderView = headerView;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 80, 44)];
    label.text = @"防丢提醒";
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor lightGrayColor];
    [headerView addSubview:label];
    _lostSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth - 64, 8, 44, 44)];
    _lostSwitch.onTintColor = KThemeGreenColor;
    [_lostSwitch setOn:[self lostSwtichStatus]];
    [_lostSwitch addTarget:self action:@selector(openPreventLost:) forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:_lostSwitch];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, kScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:lineView];
    
    _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 44 * 3)];
    _coverView.backgroundColor = [UIColor lightGrayColor];
    _coverView.alpha = 0.5;
    if (!_lostSwitch.isOn) {
       [_tableView addSubview:_coverView];
    }
    
    
}

- (void)openPreventLost:(id)sender
{
    UISwitch *uiSwitch = (UISwitch *)sender;
        if (uiSwitch.on) {
            [_coverView removeFromSuperview];
            [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:LOSTSWTICHSTATUS];
        } else {
            [_tableView addSubview:_coverView];
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:LOSTSWTICHSTATUS];
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
        if (indexPath.row == _selectedRow) {
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
        case 0:
        {
            [[NSUserDefaults standardUserDefaults] setObject:@(80) forKey:PREVENTLOST];
            [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:LOSTSELECTEDDISTANCE];
        }
            
            break;
        case 1:
        {
            [[NSUserDefaults standardUserDefaults] setObject:@(90) forKey:PREVENTLOST];
            [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:LOSTSELECTEDDISTANCE];
        }
            
            break;
        case 2:
        {
            [[NSUserDefaults standardUserDefaults] setObject:@(100) forKey:PREVENTLOST];
            [[NSUserDefaults standardUserDefaults] setObject:@(2) forKey:LOSTSELECTEDDISTANCE];
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
