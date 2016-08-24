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

@property (nonatomic , assign) BOOL callAlertIsOpen;

@property (nonatomic , strong) NSArray *remindWayArray;

@property (nonatomic , strong) NSArray *remindSwitchArray;

@property (nonatomic , assign) NSInteger openCount;

@property (nonatomic , strong) NSString *openStr;


@end

@implementation CallAlertViewController

static NSString *identifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = BTLocalizedString(@"来电提醒");
    self.view.backgroundColor = kThemeGrayColor;
    _openCount = [[[NSUserDefaults standardUserDefaults] objectForKey:callAlertOpen] integerValue];
    _openStr = [self toBinarySystemWithDecimalSystem:_openCount];
    
    _remindWayArray = @[BTLocalizedString(@"短信提醒"),BTLocalizedString(@"微信提醒"),BTLocalizedString(@"QQ提醒"),BTLocalizedString(@"电话提醒")];
    [self setUpRemindSwitchArray];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44 * 4)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
}

- (void)setUpRemindSwitchArray
{
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSInteger i = 0; i < 4; i++) {
        UISwitch *remindSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        remindSwitch.tag = 100 + i;
        [remindSwitch setOn:[self switchIsOpen:i]];
        [remindSwitch addTarget:self action:@selector(openCallAlert:) forControlEvents:UIControlEventValueChanged];
        [tempArray addObject:remindSwitch];
    }
    _remindSwitchArray = [NSArray arrayWithArray:tempArray];
}

- (BOOL)switchIsOpen:(NSInteger)row
{
    if (_openCount <= 0) {
        return NO;
    }else{
        BOOL isOpen = [[_openStr substringWithRange:NSMakeRange(3-row, 1)] boolValue];
        return isOpen;
    }
}

//  十进制转二进制
- (NSString *)toBinarySystemWithDecimalSystem:(NSInteger )num
{
    
    NSInteger remainder = 0;      //余数
    NSInteger divisor = 0;        //除数
    
    NSString * prepare = @"";
    
    while (true)
    {
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%ld",remainder];
        
        if (divisor == 0)
        {
            break;
        }
    }
    NSString * result = @"";
    for (NSInteger i = prepare.length - 1; i >= 0; i --)
    {
        result = [result stringByAppendingFormat:@"%@",
                  [prepare substringWithRange:NSMakeRange(i , 1)]];
    }
    switch (result.length) {
        case 0:
        {
            result = @"0000";
        }
            break;
        case 1:
        {
            result = [NSString stringWithFormat:@"000%@",result];
        }
            break;
        case 2:
        {
            result = [NSString stringWithFormat:@"00%@",result];
        }
            break;
        case 3:
        {
            result = [NSString stringWithFormat:@"0%@",result];
        }
            break;
        default:
            break;
    }
    return result;
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.textLabel.text = _remindWayArray[indexPath.row];
    cell.accessoryView = _remindSwitchArray[indexPath.row];
    return cell;
}

- (void)openCallAlert:(id)sender
{
    UISwitch *uiSwitch = (UISwitch *)sender;
    NSInteger switchTag = uiSwitch.tag - 100;
    
    switch (switchTag) {
        case 0:{
            if (uiSwitch.on) {
                DLog(@"短信提醒开");
                _openCount += 1;
            } else {
                DLog(@"短信提醒关");
                _openCount -= 1;
            }
        }
            break;
        case 1:{
            if (uiSwitch.on) {
                DLog(@"微信提醒开");
                _openCount += 2;
            } else {
                DLog(@"微信提醒关");
                _openCount -= 2;
            }
        }
            break;
        case 2:{
            if (uiSwitch.on) {
                DLog(@"QQ提醒开");
                _openCount += 4;
            } else {
                DLog(@"QQ提醒关");
                _openCount -= 4;
            }
        }
            break;
            
        case 3:{
            if (uiSwitch.on) {
                DLog(@"电话提醒开");
                _openCount += 8;
            } else {
                DLog(@"电话提醒关");
                _openCount -= 8;
            }
        }
            break;
            
            
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(_openCount) forKey:callAlertOpen];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[BluetoothManager share] openCallAlert];
    [MBProgressHUD showHUDAddedTo:UI_Window animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:UI_Window animated:YES];
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
