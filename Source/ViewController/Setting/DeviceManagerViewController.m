//
//  DeviceManagerViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/26.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "DeviceManagerViewController.h"
#import "AddDeviceViewController.h"

@interface DeviceManagerViewController ()<UITableViewDataSource,UITableViewDelegate> {
    BOOL _isBindingPeripheral;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *imageArray;
@end

@implementation DeviceManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title  = @"设备管理";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    
    _isBindingPeripheral = [BluetoothManager share].isBindingPeripheral;
    [self reloadData];
}

- (void)reloadData {
    _titleArray = nil;
    _imageArray = nil;
    if (_isBindingPeripheral) {
        _titleArray = @[@"解除"];
        _imageArray = @[@"remove"];
    } else {
        _titleArray = @[@"添加设备"];
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
    return 180.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
    UIImageView *bracelet = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 77)/2, 15, 77, 150)];
    bracelet.image = [UIImage imageNamed:@"bracelet"];
    [headerview addSubview:bracelet];
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
            if (_isBindingPeripheral) {
                [[BluetoothManager share].baby cancelAllPeripheralsConnection];
                [BluetoothManager share].isBindingPeripheral = NO;
                _isBindingPeripheral = NO;
                [DataStoreHelper clearBindingPeripheral];
                [self reloadData];
                [tableView reloadData];
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
