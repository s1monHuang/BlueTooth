//
//  BluetoothManager.m
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/9.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "BluetoothManager.h"
#import "SportDataModel.h"
#import "HistroySportDataModel.h"


#define BlueToothIsReadedPripheralAllData @"isReadedPripheralAllData"
#define specifiedUUID @"FFF0"

static BluetoothManager *manager = nil;


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
        _isReadedPripheralAllData = [[NSUserDefaults standardUserDefaults] boolForKey:BlueToothIsReadedPripheralAllData];
        //初始化BabyBluetooth 蓝牙库
        _baby = [BabyBluetooth shareBabyBluetooth];
        //设置蓝牙委托
        [self babyDelegate];
        
        [_baby cancelAllPeripheralsConnection];
        if (_isBindingPeripheral) {
            //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
            _baby.scanForPeripherals().begin();
        }
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
        for (CBService *s in peripheral.services) {
            //查找到指定的服务
            if ([s.UUID.UUIDString isEqualToString:specifiedUUID]) {
//                weakSelf.specifiedService = s;
                return ;
            }
        }
    }];
    
    //设置读取characteristics的委托
    [_baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        //如果是第一次绑定设备,读取蓝牙设备中的相关信息
        if (!weakSelf.isReadedPripheralAllData) {
            [weakSelf firstReadPripheralData:weakSelf
                              characteristic:characteristics];
        }
    }];
    
    //设置写数据成功的block
    [_baby setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        if ([characteristic.UUID.UUIDString isEqualToString:@"FFF1"]) {
            //如果是第一次读取蓝牙设备中的数据
            if (!weakSelf.isReadedPripheralAllData) {
                switch (weakSelf.connectionType) {
                        //绑定请求发送成功,需要要再次确认绑定蓝牙设备
                    case BluetoothConnectingBinding: {
                        weakSelf.successType = BluetoothConnectingBindingSuccess;
                    }
                        break;
                        //成功绑定蓝牙设备,需要读取运动数据
                    case BluetoothConnectingConfirmBinding: {
                        weakSelf.successType = BluetoothConnectingConfirmBindingSuccess;
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
//                    case BluetoothConnectingHeartRate: {
//                        weakSelf.successType = BluetoothConnectingHeartRateSuccess;
//                    }
//                        break;
                    default:
                        break;
                }

            }
            [weakSelf.bindingPeripheral.peripheral readValueForCharacteristic:characteristic];
        }
//        NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel cha racteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
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
        if (!weakSelf.isBindingPeripheral) {
            [BluetoothManager saveBindingPeripheralUUID:peripheral];
        }
        weakSelf.isBindingPeripheral = YES;
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
        if (weakSelf.isBindingPeripheral) {
            [weakSelf.baby cancelNotify:weakSelf.bindingPeripheral.peripheral
                         characteristic:weakSelf.characteristics];
            weakSelf.connectionType = BluetoothConnectingNormal;
            weakSelf.characteristics = nil;
            [weakSelf connectingBlueTooth:peripheral];
        }
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
    if ([characteristics.UUID.UUIDString isEqualToString:@"FFF1"] ) {
        if (!weakSelf.characteristics) {
            weakSelf.characteristics = characteristics;
        }
        switch (weakSelf.successType) {
                //绑定请求发送后,要再次确认绑定蓝牙设备
            case BluetoothConnectingBindingSuccess: {
                [weakSelf confirmBindingPeripheralWithValue:characteristics.value];
                NSLog(@"确认绑定蓝牙设备 name:%@ value is:%@",characteristics.UUID,characteristics.value);
            }
                break;
                //成功绑定蓝牙设备后,读取运动数据
            case BluetoothConnectingConfirmBindingSuccess: {
                [weakSelf readSportDataWithValue:characteristics.value];
                NSLog(@"绑定蓝牙设备成功,开始获取运动数据 name:%@ value is:%@",characteristics.UUID,characteristics.value);
            }
                break;
                //成功读取蓝牙设备中的运动数据后,读取72小时蓝牙设备中的运动数据
            case BluetoothConnectingReadSportDataSuccess: {
                NSLog(@"获取蓝牙设备中的运动数据成功 name:%@ value is:%@",characteristics.UUID,characteristics.value);
                //读取蓝牙设备中的运动数据
                [weakSelf saveNewSportData:characteristics.value];
                [weakSelf readHistroySportDataWithValue:characteristics.value time:0x00];
            }
                break;
                //成功读取蓝牙设备中的72小时内的运动数据后(每次获取一小时的,获取72次),
                //如果还没获取完72小时数据,继续获取下一个小时的数据
                //如果获取完,
            case BluetoothConnectingHistroyReadSportDataSuccess: {
                NSLog(@"获取蓝牙设备中3天的运动数据成功 name:%@ value is:%@",characteristics.UUID,characteristics.value);
                Byte *byte = (Byte *)characteristics.value.bytes;
                NSInteger time = byte[1];
                [weakSelf saveNewHistroyData:characteristics.value time:time];
                //获取72小时内的历史数据
                if (time < 71) {
                    [weakSelf readHistroySportDataWithValue:characteristics.value time:++time];
                } else {
                    weakSelf.successType = BluetoothConnectingAllSuccess;
                    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:BlueToothIsReadedPripheralAllData];
//                    [weakSelf readHeartRateWithValue:characteristics.value];
                }
            }
                break;
            default: {
                Byte *byte = (Byte *)characteristics.value.bytes;
                if (byte[1] == 0x0F) {
                    [weakSelf confirmBindingPeripheralWithValue:characteristics.value];
                    NSLog(@"确认绑定蓝牙设备 name:%@ value is:%@",characteristics.UUID,characteristics.value);
                } else {
                    [weakSelf startBindingPeripheral];
                    NSLog(@"开始绑定蓝牙设备 name:%@ value is:%@",characteristics.UUID,characteristics.value);
                }
            }
                break;
        }
    }
}

#pragma mark - 读取蓝牙中的数据,写入数据成功

- (void)saveNewSportData:(NSData *)data {
    SportDataModel *model = [[SportDataModel alloc] init];
    Byte *byte = (Byte *)data.bytes;
    model.step = (byte[2] << 8) + byte[1];              //步数
    model.distance = (byte[4] << 8) + byte[3];          //距离
    model.calorie = (byte[6] << 8) + byte[5];           //卡路里
    model.target = (byte[8] << 8) + byte[7];            //目标
    model.battery = byte[9];                            //电量
    NSLog(@"步数 = %ld   距离 = %ld  卡路里 = %ld  目标 = %ld  电量 = %ld",model.step,model.distance,model.calorie,model.target,model.battery);
}

- (void)saveNewHistroyData:(NSData *)data time:(NSInteger)time {
    HistroySportDataModel *model = [[HistroySportDataModel alloc] init];
    Byte *byte = (Byte *)data.bytes;
    model.time = byte[1];                               //前几个小时的数据
    model.step = (byte[3] << 8) + byte[2];              //步数
    model.calorie = (byte[5] << 8) + byte[4];           //卡路里
    model.sleep = byte[6];                              //睡眠动作次数
    model.battery = byte[7];                            //电量
    NSInteger timeInterval = byte[8] + (byte[9] << 8) + (byte[10] << 16) + (byte[11] << 24);
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-DD HH:mm:ss"];
    NSString *myDataString = @"2000-01-01 0:0:00";
    model.date = [NSDate dateWithTimeInterval:timeInterval sinceDate:[df dateFromString:myDataString]];
    
    NSLog(@"时间 = %ld 步数 = %ld  卡路里 = %ld  睡眠动作次数 = %ld  电量 = %ld  日期 = %@",model.time,model.step,model.calorie,model.sleep,model.battery,model.date);
}


#pragma mark - 写数据到蓝牙设备中

- (void)handleCharacteristicsFFF1:(CBCharacteristic *)characteristics weakSelf:(BluetoothManager *)weakSelf {
    Byte *resultByte = (Byte *)characteristics.value.bytes;
    if (resultByte[1] == 0x0F) {
        [weakSelf confirmBindingPeripheralWithValue:characteristics.value];
    } else if (resultByte[1] == 0xF2) {
        NSLog(@"设备已绑定,characteristics value is %@",characteristics.value);
    } else {
        [weakSelf startBindingPeripheral];
    }
}

- (void)handleBindingPeripheral:(CBCharacteristic *)characteristics weakSelf:(BluetoothManager *)weakSelf {
    
}

/*!
 *  开始绑定蓝牙设备
 */
- (void)startBindingPeripheral {
    _connectionType = BluetoothConnectingBinding;
    Byte b[20] = {0xAA,0xF1,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    [self.bindingPeripheral.peripheral writeValue:data
                                forCharacteristic:self.characteristics
                                             type:CBCharacteristicWriteWithResponse];
}

/*!
 *  确认绑定蓝牙设备
 */
- (void)confirmBindingPeripheralWithValue:(NSData *)value {
    _connectionType = BluetoothConnectingConfirmBinding;
    Byte *b = (Byte *)value.bytes;
    b[1] = 0xF2;
    b[6] = 0x00;
    b[7] = 0x00;
    b[8] = 0x00;
    b[9] = 0x00;
    b[10] = 0x00;
    b[11] = 0x00;
    b[12] = 0x00;
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:b length:value.length];
    [self.bindingPeripheral.peripheral writeValue:data
                                forCharacteristic:self.characteristics
                                             type:CBCharacteristicWriteWithResponse];
}

/*!
 *  清除所有数据
 */
- (void)clearPeripheralData {
    Byte b[20] = {0xAA,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x02,0x00};
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    [self.bindingPeripheral.peripheral writeValue:data
                                    forCharacteristic:self.characteristics
                                                 type:CBCharacteristicWriteWithResponse];
}

/*!
 *  读取运动数据
 *
 *  @param value
 */
- (void)readSportDataWithValue:(NSData *)value {
    _connectionType = BluetoothConnectingReadSportData;
    Byte *b = (Byte *)value.bytes;
    b[1] = 0xB1;
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:b length:value.length];
    [self.bindingPeripheral.peripheral writeValue:data
                                forCharacteristic:self.characteristics
                                             type:CBCharacteristicWriteWithResponse];
}

/*!
 *  读取72小时内的运动数据
 *
 *  @param value
 */
- (void)readHistroySportDataWithValue:(NSData *)value time:(Byte)time{
    _connectionType = BluetoothConnectingHistroyReadSportData;
    Byte *b = (Byte *)value.bytes;
    b[1] = 0xA1;
    b[2] = time;
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:b length:value.length];
    [self.bindingPeripheral.peripheral writeValue:data
                                forCharacteristic:self.characteristics
                                             type:CBCharacteristicWriteWithResponse];
}

/*!
 *  读取心率数据
 *
 *  @param value
 */
- (void)readHeartRateWithValue:(NSData *)value {
    _connectionType = BluetoothConnectingReadSportData;
    Byte *b = (Byte *)value.bytes;
    b[1] = 0xE0;
    b[2] = 0x01;
    b[3] = 0x02;
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:b length:value.length];
    [self.bindingPeripheral.peripheral writeValue:data
                                forCharacteristic:self.characteristics
                                             type:CBCharacteristicWriteWithResponse];
    
    __weak typeof(self) weakSelf = self;
    [_baby notify:self.bindingPeripheral.peripheral
   characteristic:self.characteristics
            block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                NSLog(@"获取心率 : %@",characteristics.value);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf closeReadHeartRate];
                });
            }];
}

/*!
 *  关闭读取心率
 */
- (void)closeReadHeartRate {
    Byte b[20] = {0xAA,0xE0,0x02,0x02,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x02,0x00};
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    [self.bindingPeripheral.peripheral writeValue:data
                                forCharacteristic:self.characteristics
                                             type:CBCharacteristicWriteWithResponse];
    [_baby cancelNotify:self.bindingPeripheral.peripheral
         characteristic:self.characteristics];
}


+ (Byte)calculateTotal:(Byte *)resultByte {
    Byte byte;
    for (int i = 0; i < 19; i++ ) {
        byte += resultByte[i];
    }
    NSInteger result = byte % 256;
    return (Byte)result;
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
    return [defaults synchronize];
}



@end
