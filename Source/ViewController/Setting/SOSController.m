//
//  SOSController.m
//  BlueToothBracelet
//
//  Created by Hsn on 16/6/29.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "SOSController.h"


#define SOSSWITCHSTATUS  @"SOSSWITCHSTATUS"      //求助开关状态
#define SOSSELECTEDINDEX  @"SOSSELECTEDINDEX"    //选择的求助方式

@interface SOSController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic , strong) UITableView *tableView;

@property (nonatomic , strong) UISwitch *SOSSwitch;

@property (nonatomic , strong) NSArray *distanceArray;

@property (nonatomic , strong) UIView *coverView;

@property (nonatomic , strong) UIView *bottomView;

@property (nonatomic , strong) UITextField *numberText;

@end

@implementation SOSController

static NSString *identifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"一键求救";
    self.view.backgroundColor = kThemeGrayColor;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44 * 3)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    [self.view addSubview:_tableView];
    [self setUpBottomView];
    _distanceArray = @[@"是否开启求救",@"请输入电话号码:"];
}

- (void)setUpBottomView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 88 + 64, kScreenWidth, 44)];
    _tableView.tableFooterView = bottomView;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [bottomView addSubview:lineView];
    
    NSArray *titleArray = @[@"电话求救",@"短信求救"];
    UISegmentedControl *SOSChooseSegment = [[UISegmentedControl alloc] initWithItems:titleArray];
    SOSChooseSegment.frame = CGRectMake(kScreenWidth / 2 - 70, 8, 140, 30);
    SOSChooseSegment.tintColor = KThemeGreenColor;
    SOSChooseSegment.selectedSegmentIndex = [self selectedIndex];
    [SOSChooseSegment addTarget:self action:@selector(chooseSOSWay:) forControlEvents:UIControlEventValueChanged];
    [bottomView addSubview:SOSChooseSegment];
    _SOSSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth - 64, 10, 44, 44)];
    _SOSSwitch.onTintColor = KThemeGreenColor;
    [_SOSSwitch setOn:[self sosSwtichStatus]];
    [_SOSSwitch addTarget:self action:@selector(openPreventLost:) forControlEvents:UIControlEventValueChanged];
    [bottomView addSubview:_SOSSwitch];
    _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 44 * 2)];
    _coverView.backgroundColor = [UIColor lightGrayColor];
    _coverView.alpha = 0.5;
    if (!_SOSSwitch.isOn) {
      [_tableView addSubview:_coverView];  
    }
    
    
}

- (NSInteger)selectedIndex
{
    NSUInteger index = [[[NSUserDefaults standardUserDefaults] objectForKey:SOSSELECTEDINDEX] integerValue];
    if (!index) {
        index = 0;
    }
    return index;
}

- (BOOL)sosSwtichStatus
{
    BOOL switchStatus = [[[NSUserDefaults standardUserDefaults] objectForKey:SOSSWITCHSTATUS] boolValue];
    if (!switchStatus) {
        switchStatus = NO;
    }
    return switchStatus;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_SOSSwitch.on) {
        if (_numberText.text.length > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:_numberText.text forKey:SETPHONENO];
            
            [[BluetoothManager share].baby notify:[BluetoothManager share].bindingPeripheral.peripheral characteristic:[BluetoothManager share].sosCharacteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                NSString *phoneNO = [[NSUserDefaults standardUserDefaults] objectForKey:SETPHONENO];
                
                NSData *data = characteristics.value;
                Byte *byte = (Byte *)data.bytes;
                if (byte[1] == 0x99) {
                    if (phoneNO) {
                        if ([BluetoothManager share].isCalling == NO) {
                            [BluetoothManager share].isCalling = YES;
                            if ([BluetoothManager share].isPhone == YES) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNO]]];
                            }else{
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",phoneNO]]];
                            }
                            
                        }
                        
                    }
                }
            }  ];
        }
        
    }else{
        if ([BluetoothManager share].bindingPeripheral) {
            [[BluetoothManager share].baby cancelNotify:[BluetoothManager share].bindingPeripheral.peripheral
                                         characteristic:[BluetoothManager share].sosCharacteristic];
                    }
    }
}

- (void)chooseSOSWay:(id)sender
{
    UISegmentedControl *SOSChooseSegment = (UISegmentedControl *)sender;
    if (SOSChooseSegment.selectedSegmentIndex == 0) {
        [BluetoothManager share].isPhone = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:SOSSELECTEDINDEX];
        
    }else{
        [BluetoothManager share].isPhone = NO;
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:SOSSELECTEDINDEX];
    }
}

- (void)openPreventLost:(id)sender
{
    UISwitch *uiSwitch = (UISwitch *)sender;
    if (uiSwitch.on) {
        [_coverView removeFromSuperview];
        [_numberText becomeFirstResponder];
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:SOSSWITCHSTATUS];
    } else {
        [_tableView addSubview:_coverView];
        [_numberText resignFirstResponder];
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:SOSSWITCHSTATUS];
    }
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.text = _distanceArray[indexPath.row];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        if (indexPath.row == 1) {
            _numberText = [[UITextField alloc] initWithFrame:CGRectMake(145, 0, kScreenWidth - 145, 44)];
            
            [cell.contentView addSubview:_numberText];
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(140, 38, kScreenWidth - 145, 0.5)];
            lineView.backgroundColor = [UIColor lightGrayColor];
            [cell.contentView addSubview:lineView];
            _numberText.userInteractionEnabled = YES;
            cell.accessoryView = nil;
            
        }else{
            cell.accessoryView = _SOSSwitch;
        }
        
    }
    return cell;
}


- (void)dealloc
{
    
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