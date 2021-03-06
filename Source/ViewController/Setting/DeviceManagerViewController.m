//
//  DeviceManagerViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/26.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "DeviceManagerViewController.h"
#import "AddDeviceViewController.h"

@interface DeviceManagerViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *imageArray;

@property (nonatomic , strong) UILabel *deviceIDLabel;

@end

@implementation DeviceManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title  = [NSString stringWithFormat:@"%@",BTLocalizedString(@"设备管理")];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    [self reloadData];
}

- (void)reloadData {
    _titleArray = nil;
    _imageArray = nil;
    if ([BluetoothManager share].isBindingPeripheral) {
        _titleArray = @[BTLocalizedString(@"解除设备")];
        _imageArray = @[@"remove"];
    } else {
        _titleArray = @[BTLocalizedString(@"添加设备")];
        _imageArray = @[@"add"];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 220.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 220)];
    UIImageView *bracelet = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 77)/2, 15, 77, 150)];
    bracelet.image = [UIImage imageNamed:@"bracelet"];
    [headerview addSubview:bracelet];
    
//    if ([BluetoothManager share].isBindingPeripheral){
//    _deviceIDLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth - 77)/2 - 10, 180, ScreenWidth - 50, 40)];
//        NSString *deviceId = [[NSUserDefaults standardUserDefaults] objectForKey:User_DeviceID];
//    _deviceIDLabel.text = [NSString stringWithFormat:@"%@:%@",BTLocalizedString(@"设备编号"),deviceId];
//    _deviceIDLabel.alpha = 0;
//    [headerview addSubview:_deviceIDLabel];
//    }
    return headerview;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //定义标记，用于标记单元格
    static NSString* identifier =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//cell的右边有一个小箭头，距离右边有十几像素；
    }
    
    for (UIView *subview in cell.contentView.subviews)
    {
        [subview removeFromSuperview];
    }
    
    cell.textLabel.text = self.titleArray[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            if ([BluetoothManager share].isBindingPeripheral) {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:BTLocalizedString(@"是否解除设备") message:nil delegate:self cancelButtonTitle:BTLocalizedString(@"取消") otherButtonTitles:BTLocalizedString(@"确定"), nil];
                [alert show];
               
                
            } else {
                AddDeviceViewController *VC = [[AddDeviceViewController alloc] init];
                [self.navigationController pushViewController:VC animated:YES];
            }
        }
            break;
        default:
            break;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[BluetoothManager share] stop];
        [[BluetoothManager share].baby cancelAllPeripheralsConnection];
        [BluetoothManager share].isBindingPeripheral = NO;
        [BluetoothManager clearBindingPeripheral];
        [BluetoothManager share].isReadedPripheralAllData = NO;
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:didConnectDevice];
        [self reloadData];
        [self.tableView reloadData];
        //解除绑定通知
        [[NSNotificationCenter defaultCenter] postNotificationName:REMOVE_DEVICE object:nil];
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
