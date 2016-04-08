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
#import "OperateViewModel.h"

@interface AddDeviceViewController ()<UITableViewDelegate,UITableViewDataSource,BluetoothManagerDelegate> {
    OperateViewModel *_operateViewModel;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic) NSMutableArray *peripheralModels;

@property (strong, nonatomic)PeripheralModel *selecedPeripheral;
@end

@implementation AddDeviceViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disConnectPeripheral)
                                                 name:DISCONNECT_PERIPHERAL
                                               object:nil];
    
    [BluetoothManager share].deleagete = self;
    [[[BluetoothManager share] baby] cancelAllPeripheralsConnection];
    [[BluetoothManager share] stop];
    [[BluetoothManager share] start];
    [BluetoothManager share].isReadedPripheralAllData = NO;
    [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:BlueToothIsReadedPripheralAllData];
    
    _operateViewModel = [[OperateViewModel alloc] init];
    
    __weak AddDeviceViewController *weakSelf = self;
    
    [_operateViewModel setFinishHandler:^(BOOL finished, id userInfo) {
        [[BluetoothManager share] stop];
        [BluetoothManager share].deviceID = userInfo;
        [[BluetoothManager share] connectingBlueTooth:weakSelf.selecedPeripheral.peripheral];
    }];
    
    _peripherals = [[NSMutableArray alloc] init];
    _peripheralModels = [[NSMutableArray alloc] init];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setTableFooterView:[UIView new]];
}



- (void)didSearchPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData {
    if (![_peripherals containsObject:peripheral]) {
        PeripheralModel *model = [[PeripheralModel alloc] initWithPeripheral:peripheral
                                                           advertisementData:advertisementData];
        [_peripherals addObject:peripheral];
        [_peripheralModels addObject:model];
        [_tableView reloadData];
    }
}

- (void)didBindingPeripheral:(BOOL)success {
    if (success) {
        [BluetoothManager share].bindingPeripheral = _selecedPeripheral;
        [self.navigationController popToRootViewControllerAnimated:YES];
        [MBProgressHUD hideHUDForView:UI_Window animated:YES];
    } else {
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount = [_peripheralModels count];
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
    PeripheralModel *model = _peripheralModels[indexPath.row];
    cell.textLabel.text = model.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PeripheralModel *model = _peripheralModels[indexPath.row];
    _selecedPeripheral = model;
    [BluetoothManager share].bindingPeripheral = model;
    [_operateViewModel createExdeviceId];
    [MBProgressHUD showHUDAddedTo:UI_Window animated:YES];
}

- (void)disConnectPeripheral {
    [MBProgressHUD hideHUDForView:UI_Window animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [BluetoothManager share].deleagete = nil;
}

@end
