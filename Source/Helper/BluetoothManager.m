//
//  BluetoothManager.m
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/9.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "BluetoothManager.h"
#import "SportDataModel.h"
#import "HistorySportDataModel.h"
#import "BasicInfomationModel.h"
#import "OperateViewModel.h"
#import "prenventLostController.h"
#import "SOSController.h"

#define ServiceUUID   @"FFF0"
#define specifiedUUID @"FFF1"
#define sosUUID       @"FFF2"

static BluetoothManager *manager = nil;

@interface BluetoothManager ()

@property (nonatomic, strong) MBProgressHUD *hud;               //获取历史数据需要显示的loading框

@property (nonatomic, strong) OperateViewModel *operateViewModel;

@end


@implementation BluetoothManager


+ (BluetoothManager *)share {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BluetoothManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _isBindingPeripheral = [[NSUserDefaults standardUserDefaults] boolForKey:@"isbindingPeripheral"];
        _isReadedPripheralAllData = NO;
        //初始化BabyBluetooth 蓝牙库
        _baby = [BabyBluetooth shareBabyBluetooth];
        //设置蓝牙委托
        [self babyDelegate];
        
        
        [_baby cancelAllPeripheralsConnection];
        if (_isBindingPeripheral) {
            //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
            _baby.scanForPeripherals().begin();
        }
        _deviceID = [[NSUserDefaults standardUserDefaults] objectForKey:User_DeviceID];
        _connectionType = BluetoothConnectingNormal;
        _successType = BluetoothConnectingNormalSuccess;
        _isConnectSuccess = NO;
        
        _bluetoothQueue = [[NSMutableArray alloc] init];
        
        _operateViewModel = [[OperateViewModel alloc] init];
        
    }
    return self;
}

#pragma mark -蓝牙配置和操作

- (void)start {
    _baby.scanForPeripherals().begin();
}

- (void)stop {
    [_baby cancelScan];
}

-(void)connectingBlueTooth:(CBPeripheral *)peripheral {
    _baby.having(peripheral).and.then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}

//蓝牙网关初始化和委托方法设置
-(void)babyDelegate{
    
    __weak typeof(self) weakSelf = self;
    
    //监测蓝牙是否打开
    [_baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            //            [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
        }
    }];
    
    //设置扫描到设备的委托
    [_baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@  uuid:%@",peripheral.name,peripheral.identifier.UUIDString);
        NSString *peripheralUUID = peripheral.identifier.UUIDString;
        //如果搜索到的设备是已经绑定的设备,直接连接该设备
        if ([[BluetoothManager getBindingPeripheralUUID] isEqualToString:peripheralUUID] &&
            peripheral.state == CBPeripheralStateDisconnected) {
            [weakSelf connectingBlueTooth:peripheral];
            [weakSelf.baby cancelScan];
            weakSelf.bindingPeripheral = [[PeripheralModel alloc] initWithPeripheral:peripheral
                                                                   advertisementData:advertisementData];
            NSLog(@"自动连接已绑定设备:%@",peripheral.name);
            return ;
        }
        if (weakSelf.deleagete && [weakSelf.deleagete respondsToSelector:@selector(didSearchPeripheral:advertisementData:)]) {
            [weakSelf.deleagete didSearchPeripheral:peripheral advertisementData:advertisementData];
        }
    }];
    
    //设置发现设备的Services的委
    [_baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {

    }];
    
    //设置读取characteristics的委托
    [_baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        //如果是第一次绑定设备,读取蓝牙设备中的相关信息 
        if (!weakSelf.isReadedPripheralAllData) {
            [weakSelf firstReadPripheralData:weakSelf
                              characteristic:characteristics];
        }
        
        else {
            [weakSelf handleCharacteristic:characteristics
                                  weakSelf:weakSelf];
        }
    }];
    
    //设置写数据成功的block
    [_baby setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        if ([characteristic.UUID.UUIDString isEqualToString:specifiedUUID]) {
            if (weakSelf.isReadedPripheralAllData) {
                DLog(@"写入数据成功    connectionType = %@    characteristic = %@",@(weakSelf.connectionType),characteristic.value);
            }
            switch (weakSelf.connectionType) {
                    //绑定请求发送成功
                case BluetoothConnectingBinding: {
                    weakSelf.successType = BluetoothConnectingBindingSuccess;
                }
                    break;
                    //成功绑定蓝牙设备
                case BluetoothConnectingConfirmBinding: {
                    weakSelf.successType = BluetoothConnectingConfirmBindingSuccess;
                    weakSelf.isConnectSuccess = YES;
                    NSString *deviceID = [weakSelf deviceIDWithData:characteristic.value];
                    if (deviceID) {
                        [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:User_DeviceID];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
                    break;
                    //成功设置基本信息
                case BluetoothConnectingSetBasicInfomation: {
                    weakSelf.successType = BluetoothConnectingSetBasicInfomationSuccess;
                }
                    break;
                case BluetoothConnectingSetTimestamp: {
                    weakSelf.successType = BluetoothConnectingSetTimestampSuccess;
                }
                    break;
                    //成功读取蓝牙设备中的运动数据,
                case BluetoothConnectingReadSportData: {
                    weakSelf.successType = BluetoothConnectingReadSportDataSuccess;
                }
                    break;
                    //成功读取72小时蓝牙设备中的运动数据(每次获取一小时的,获取72次)
                case BluetoothConnectingHistroyReadSportData: {
                    weakSelf.successType = BluetoothConnectingHistroyReadSportDataSuccess;
                }
                    break;
                    //成功读取心率
                case BluetoothConnectingHeartRate: {
                    weakSelf.successType = BluetoothConnectingHeartRateSuccess;
                }
                    break;
                    //成功打开(关闭)来电提醒
                case BluetoothConnectingCallAlert: {
//                    [[NSUserDefaults standardUserDefaults] setObject:@([BluetoothManager share].isOpenCallAlert)
//                                                              forKey:callAlertOpen];
                    weakSelf.successType = BluetoothConnectingCallAlertSuccess;
                }
                    break;
                case BluetoothConnectingLostDevice: {
                    weakSelf.successType = BluetoothConnectingLostDeviceSuccess;
                }
                    break;
                default:
                    break;
            }
            [weakSelf.timer invalidate];
            [weakSelf.bindingPeripheral.peripheral readValueForCharacteristic:characteristic];
        }
    }];
    
    //设置查找设备的过滤器
    [_baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName) {
        //设置查找规则是名称大于1 ， the search rule is peripheral.name length > 2
        if (peripheralName.length >2) {
            return YES;
        }
        return NO;
    }];
    
    
    [_baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelAllPeripheralsConnectionBlock");
    }];
    
    [_baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"setBlockOnCancelScanBlock");
    }];
    
    //设置设备连接成功的委托
    [_baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        NSLog(@"设备：%@--连接成功",peripheral.name);
        BOOL lostRemind = [[[NSUserDefaults standardUserDefaults] objectForKey:LOSTSWTICHSTATUS] boolValue];
        if (lostRemind) {
            _rssiTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                          target:self.bindingPeripheral.peripheral
                                                        selector:@selector(readRSSI)
                                                        userInfo:nil
                                                         repeats:YES];
        }
        if (weakSelf.deleagete && [weakSelf.deleagete respondsToSelector:@selector(didBindingPeripheral:)]) {
            [weakSelf.deleagete didBindingPeripheral:YES];
        }
    }];
    
    //设置设备连接失败的委托
    [_baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        if (weakSelf.deleagete && [weakSelf.deleagete respondsToSelector:@selector(didBindingPeripheral:)]) {
            [weakSelf.deleagete didBindingPeripheral:NO];
        }
    }];
    
    //设置设备断开连接的委托
    [_baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        
        weakSelf.connectionType = BluetoothConnectingNormal;
        weakSelf.successType = BluetoothConnectingNormalSuccess;
        weakSelf.characteristics = nil;
        weakSelf.sosCharacteristic = nil;
        weakSelf.isConnectSuccess = NO;
        [weakSelf removeAllQueue];
        
        if (weakSelf.isBindingPeripheral && !weakSelf.deleagete) {
            if (weakSelf.bindingPeripheral.peripheral && weakSelf.characteristics) {
                [weakSelf.baby cancelNotify:weakSelf.bindingPeripheral.peripheral
                             characteristic:weakSelf.characteristics];
            }
            if (weakSelf.bindingPeripheral.peripheral && weakSelf.sosCharacteristic) {
                [weakSelf.baby cancelNotify:weakSelf.bindingPeripheral.peripheral
                             characteristic:weakSelf.sosCharacteristic];
            }
            [weakSelf connectingBlueTooth:peripheral];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:DISCONNECT_PERIPHERAL
                                                            object:nil];
    }];
    
    [_baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        if ([service.UUID.UUIDString isEqualToString:ServiceUUID]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID.UUIDString isEqualToString:specifiedUUID]) {
                    if (!weakSelf.characteristics) {
                        weakSelf.characteristics = characteristic;
                    }
                }
                else if ([characteristic.UUID.UUIDString isEqualToString:sosUUID]) {
                    NSLog(@"characteristics.UUID.UUIDString isEqualToString:sosUUID");
                    if (!weakSelf.sosCharacteristic) {
                        NSLog(@"characteristics.UUID.UUIDString isEqualToString:sosUUID1");
                        weakSelf.sosCharacteristic = characteristic;
                        [weakSelf.baby notify:weakSelf.bindingPeripheral.peripheral characteristic:characteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                            NSData *data = characteristics.value;
                            if (data.length) {
                                NSLog(@"characteristics.UUID.UUIDString isEqualToString:sosUUID2");
                                Byte *byte = (Byte *)data.bytes;
                                if (byte[1] == 0x99 && byte[19] == 0x43) {
                                    NSLog(@"characteristics.UUID.UUIDString isEqualToString:sosUUID3");
                                    NSString *phoneNO = [[NSUserDefaults standardUserDefaults] objectForKey:SETPHONENO];
                                    BOOL openSOSFunc = [[[NSUserDefaults standardUserDefaults] objectForKey:SOSSWITCHSTATUS] boolValue];
                                    BOOL wayForSOSFunc = [[[NSUserDefaults standardUserDefaults] objectForKey:SOSSELECTEDINDEX] boolValue];
                                    
                                    if (phoneNO) {
                                        if (openSOSFunc) {
                                            NSLog(@"characteristics.UUID.UUIDString isEqualToString:sosUUID4");
                                            if ([BluetoothManager share].isCalling == NO) {
                                                NSLog(@"characteristics.UUID.UUIDString isEqualToString:sosUUID5");
                                                [BluetoothManager share].isCalling = YES;
                                                if (!wayForSOSFunc) {
                                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNO]]];
                                                }else{
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"SOSSendMessage" object:nil];
                                                    });
                                                }
                                                
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }];
                    }
                }

            }
        }
    }];
    
    //防设备丢失测试信号强度
    [_baby setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        
        NSInteger defaultRSSI = -([[[NSUserDefaults standardUserDefaults] objectForKey:PREVENTLOST] integerValue]);
        if (!defaultRSSI) {
            defaultRSSI = -90;
        }
        if (RSSI.integerValue < defaultRSSI) {
            [weakSelf alertUserLostDevice];
        }
        DLog(@"RSSI : %@ ",RSSI.stringValue);
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    
    [_baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions
                              connectPeripheralWithOptions:connectOptions
                            scanForPeripheralsWithServices:nil
                                      discoverWithServices:nil
                               discoverWithCharacteristics:nil];
}

#pragma mark - 第一次连接设备,获取蓝牙设备中的信息

- (void)firstReadPripheralData:(BluetoothManager *)weakSelf characteristic:(CBCharacteristic *)characteristics {
    if ([characteristics.UUID.UUIDString isEqualToString:specifiedUUID] ) {
        if (!weakSelf.characteristics) {
            weakSelf.characteristics = characteristics;
        }
        switch (weakSelf.successType) {
                //绑定请求发送后,要再次确认绑定蓝牙设备
            case BluetoothConnectingBindingSuccess: {
                //如果存在设备ID,不需要发送确认绑定
                if ([weakSelf isExistDeviceID:characteristics]) {
                    NSString *deviceID = [weakSelf deviceIDWithData:characteristics.value];
                    if (deviceID) {
                        [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:User_DeviceID];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
//                    BasicInfomationModel *model = [DBManager selectBasicInfomation];
//                    [weakSelf setBasicInfomation:model];
                    [weakSelf setTimestamp];
                    NSLog(@"蓝牙设备中有设备ID,开始设置基本信息 name:%@ value is:%@",characteristics.UUID,characteristics.value);
                } else {
                    [weakSelf confirmBindingPeripheralWithValue:characteristics.value];
                    NSLog(@"确认绑定蓝牙设备 name:%@ value is:%@",characteristics.UUID,characteristics.value);
                }
            }
                break;
                //成功绑定蓝牙设备后,设置基本信息
            case BluetoothConnectingConfirmBindingSuccess: {
                [weakSelf setTimestamp];
                NSLog(@"成功设置基本信息后,设置时间戳 name:%@ value is:%@",characteristics.UUID,characteristics.value);
            }
                break;
                //成功设置基本信息后,设置时间戳
                case BluetoothConnectingSetTimestampSuccess: {
                BasicInfomationModel *model = [DBManager selectBasicInfomation];
                [weakSelf setBasicInfomation:model];
                NSLog(@"绑定蓝牙设备成功,开始设置基本信息 name:%@ value is:%@",characteristics.UUID,characteristics.value);
            }
                break;
                //设置时间戳后,读取运动数据
                    case BluetoothConnectingSetBasicInfomationSuccess: {
//            case BluetoothConnectingSetTimestampSuccess: {
                [weakSelf readSportData];
                NSLog(@"绑定蓝牙设备成功,开始获取运动数据 name:%@ value is:%@",characteristics.UUID,characteristics.value);
            }
                break;
                //成功读取蓝牙设备中的运动数据后,读取72小时蓝牙设备中的运动数据
            case BluetoothConnectingReadSportDataSuccess: {
                NSLog(@"获取蓝牙设备中的运动数据成功 name:%@ value is:%@",characteristics.UUID,characteristics.value);
                //如果没有绑定设备,获取历史运动数据
                if (![BluetoothManager getBindingPeripheralUUID]) {
                    [weakSelf saveNewSportData:characteristics.value];
                    [weakSelf readHistroySportDataWithValue:characteristics.value];
                } else {
                    Byte *byte = (Byte *)characteristics.value.bytes;
                    if ((byte[0] == 0xAA && byte[18] == 0x04)) {
                        SportDataModel *model = [weakSelf sportDataModelWithData:characteristics.value];
                        DLog(@"步数 = %ld   距离 = %ld  卡路里 = %ld  目标 = %ld  电量 = %ld",model.step,model.distance,model.calorie,model.target,model.battery);
                        
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:FIRST_READ_SPORTDATA_SUCCESS
                                                                        object:nil];
                    self.successType = BluetoothConnectingAllSuccess;
                    self.isReadedPripheralAllData = YES;
                    self.connectionType = BluetoothConnectingSuccess;
                }
            }
                break;
                //成功读取蓝牙设备中的72小时内的运动数据后(每次获取一小时的,获取72次),
                //如果还没获取完72小时数据,继续获取下一个小时的数据
                //如果获取完,
            case BluetoothConnectingHistroyReadSportDataSuccess: {
                NSLog(@"获取蓝牙设备中3天的运动数据成功 name:%@ value is:%@",characteristics.UUID,characteristics.value);
            }
                break;
            default: {
                [weakSelf startBindingPeripheral];
                DLog(@"开始绑定蓝牙设备 name:%@ value is:%@",characteristics.UUID,characteristics.value);
            }
                break;
        }
    }
    //拨打紧急电话
//    else if ([characteristics.UUID.UUIDString isEqualToString:sosUUID]) {
//        NSLog(@"characteristics.UUID.UUIDString isEqualToString:sosUUID");
//        if (!weakSelf.sosCharacteristic) {
//            NSLog(@"characteristics.UUID.UUIDString isEqualToString:sosUUID1");
//            weakSelf.sosCharacteristic = characteristics;
//            [weakSelf.baby notify:weakSelf.bindingPeripheral.peripheral characteristic:characteristics block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
//                NSData *data = characteristics.value;
//                if (data.length) {
//                    NSLog(@"characteristics.UUID.UUIDString isEqualToString:sosUUID2");
//                    Byte *byte = (Byte *)data.bytes;
//                    if (byte[1] == 0x99) {
//                        NSLog(@"characteristics.UUID.UUIDString isEqualToString:sosUUID3");
//                        NSString *phoneNO = [[NSUserDefaults standardUserDefaults] objectForKey:SETPHONENO];
//                        BOOL openSOSFunc = [[[NSUserDefaults standardUserDefaults] objectForKey:SOSSWITCHSTATUS] boolValue];
//                        BOOL wayForSOSFunc = [[[NSUserDefaults standardUserDefaults] objectForKey:SOSSELECTEDINDEX] boolValue];
//
//                        if (phoneNO) {
//                            if (openSOSFunc) {
//                                NSLog(@"characteristics.UUID.UUIDString isEqualToString:sosUUID4");
//                            if ([BluetoothManager share].isCalling == NO) {
//                                NSLog(@"characteristics.UUID.UUIDString isEqualToString:sosUUID5");
//                                [BluetoothManager share].isCalling = YES;
//                                if (!wayForSOSFunc) {
//                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNO]]];
//                                }else{
//                                    dispatch_async(dispatch_get_main_queue(), ^{
//                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"SOSSendMessage" object:nil];
//                                    });
//                                }
//                                
//                            }
//                            }
//                        }
//                        
//                    }
//                }
//            }];
//        }
//    }
}


- (void)handleCharacteristic:(CBCharacteristic *)characteristic weakSelf:(BluetoothManager *)weakSelf{
    if ([characteristic.UUID.UUIDString isEqualToString:specifiedUUID] ) {
        if (!weakSelf.characteristics) {
            weakSelf.characteristics = characteristic;
        }
        switch (weakSelf.successType) {
            case BluetoothConnectingNormalSuccess: {
                [weakSelf startBindingPeripheral];
                DLog(@"开始绑定蓝牙设备 name:%@ value is:%@",characteristic.UUID,characteristic.value);
            }
                break;
                //绑定请求发送后,要再次确认绑定蓝牙设备
            case BluetoothConnectingBindingSuccess: {
                if (![weakSelf isExistDeviceID:characteristic]) {
                    [weakSelf confirmBindingPeripheralWithValue:characteristic.value];
                    DLog(@"确认绑定蓝牙设备 name:%@ value is:%@",characteristic.UUID,characteristic.value);
                } else {
                    weakSelf.connectionType = BluetoothConnectingSuccess;
                }
            }
                break;
                //确认绑定成功
            case BluetoothConnectingConfirmBindingSuccess: {
                weakSelf.connectionType = BluetoothConnectingSuccess;
                [weakSelf handleBluetoothQueue];
            }
                break;
                //读取运动数据成功
            case BluetoothConnectingReadSportDataSuccess: {
                Byte *byte = (Byte *)characteristic.value.bytes;
                if (!(byte[0] == 0xAA && byte[18] == 0x04)) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:READ_SPORTDATA_ERROR
                                                                        object:nil];
                    weakSelf.connectionType = BluetoothConnectingSuccess;
                }
                else {
                    SportDataModel *model = [weakSelf sportDataModelWithData:characteristic.value];
                    [weakSelf saveNewSportData:characteristic.value];
                    DLog(@"步数 = %ld   距离 = %ld  卡路里 = %ld  目标 = %ld  电量 = %ld",model.step,model.distance,model.calorie,model.target,model.battery);
                    //下面两个调用顺序不能更改
                    weakSelf.connectionType = BluetoothConnectingSuccess;
                    [[NSNotificationCenter defaultCenter] postNotificationName:READ_SPORTDATA_SUCCESS
                                                                        object:model];
                }
                [weakSelf handleBluetoothQueue];
            }
                break;
                //设置基本信息成功
            case BluetoothConnectingSetBasicInfomationSuccess: {
                weakSelf.connectionType = BluetoothConnectingSuccess;
                [[NSNotificationCenter defaultCenter] postNotificationName:SET_BASICINFOMATION_SUCCESS
                                                                    object:nil];
                [weakSelf handleBluetoothQueue];
                NSLog(@"设置基本信息成功 name:%@ value is:%@",characteristic.UUID,characteristic.value);
            }
                break;
                //成功读取蓝牙设备中的72小时内的运动数据后(每次获取一小时的,获取72次),
                //如果还没获取完72小时数据,继续获取下一个小时的数据
                //如果获取完,
            case BluetoothConnectingHistroyReadSportDataSuccess: {
                NSLog(@"获取蓝牙设备中3天的运动数据成功 name:%@ value is:%@",characteristic.UUID,characteristic.value);
            }
                break;
                
            case BluetoothConnectingHeartRateSuccess: {
                DLog(@"打开获取心率成功");
            }
                break;
                
            case BluetoothConnectingCallAlertSuccess: {
                DLog(@"打开(关闭)来电提醒成功");
            }
                break;
            case BluetoothConnectingSetTimestampSuccess: {
                weakSelf.connectionType = BluetoothConnectingSuccess;
                BasicInfomationModel *model = [DBManager selectBasicInfomation];
                [weakSelf setBasicInfomation:model];
                NSLog(@"设置时间戳成功 name:%@ value is:%@",characteristic.UUID,characteristic.value);
//                 weakSelf.connectionType = BluetoothConnectingSuccess;
//                [[NSNotificationCenter defaultCenter] postNotificationName:SET_BASICINFOMATION_SUCCESS
//                                                                    object:nil];
//                NSLog(@"设置时间戳成功 name:%@ value is:%@",characteristic.UUID,characteristic.value);
//                [weakSelf handleBluetoothQueue];
            }
                break;
                
            case BluetoothConnectingAllSuccess: {
                Byte *byte = (Byte *)characteristic.value.bytes;
                if (byte[2] == 0xEE) {
//                    [[NSUserDefaults standardUserDefaults] setObject:@([BluetoothManager share].isOpenCallAlert)
//                                                              forKey:callAlertOpen];
                    weakSelf.connectionType = BluetoothConnectingSuccess;
                }
            }
                break;
                
            case BluetoothConnectingLostDeviceSuccess: {
                Byte *byte = (Byte *)characteristic.value.bytes;
                if (byte[2] == 0xEE) {
                    DLog(@"打开/关闭防丢失成功.");
                    
                    
                    weakSelf.connectionType = BluetoothConnectingSuccess;
                }
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)handleBluetoothQueue {
    if (_bluetoothQueue.count > 0) {
        NSDictionary *dictionary = [_bluetoothQueue objectAtIndex:0];
        [_bluetoothQueue removeObject:dictionary];
        BluetoothQueueType type = [[dictionary objectForKey:@"type"] integerValue];
        switch (type) {
            case BluetoothQueueSetBasicInfomation: {
                BasicInfomationModel *model = [dictionary objectForKey:@"model"];
                [self setBasicInfomation:model];
            }
                break;
            case BluetoothQueueReadSportData: {
                [self readSportData];
            }
                break;
            case BluetoothQueueHistroyReadSportData: {
                [self readHistroySportData];
            }
                break;
            case BluetoothQueueHeartRate: {
                [self readHeartRate];
            }
                break;
            case BluetoothQueueCallAlert: {
                [self openCallAlert];
            }
                break;
            default:
                break;
        }
    }
}

- (void)removeAllQueue {
    [_bluetoothQueue removeAllObjects];
}

- (SportDataModel *)sportDataModelWithData:(NSData *)data {
    SportDataModel *model = [[SportDataModel alloc] init];
    Byte *byte = (Byte *)data.bytes;
    model.step = (byte[2] << 8) + byte[1];              //步数
    model.distance = (byte[4] << 8) + byte[3];          //距离
    model.calorie = (byte[6] << 8) + byte[5];           //卡路里
    model.target = (byte[8] << 8) + byte[7];            //目标
    model.battery = byte[9];                            //电量
//     NSLog(@"步数 = %ld   距离 = %ld  卡路里 = %ld  目标 = %ld  电量 = %ld",model.step,model.distance,model.calorie,model.target,model.battery);
    return model;
}

- (HistorySportDataModel *)histroySportDataModelWithData:(NSData *)data {
    
    HistorySportDataModel *model = [[HistorySportDataModel alloc] init];
    Byte *byte = (Byte *)data.bytes;
    model.time = byte[1];                               //前几个小时的数据
    model.step = (byte[3] << 8) + byte[2];              //步数
    model.calorie = (byte[5] << 8) + byte[4];           //卡路里
    model.sleep = byte[6];                              //睡眠动作次数
    model.battery = byte[7];                            //电量
    NSTimeInterval timeInterval = byte[8] + (byte[9] << 8) + (byte[10] << 16) + (byte[11] << 24);
    
    model.date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
//    NSString *message = [NSString stringWithFormat:@"时间：%@  次数：%@",model.date,@(model.sleep).stringValue];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"手环发的睡眠动作次数，小于10是深睡眠，10-254是浅睡眠，255无效" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil ];
//    [alert show];
    return model;
    
}

- (BOOL)isExistDeviceID:(CBCharacteristic *)characteristic {
    Byte *b = (Byte *)characteristic.value.bytes;
    BOOL isExist = NO;
    for (NSInteger i = 6; i <=12 ; i++) {
        if (b[i] != 0) {
            isExist = YES;
            break;
        }
    }
    return isExist;
}

- (NSString *)deviceIDWithData:(NSData *)data {
    NSMutableString *string = [[NSMutableString alloc] init];
    Byte *b = (Byte *)data.bytes;
    for (NSInteger i = 6; i <=12 ; i++) {
        [string appendFormat:@"%@",@(b[i]).stringValue];
    }
    return string;
}

#pragma mark - 读取蓝牙中的数据,写入数据成功

- (void)saveNewSportData:(NSData *)data {
    SportDataModel *model = [self sportDataModelWithData:data];
    [DBManager insertOrReplaceSportData:model];
}

- (void)saveNewHistroyData:(NSData *)data time:(NSInteger)time {
    HistorySportDataModel *model = [self histroySportDataModelWithData:data];
    [DBManager insertOrReplaceHistroySportData:model];
}


#pragma mark - 写数据到蓝牙设备中

- (void)startTiming {
//    [_timer invalidate];
//    _timer = nil;
//    _timer = [NSTimer scheduledTimerWithTimeInterval:30
//                                              target:self
//                                            selector:@selector(timeOut)
//                                            userInfo:nil
//                                             repeats:NO];
}

/*!
 *  开始绑定蓝牙设备
 */
- (void)startBindingPeripheral {
    [self startTiming];
    _connectionType = BluetoothConnectingBinding;
    Byte b[20] = {0xAA,0xF1,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    [[BluetoothManager share] writeValue:data];
}

/*!
 *  确认绑定蓝牙设备
 */
- (void)confirmBindingPeripheralWithValue:(NSData *)value {
    
    __weak typeof(self) weakSelf = self;
    [_operateViewModel setFinishHandler:^(BOOL finished, id userInfo) {
        if (finished) {
            weakSelf.deviceID = userInfo;
            [weakSelf startTiming];
            weakSelf.connectionType = BluetoothConnectingConfirmBinding;
            Byte *b = (Byte *)value.bytes;
            b[1] = 0xF2;
            
            NSInteger deviceIDNumber = weakSelf.deviceID.integerValue;
            for (NSInteger i = 0; i < weakSelf.deviceID.length ;i++ ) {
                
                NSInteger idNumber = deviceIDNumber % 10;
                b[12 - i] = idNumber;
                deviceIDNumber /= 10;
            }
            
            b[19] = [BluetoothManager calculateTotal:b];
            NSData *data = [NSData dataWithBytes:b length:value.length];
            [[BluetoothManager share] writeValue:data];
        }
    }];
    [_operateViewModel createExdeviceId];
}

/*!
 *  清除所有数据
 */
- (void)clearPeripheralData {
    Byte b[20] = {0xAA,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x02,0x00};
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    [[BluetoothManager share] writeValue:data];
}

/*!
 *  读取运动数据
 *
 *  @param value
 */
- (void)readSportData {
    if (_connectionType != BluetoothConnectingSuccess && self.isReadedPripheralAllData) {
        NSDictionary *dictionary = @{@"type":@(BluetoothQueueReadSportData)};
        [_bluetoothQueue addObject:dictionary];
        return;
    }
    [self startTiming];
    _connectionType = BluetoothConnectingReadSportData;
    Byte b[20];
    b[0] = 0xAA;
    b[1] = 0xB1;
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:b length:sizeof(b)];
    [[BluetoothManager share] writeValue:data];
}


- (void)readHistroySportData {
    if (_connectionType != BluetoothConnectingSuccess && self.isReadedPripheralAllData) {
        NSDictionary *dictionary = @{@"type":@(BluetoothQueueHistroyReadSportData)};
        [_bluetoothQueue addObject:dictionary];
        return;
    }
    [self startTiming];
    _connectionType = BluetoothConnectingHistroyReadSportData;
    //需要获取几次历史数据
    NSInteger count = [self getHistoryDataCount];
    
    if (count <= 0) {
        NSLog(@"不需要获取历史运动数据");
        [MBProgressHUD showHUDByContent:NSLocalizedString(@"同步成功", nil) view:UI_Window afterDelay:1.5];
        [[NSNotificationCenter defaultCenter] postNotificationName:READ_HISTORY_SPORTDATA_SUCCESS
                                                            object:nil];
        self.connectionType = BluetoothConnectingSuccess;
        [self handleBluetoothQueue];
        return;
    }
    
    Byte b[20] = {0xAA,0xA1,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    if (count < 72 && count != 0) {
        b[2] = count;
    }else{
        b[2] = 0xFF;
    }
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:b length:sizeof(b)];
    [[BluetoothManager share] writeValue:data];
    
    _hud = [MBProgressHUD showHUDAddedTo:UI_Window animated:YES];
    _hud.labelText = NSLocalizedString(@"同步数据中...", nil);
    
    __weak BluetoothManager *weakSelf = self;
    [self.baby notify:weakSelf.bindingPeripheral.peripheral
       characteristic:weakSelf.characteristics
                block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                    NSLog(@"获取蓝牙设备中3天的运动数据成功 name:%@ value is:%@",characteristics.UUID,characteristics.value);
                    Byte *byte = (Byte *)characteristics.value.bytes;
                    NSInteger time = byte[1];
                    Byte flag = byte[2];
                    
                    //读取历史运动数据结束
                    if (flag == 0xEE) {
                        [weakSelf.baby cancelNotify:weakSelf.bindingPeripheral.peripheral
                                     characteristic:weakSelf.characteristics];
                        [[NSNotificationCenter defaultCenter] postNotificationName:READ_HISTORY_SPORTDATA_SUCCESS
                                                                            object:nil];
                        weakSelf.connectionType = BluetoothConnectingSuccess;
                        [weakSelf handleBluetoothQueue];
                        
                        [weakSelf.hud hide:YES];
                        weakSelf.hud = nil;
                        
                        [MBProgressHUD showHUDByContent:NSLocalizedString(@"同步成功", nil) view:UI_Window afterDelay:1.5];

                        return ;
                    }
                    
                    //保存历史运动数据到数据库
                    [weakSelf saveNewHistroyData:characteristics.value time:time];
                }];
}

/*!
 *  读取72小时内的运动数据
 *
 *  @param value
 */
- (void)readHistroySportDataWithValue:(NSData *)value {
    [self startTiming];
    
    //需要获取几次历史数据
    NSInteger count = [self getHistoryDataCount];
    
    if (count <= 0) {
        NSLog(@"不需要获取历史运动数据");
        [self firstReadHistroySportDataSuccess];
        return;
    }
    
    _connectionType = BluetoothConnectingHistroyReadSportData;
    Byte *b = (Byte *)value.bytes;
    b[1] = 0xA1;
    if (count < 72 && count != 0) {
        b[2] = count;
    }else{
    b[2] = 0xFF;
    }
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:b length:value.length];
    [[BluetoothManager share] writeValue:data];
    
//    _hud = [MBProgressHUD showHUDAddedTo:UI_Window animated:YES];
//    _hud.labelText = @"同步数据中...";
    
    __weak BluetoothManager *weakSelf = self;
    [self.baby notify:weakSelf.bindingPeripheral.peripheral
       characteristic:weakSelf.characteristics
                block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                    NSLog(@"获取蓝牙设备中3天的运动数据成功 name:%@ value is:%@",characteristics.UUID,characteristics.value);
                    Byte *byte = (Byte *)characteristics.value.bytes;
                    NSInteger time = byte[1];
                    Byte flag = byte[2];
                    //读取历史运动数据结束
                    if (flag == 0xEE) {

                        [weakSelf.baby cancelNotify:weakSelf.bindingPeripheral.peripheral
                                     characteristic:weakSelf.characteristics];
                        [weakSelf firstReadHistroySportDataSuccess];
                        
                        [weakSelf.hud hide:YES];
                        weakSelf.hud = nil;
                        return ;
//                        [MBProgressHUD showHUDByContent:@"同步成功" view:UI_Window afterDelay:1.5];
                        
                        //同步完发送来电提醒开关
                        [[BluetoothManager share] openCallAlert];
                    }
                    //保存历史运动数据到数据库
                    [weakSelf saveNewHistroyData:characteristics.value time:time];
                    
                }];
    
    
}

- (void)firstReadHistroySportDataSuccess {
    self.successType = BluetoothConnectingAllSuccess;
    self.isReadedPripheralAllData = YES;
    self.connectionType = BluetoothConnectingSuccess;
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:BlueToothIsReadedPripheralAllData];
    //绑定成功保存设备uuid
    if (!self.isBindingPeripheral) {
        [BluetoothManager saveBindingPeripheralUUID:self.bindingPeripheral.peripheral];
    }
    self.isBindingPeripheral = YES;
    if (self.deleagete && [self.deleagete respondsToSelector:@selector(didBindingPeripheralFinished)]) {
        [self.deleagete didBindingPeripheralFinished];
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:READ_SPORTDATA_SUCCESS
//                                                        object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:FIRST_READ_SPORTDATA_SUCCESS
                                                        object:nil];
    //同步完成后上传数据
    OperateViewModel *operateVM = [OperateViewModel viewModel];
    [operateVM saveStepData:[DBManager selectHistorySportData]];
    [operateVM saveSleepData:[DBManager selectHistorySleepData]];
//    NSString *str = [DBManager testSelectHistorySleepData];
//    NSString *Str = [DBManager selectHistorySportData];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"历史睡眠数据" message:str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alert show];
//    UIAlertView *alert1 = [[UIAlertView alloc] initWithTitle:@"历史运动数据" message:Str delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alert1 show];
    
}

/*!
 *  读取心率数据
 *
 *  @param value
 */
- (void)readHeartRate {
    if (_connectionType != BluetoothConnectingSuccess && self.isReadedPripheralAllData) {
        NSDictionary *dictionary = @{@"type":@(BluetoothQueueHeartRate)};
        [_bluetoothQueue addObject:dictionary];
        return;
    }
    [self startTiming];
    _connectionType = BluetoothConnectingHeartRate;
    Byte b[20];
    b[0] = 0xAA;
    b[1] = 0xE0;
    b[2] = 0x01;
    b[3] = 0x01;
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:b length:sizeof(b)];
    [[BluetoothManager share] writeValue:data];
    
    [_heartRateTimer invalidate];
    _heartRateTimer = nil;
    _heartRateTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                       target:self
                                                     selector:@selector(closeReadHeartRate)
                                                     userInfo:nil
                                                      repeats:NO];
    
    __weak typeof(self) weakSelf = self;
    [_baby notify:self.bindingPeripheral.peripheral
   characteristic:self.characteristics
            block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                Byte *byte = (Byte *)characteristics.value.bytes;
                weakSelf.heartRate = byte[1];
                [[NSNotificationCenter defaultCenter] postNotificationName:READ_HEARTRATE_SUCCESS
                                                                    object:nil];
                DLog(@"获取心率 : %@      %@",characteristics.value,@(weakSelf.heartRate).stringValue);
            }];
}

/*!
 *  关闭读取心率
 */
- (void)closeReadHeartRate {
    [self startTiming];
    Byte b[20] = {0xAA,0xE0,0x02,0x02,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x02,0x00};
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    [self.bindingPeripheral.peripheral writeValue:data
                                forCharacteristic:self.characteristics
                                             type:CBCharacteristicWriteWithResponse];
    [_heartRateTimer invalidate];
    [_baby cancelNotify:self.bindingPeripheral.peripheral
         characteristic:self.characteristics];
    self.connectionType = BluetoothConnectingSuccess;
    [self handleBluetoothQueue];
    [[NSNotificationCenter defaultCenter] postNotificationName:READ_HEARTRATE_FINISHED
                                                        object:nil];
}

/*!
 *  来电提醒开关
 *
 *  @param value
 */
- (void)openCallAlert
{
    if (_connectionType != BluetoothConnectingSuccess && self.isReadedPripheralAllData) {
        NSDictionary *dictionary = @{@"type":@(BluetoothQueueCallAlert)};
        [_bluetoothQueue addObject:dictionary];
        return;
    }
    NSInteger remindWay = [[[NSUserDefaults standardUserDefaults] objectForKey:callAlertOpen] integerValue];
    [self startTiming];
    _connectionType = BluetoothConnectingCallAlert;
    Byte b[20];
    b[0] = 0xAA;
    b[1] = 0xE1;
    b[2] = remindWay;
//    if (_isOpenCallAlert) {
//      b[2] = 0x0F;
//    }else{
//        b[2] = 0x00;
//    }
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:b length:sizeof(b)];
    [[BluetoothManager share] writeValue:data];
    
}

//设备防丢失开关
- (void)lostDevice:(BOOL)open {
    if (_connectionType != BluetoothConnectingSuccess && self.isReadedPripheralAllData) {
        NSDictionary *dictionary = @{@"type":@(BluetoothConnectingLostDevice)};
        [_bluetoothQueue addObject:dictionary];
        return;
    }
    [self startTiming];
    _connectionType = BluetoothConnectingLostDevice;
    Byte b[20];
    b[0] = 0xAA;
    if (open) {
        b[1] = 0x02;
        _rssiTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self.bindingPeripheral.peripheral
                                                    selector:@selector(readRSSI)
                                                    userInfo:nil
                                                     repeats:YES];
    }
    else {
        b[1] = 0x03;
        [_rssiTimer invalidate];
        _rssiTimer = nil;
    }
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:b length:sizeof(b)];
    [[BluetoothManager share] writeValue:data];
}

//提醒用户设备丢失
- (void)alertUserLostDevice {
    [self startTiming];
    _connectionType = BluetoothConnectingLostDevice;
    Byte b[20];
    b[0] = 0xAA;
    b[1] = 0x02;
    b[2] = 0x04;
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:b length:sizeof(b)];
    [[BluetoothManager share] writeValue:data];
}

//设置时间戳
- (void)setTimestamp {
    _connectionType = BluetoothConnectingSetTimestamp;
    NSInteger interval = [NSDate date].timeIntervalSince1970;
    Byte b[20];
    b[0] = 0xAA;
    b[1] = 0xDA;
    char *p_time = (char *)&interval;
    for(int i = 2 ;i < 19 ;i++) {
        if (i > 5) {
            b[i] = 0;
        } else {
            b[i] = *p_time;
            p_time ++;
        }
    }
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [[NSData alloc] initWithBytes:b length:sizeof(b)];
    [[BluetoothManager share] writeValue:data];
}

- (void)setBasicInfomation:(BasicInfomationModel *)model {
    if (_connectionType != BluetoothConnectingSuccess && self.isReadedPripheralAllData) {
        NSDictionary *dictionary = @{@"type":@(BluetoothQueueSetBasicInfomation),
                                    @"model":model};
        [_bluetoothQueue addObject:dictionary];
        return;
    }
    _connectionType = BluetoothConnectingSetBasicInfomation;
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit;
    comps = [calendar components:unitFlags fromDate:date];

    Byte b[20];
    b[0] = 0xAA;
    b[1] = 0x00;
    b[2] = [comps year] % 100;
    b[3] = [comps month];
    b[4] = [comps day];
    b[5] = [comps hour];
    b[6] = [comps minute];
    b[7] = model.height;
    b[8] = model.weight;
    b[9] = model.distance;
    b[10] = model.clockSwitch;
    b[11] = model.clockHour;
    b[12] = model.clockMinute;
    b[13] = model.clockInterval;
    b[14] = model.sportSwitch;
    b[15] = model.startTime;
    b[16] = model.endTime;
    b[17] = model.sportInterval;
//    NSInteger taget = (NSInteger)(model.target * CurrentUser.stepLong.integerValue * 0.01 * 0.01);
    b[18] = model.target;
    b[19] = [BluetoothManager calculateTotal:b];
    
    NSData *data = [NSData dataWithBytes:b length:sizeof(b)];
    [[BluetoothManager share] writeValue:data];
}


+ (Byte)calculateTotal:(Byte *)resultByte {
    NSInteger result = 0;
    for (int i = 0; i < 19; i++ ) {
        result += resultByte[i];
    }
    Byte byte = result % 256;
    return byte;
}

- (void)writeValue:(NSData *)data {
    if (self.bindingPeripheral.peripheral && self.characteristics) {
        [self.bindingPeripheral.peripheral writeValue:data
                                    forCharacteristic:self.characteristics
                                                 type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark -

+ (BOOL)saveBindingPeripheralUUID:(CBPeripheral *)peripheral {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:peripheral.identifier.UUIDString forKey:@"peripheralIdentifier"];
    [defaults setObject:@(YES) forKey:@"isbindingPeripheral"];
    return [defaults synchronize];
}

+ (NSString *)getBindingPeripheralUUID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:@"peripheralIdentifier"];
}

+ (BOOL)clearBindingPeripheral {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"peripheralIdentifier"];
    [defaults setObject:nil forKey:@"isbindingPeripheral"];
    [BluetoothManager share].isConnectSuccess = NO;
    return [defaults synchronize];
}


#pragma mark - 

- (BOOL)isExistCharacteristic {
    if (!_characteristics || !_isReadedPripheralAllData ) {
        DLog(@"蓝牙设备未连接上..");
        return NO;
    }
    return YES;
}

- (void)timeOut {
    //如果在第一次绑定设备或者重新打开应用同步数据超时,标识已同步
    if (!_isReadedPripheralAllData) {
        _isReadedPripheralAllData = YES;
    }
    if (_hud) {
        [_hud setHidden:YES];
        _hud = nil;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"" object:nil];
}

- (void)cancel {
    if (self.isConnectSuccess && self.isReadedPripheralAllData) {
        self.connectionType = BluetoothConnectingSuccess;
        self.successType = BluetoothConnectingAllSuccess;
    }
}

- (NSInteger)getHistoryDataCount
{
    NSDate *date = [DBManager selectNewestHistoryData];
    
    NSInteger historyTime = date.timeIntervalSince1970;
    NSInteger getHistoryDataCount = 0;
    NSInteger nowTime = [NSDate date].timeIntervalSince1970;
    getHistoryDataCount = (nowTime - historyTime) / 3600;
    
    return getHistoryDataCount;
    
}


@end
