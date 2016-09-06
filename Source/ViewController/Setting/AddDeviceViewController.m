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

@interface AddDeviceViewController ()<UITableViewDelegate,UITableViewDataSource,BluetoothManagerDelegate,UIGestureRecognizerDelegate> {
//    OperateViewModel *_operateViewModel;
    MBProgressHUD *_hud;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *peripherals;
@property (strong, nonatomic) NSMutableArray *peripheralModels;

@property (strong, nonatomic)PeripheralModel *selecedPeripheral;

@property (strong, nonatomic) NSTimer *timer;

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
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  30,
                                                                  44)];
    [button setTitle:nil forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_btn_back_nor"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_btn_back_pre"] forState:UIControlStateHighlighted];
    [button addTarget:self
               action:@selector(PushToVC)
     forControlEvents:UIControlEventTouchUpInside];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    button.accessibilityLabel = BTLocalizedString(@"返回");
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
//    _operateViewModel = [[OperateViewModel alloc] init];
//    
//    __weak AddDeviceViewController *weakSelf = self;
//    
//    [_operateViewModel setFinishHandler:^(BOOL finished, id userInfo) {
//        if (finished) {
//            [[BluetoothManager share] stop];
//            [BluetoothManager share].deviceID = userInfo;
//            [[NSUserDefaults standardUserDefaults] setObject:[BluetoothManager share].deviceID forKey:@"userDeviceID"];
//            [[BluetoothManager share] connectingBlueTooth:weakSelf.selecedPeripheral.peripheral];
//            
//        }else{
//            
//        }
//    }];
    
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
        NSRange range = [model.name rangeOfString:@"BCD"];
        if (range.location == NSNotFound) {
            return;
        } 
        [_peripherals addObject:peripheral];
        [_peripheralModels addObject:model];
        [_tableView reloadData];
    }
}


//绑定蓝牙设备成功或失败
- (void)didBindingPeripheral:(BOOL)success {
    
    [_timer invalidate];
    _timer = nil;
    
    if (!success) {
        [self disConnectPeripheral];
    } else {
        _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
    }
}

//绑定蓝牙设备成功并且获取历史运动数据成功
- (void)didBindingPeripheralFinished {
    [BluetoothManager share].bindingPeripheral = _selecedPeripheral;
    [self.navigationController popToRootViewControllerAnimated:YES];
    [_hud setHidden:YES];
    _hud = nil;
    [_timer invalidate];
    _timer = nil;
    [MBProgressHUD showHUDByContent:BTLocalizedString(@"绑定成功") view:UI_Window afterDelay:1.5];
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
    [[BluetoothManager share] stop];
    [[BluetoothManager share] connectingBlueTooth:_selecedPeripheral.peripheral];

    _hud = [MBProgressHUD showHUDAddedTo:UI_Window animated:YES];
    _hud.labelText = [NSString stringWithFormat:@"%@",BTLocalizedString(@"正在绑定...")] ;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
    
}

- (void)timeOut {
    [_timer invalidate];
    _timer = nil;
    [self disConnectPeripheral];
}

- (void)disConnectPeripheral {
    [[[BluetoothManager share] baby] cancelAllPeripheralsConnection];
    [_hud setHidden:YES];
    _hud = nil;
    [MBProgressHUD showHUDByContent:BTLocalizedString(@"绑定失败") view:UI_Window afterDelay:1.5];
    
    [_peripherals removeAllObjects];
    [_peripheralModels removeAllObjects];
    [_tableView reloadData];
    
    [[BluetoothManager share] stop];
    [[BluetoothManager share] start];
}

- (void)PushToVC
{
    [self.navigationController popViewControllerAnimated:YES];
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
