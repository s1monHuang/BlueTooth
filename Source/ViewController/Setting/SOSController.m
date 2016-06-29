//
//  SOSController.m
//  BlueToothBracelet
//
//  Created by Hsn on 16/6/29.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "SOSController.h"

@interface SOSController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic , strong) UITableView *tableView;

@property (nonatomic , strong) UISwitch *lostSwitch;

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
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44 * 2)];
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
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 44)];
    label.text = @"电话求救";
    label.font = [UIFont systemFontOfSize:20];
    label.textColor = [UIColor lightGrayColor];
    [bottomView addSubview:label];
    _lostSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth - 64, 10, 44, 44)];
    _lostSwitch.onTintColor = KThemeGreenColor;
    [_lostSwitch setOn:NO];
    [_lostSwitch addTarget:self action:@selector(openPreventLost:) forControlEvents:UIControlEventValueChanged];
    [bottomView addSubview:_lostSwitch];
    _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 44 * 2)];
    _coverView.backgroundColor = [UIColor lightGrayColor];
    _coverView.alpha = 0.5;
    [_tableView addSubview:_coverView];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_lostSwitch.on) {
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
                      
                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNO]]];
                  }
                  
              }
            }
          }  ];
        }
            
        }else{
            
            [[BluetoothManager share].baby cancelNotify:[BluetoothManager share].bindingPeripheral.peripheral
                                         characteristic:[BluetoothManager share].sosCharacteristic];
        }
}

- (void)openPreventLost:(id)sender
{
    UISwitch *uiSwitch = (UISwitch *)sender;
    if (uiSwitch.on) {
        [_coverView removeFromSuperview];
    } else {
        [_tableView addSubview:_coverView];
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
        if (indexPath.row == 1) {
            _numberText = [[UITextField alloc] initWithFrame:CGRectMake(120, 10, kScreenWidth - 120, 44)];
            [cell.contentView addSubview:_numberText];
            _numberText.userInteractionEnabled = YES;
            cell.accessoryView = nil;
            
        }else{
            cell.accessoryView = _lostSwitch;
        }
        
    }
    return cell;
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
