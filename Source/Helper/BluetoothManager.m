//
//  BluetoothManager.m
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/9.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "BluetoothManager.h"


#define channelOnPeropheralView @"peripheralView"
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
//        if (_isBindingPeripheral) {
//            _bindingPeripheral = [DataStoreHelper getPeripheral];
//        }
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
//        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
        if ([characteristics.UUID.UUIDString isEqualToString:@"FFF1"] ) {
            if (!weakSelf.characteristics) {
                weakSelf.characteristics = characteristics;
            }
            switch (weakSelf.type) {
                //绑定请求发送后,要再次确认绑定蓝牙设备
                case BluetoothConnectingBinding: {
                    [weakSelf confirmBindingPeripheralWithValue:characteristics.value];
                    NSLog(@"确认绑定蓝牙设备 name:%@ value is:%@",characteristics.UUID,characteristics.value);
                }
                    break;
                //成功绑定蓝牙设备后,读取运动数据
                case BluetoothConnectingReadSportData: {
                    [weakSelf readSportDataWithValue:characteristics.value];
                    NSLog(@"绑定蓝牙设备成功,开始获取运动数据 name:%@ value is:%@",characteristics.UUID,characteristics.value);
                }
                    break;
                case BluetoothConnectingSuccess: {
                    NSLog(@"获取蓝牙设备中的运动数据成功 name:%@ value is:%@",characteristics.UUID,characteristics.value);
//                    Byte *byte = (Byte *)characteristics.value.bytes;
                    Byte byte[5] = {0xAA,0x30,0x75,0xB3,0x01};
                    NSInteger step = (byte[2] << 8) + byte[1];
                    NSInteger distance = (byte[4] << 8) + byte[3];
                    NSLog(@"%ld    %ld",step,distance);
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
    }];
    
    //设置写数据成功的block
    [_baby setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        if ([characteristic.UUID.UUIDString isEqualToString:@"FFF1"]) {
            switch (weakSelf.type) {
                //绑定请求发送成功,需要要再次确认绑定蓝牙设备
                case BluetoothConnectingBinding: {
                    weakSelf.type = BluetoothConnectingConfirmBinding;
                }
                    break;
                //成功绑定蓝牙设备,需要读取运动数据
                case BluetoothConnectingConfirmBinding: {
                    weakSelf.type = BluetoothConnectingReadSportData;
                }
                    break;
                //成功读取蓝牙设备中的运动数据,
                case BluetoothConnectingReadSportData: {
                    weakSelf.type = BluetoothConnectingSuccess;
                }
                    break;
                default:
                    break;
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
            weakSelf.type = BluetoothConnectingNormal;
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

#pragma mark - 读取蓝牙中的数据,写入数据成功

//- (void)readNewData:()


#pragma mark -

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

- (void)startBindingPeripheral {
    _type = BluetoothConnectingBinding;
    Byte b[20] = {0xAA,0xF1,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    [self.bindingPeripheral.peripheral writeValue:data
                                forCharacteristic:self.characteristics
                                             type:CBCharacteristicWriteWithResponse];
}

- (void)confirmBindingPeripheralWithValue:(NSData *)value {
    _type = BluetoothConnectingConfirmBinding;
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

- (void)clearBindingPeripheralData {
    Byte b[20] = {0xAA,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x02,0x00};
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    [self.bindingPeripheral.peripheral writeValue:data
                                    forCharacteristic:self.characteristics
                                                 type:CBCharacteristicWriteWithResponse];
}

//- (void)readBindingPeripheralDataWithValue:(NSData *)value {
//    _type = BluetoothConnectingRead;
//    Byte *b = (Byte *)value.bytes;
//    b[1] = 0xB1;
//    b[19] = [BluetoothManager calculateTotal:b];
//    NSData *data = [NSData dataWithBytes:b length:value.length];
//    [self.bindingPeripheral.peripheral writeValue:data
//                                forCharacteristic:self.characteristics
//                                             type:CBCharacteristicWriteWithResponse];
//}

- (void)readSportDataWithValue:(NSData *)value {
    _type = BluetoothConnectingReadSportData;
    Byte *b = (Byte *)value.bytes;
    b[1] = 0xB1;
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:b length:value.length];
    [self.bindingPeripheral.peripheral writeValue:data
                                forCharacteristic:self.characteristics
                                             type:CBCharacteristicWriteWithResponse];
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
