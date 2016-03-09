//
//  AddDeviceViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/26.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "AddDeviceViewController.h"
#import "BabyBluetooth.h"
#import "PeripheralModel.h"
#import "BluetoothManager.h"

@interface AddDeviceViewController ()<UITableViewDelegate,UITableViewDataSource,BluetoothManagerDelegate> {
    PeripheralModel *_selecedPeripheral;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *peripherals;
@end

@implementation AddDeviceViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [BluetoothManager share].deleagete = self;
    [[BluetoothManager share] start];
    
    _peripherals = [[NSMutableArray alloc] init];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setTableFooterView:[UIView new]];
}



- (void)didSearchPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData {
    if (![_peripherals containsObject:peripheral]) {
        PeripheralModel *model = [[PeripheralModel alloc] initWithPeripheral:peripheral
                                                           advertisementData:advertisementData];
        [_peripherals addObject:model];
        [_tableView reloadData];
    }
}

- (void)didBindingPeripheral:(BOOL)success {
    if (success) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount = [_peripherals count];
    return rowCount;
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
    }
    
    cell.imageView.image = [UIImage imageNamed:@"add_bracelet"];
    PeripheralModel *model = _peripherals[indexPath.row];
    cell.textLabel.text = model.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PeripheralModel *model = _peripherals[indexPath.row];
    [BluetoothManager share].selecedPeripheral = model;
    [[BluetoothManager share] connectingBlueTooth:model.peripheral];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [BluetoothManager share].deleagete = nil;
}

@end
