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
        _isConnectSuccess = NO;
        
        _bluetoothQueue = [[NSMutableArray alloc] init];
        
        _operateViewModel = [[OperateViewModel alloc] init];
        
        _firstSynchron = YES;
        
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
    _baby.having(peripheral).and.then.connectToPeripherals().discoverServices().discoverCharacteristics().begin();
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
    
    //设置查找到Characteristics的block
    [_baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral,CBService *service,NSError *error) {
        if ([service.UUID.UUIDString isEqualToString:ServiceUUID]) {
            for (CBCharacteristic *characteristic in service.characteristics) {
                if ([characteristic.UUID.UUIDString isEqualToString:specifiedUUID]) {
                    weakSelf.FFF1characteristic = characteristic;
                } else if ([characteristic.UUID.UUIDString isEqualToString:sosUUID]) {
                    weakSelf.FFF2Characteristic = characteristic;
                }
            }
        }
        if (weakSelf.FFF1characteristic && weakSelf.FFF2Characteristic) {
            [weakSelf startBindingPeripheral];
        }
    }];
    
    //设置读取characteristics的委托
    [_baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        [weakSelf readedNewCharacteristic:characteristics error:error];
    }];
    
    //设置写数据成功的block
    [_baby setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        if (characteristic == weakSelf.FFF1characteristic) {
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
        
        weakSelf.FFF1characteristic = nil;
        weakSelf.FFF2Characteristic = nil;
        weakSelf.isConnectSuccess = NO;
        weakSelf.firstSynchron = YES;
        
        [weakSelf removeAllQueue];
        
        if (weakSelf.isBindingPeripheral) {
            if (weakSelf.bindingPeripheral.peripheral && weakSelf.FFF1characteristic) {
                [weakSelf.baby cancelNotify:weakSelf.bindingPeripheral.peripheral
                             characteristic:weakSelf.FFF1characteristic];
            }
            [weakSelf connectingBlueTooth:peripheral];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:DISCONNECT_PERIPHERAL
                                                            object:nil];
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

#pragma mark - new


- (void)readedNewCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        return;
    }
    if (!_firstSynchron) {
        _writing = NO;
    }
    switch (_tag) {
        case BluetoothBinding: {
            [self handleBindingByCharacteristic:characteristic];
        }
            break;
        case BluetoothConfirmBinding: {
            [self handleConfirmBindingByCharacteristic:characteristic];
        }
            break;
        case BluetoothSetBasicInfomation: {
            [self handleSetBasicInfomationByCharacteristic:characteristic];
        }
            break;
        case BluetoothSetTimestamp: {
            [self handleSetTimestampByCharacteristic:characteristic];
        }
            break;
        case BluetoothReadSportData: {
            [self handleReadSportDataByCharacteristic:characteristic];
        }
            break;
        case BluetoothHistroyReadSportData: {
            [self handleHistroyReadSportDataByCharacteristic:characteristic];
        }
            break;
        case BluetoothHeartRate: {
            [self handleHeartRateByCharacteristic:characteristic];
        }
            break;
        case BluetoothCallAlert: {
            [self handleCallAlertByCharacteristic:characteristic];
        }
            break;
        case BluetoothLostDevice: {
            [self handleLostDeviceByCharacteristic:characteristic];
        }
            break;
        default:
            break;
    }
}


/*!
 *  处理绑定蓝牙设备
 *
 *  @param characteristic
 */
- (void)handleBindingByCharacteristic:(CBCharacteristic *)characteristic {
    if ([self isExistDeviceID:characteristic]) {
        NSString *deviceID = [self deviceIDWithData:characteristic.value];
        if (deviceID) {
            [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:User_DeviceID];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        BasicInfomationModel *model = [DBManager selectBasicInfomation];
        [self setBasicInfomation:model];
        NSLog(@"蓝牙设备中有设备ID,开始设置基本信息 name:%@ value is:%@",characteristic.UUID,characteristic.value);
    } else {
        [self confirmBindingPeripheralWithValue:characteristic.value];
        NSLog(@"确认绑定蓝牙设备 name:%@ value is:%@",characteristic.UUID,characteristic.value);
    }
}

/*!
 *  处理确认绑定蓝牙设备
 *
 *  @param characteristic
 */
- (void)handleConfirmBindingByCharacteristic:(CBCharacteristic *)characteristic {
    BasicInfomationModel *model = [DBManager selectBasicInfomation];
    [self setBasicInfomation:model];
    NSLog(@"绑定蓝牙设备成功,开始设置基本信息 name:%@ value is:%@",characteristic.UUID,characteristic.value);
}

/*!
 *  处理设置基本信息
 *
 *  @param characteristic
 */
- (void)handleSetBasicInfomationByCharacteristic:(CBCharacteristic *)characteristic {
    [self setTimestamp];
    NSLog(@"成功设置基本信息后,设置时间戳 name:%@ value is:%@",characteristic.UUID,characteristic.value);
}

/*!
 *  处理设置时间戳
 *
 *  @param characteristic
 */
- (void)handleSetTimestampByCharacteristic:(CBCharacteristic *)characteristic {
    if (_firstSynchron) {
        [self readSportData];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:SET_BASICINFOMATION_SUCCESS
                                                            object:nil];
    }
    NSLog(@"设置时间戳成功 name:%@ value is:%@",characteristic.UUID,characteristic.value);
}

/*!
 *  处理获取运动数据
 *
 *  @param characteristic
 */
- (void)handleReadSportDataByCharacteristic:(CBCharacteristic *)characteristic {
    if (_firstSynchron) {
        //如果没有绑定设备,获取历史运动数据
        if (![BluetoothManager getBindingPeripheralUUID]) {
            [self saveNewSportData:characteristic.value];
            [self readHistroySportDataWithValue:characteristic.value];
        } else {
            Byte *byte = (Byte *)characteristic.value.bytes;
            if ((byte[0] == 0xAA && byte[18] == 0x04)) {
                SportDataModel *model = [self sportDataModelWithData:characteristic.value];
                NSLog(@"步数 = %ld   距离 = %ld  卡路里 = %ld  目标 = %ld  电量 = %ld",model.step,model.distance,model.calorie,model.target,model.battery);
                
            }
            self.isReadedPripheralAllData = YES;
            self.writing = NO;
            self.firstSynchron = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:FIRST_READ_SPORTDATA_SUCCESS
                                                                object:nil];
        }
    }
    
    else {
        Byte *byte = (Byte *)characteristic.value.bytes;
        if (!(byte[0] == 0xAA && byte[18] == 0x04)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:READ_SPORTDATA_ERROR
                                                                object:nil];
        }
        else {
            SportDataModel *model = [self sportDataModelWithData:characteristic.value];
            [self saveNewSportData:characteristic.value];
            NSLog(@"步数 = %ld   距离 = %ld  卡路里 = %ld  目标 = %ld  电量 = %ld",model.step,model.distance,model.calorie,model.target,model.battery);
            [[NSNotificationCenter defaultCenter] postNotificationName:READ_SPORTDATA_SUCCESS
                                                                object:model];
        }

    }
    
    NSLog(@"获取蓝牙设备中的运动数据成功 name:%@ value is:%@",characteristic.UUID,characteristic.value);
}


- (void)handleHistroyReadSportDataByCharacteristic:(CBCharacteristic *)characteristic {
    NSLog(@"获取蓝牙设备中3天的运动数据成功 name:%@ value is:%@",characteristic.UUID,characteristic.value);
}

- (void)handleHeartRateByCharacteristic:(CBCharacteristic *)characteristic {
    
}

- (void)handleCallAlertByCharacteristic:(CBCharacteristic *)characteristic {
    
}

- (void)handleLostDeviceByCharacteristic:(CBCharacteristic *)characteristic {
    
}


#pragma mark - 队列


- (void)handleBluetoothQueue {
    if (_bluetoothQueue.count > 0) {
        NSDictionary *dictionary = [_bluetoothQueue objectAtIndex:0];
        [_bluetoothQueue removeObject:dictionary];
        BluetoothTag tag = [[dictionary objectForKey:@"tag"] integerValue];
        switch (tag) {
            case BluetoothSetBasicInfomation: {
                BasicInfomationModel *model = [dictionary objectForKey:@"model"];
                [self setBasicInfomation:model];
            }
                break;
            case BluetoothReadSportData: {
                [self readSportData];
            }
                break;
            case BluetoothHistroyReadSportData: {
                [self readHistroySportData];
            }
                break;
            case BluetoothHeartRate: {
                [self readHeartRate];
            }
                break;
            case BluetoothCallAlert: {
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
    [_timer invalidate];
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:30
                                              target:self
                                            selector:@selector(timeOut)
                                            userInfo:nil
                                             repeats:NO];
}

/*!
 *  开始绑定蓝牙设备
 */
- (void)startBindingPeripheral {
    [self startTiming];
    _tag = BluetoothBinding;
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
            weakSelf.tag = BluetoothConfirmBinding;
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
    if (_writing && self.isReadedPripheralAllData) {
        NSDictionary *dictionary = @{@"tag":@(BluetoothReadSportData)};
        [_bluetoothQueue addObject:dictionary];
        return;
    }
    [self startTiming];
    
    _tag = BluetoothReadSportData;
    _writing = YES;
    
    Byte b[20];
    b[0] = 0xAA;
    b[1] = 0xB1;
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:b length:sizeof(b)];
    [[BluetoothManager share] writeValue:data];
}


- (void)readHistroySportData {
    if (_writing && self.isReadedPripheralAllData) {
        NSDictionary *dictionary = @{@"tag":@(BluetoothHistroyReadSportData)};
        [_bluetoothQueue addObject:dictionary];
        return;
    }
    [self startTiming];
    
    _writing = YES;
    _tag = BluetoothHistroyReadSportData;
    
    //需要获取几次历史数据
    NSInteger count = [self getHistoryDataCount];
    
    if (count <= 0) {
        NSLog(@"不需要获取历史运动数据");
        [MBProgressHUD showHUDByContent:@"同步成功" view:UI_Window afterDelay:1.5];
        [[NSNotificationCenter defaultCenter] postNotificationName:READ_HISTORY_SPORTDATA_SUCCESS
                                                            object:nil];
        _writing = NO;
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
    _hud.labelText = @"同步数据中...";
    
    __weak BluetoothManager *weakSelf = self;
    [self.baby notify:weakSelf.bindingPeripheral.peripheral
       characteristic:weakSelf.FFF1characteristic
                block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                    NSLog(@"获取蓝牙设备中3天的运动数据成功 name:%@ value is:%@",characteristics.UUID,characteristics.value);
                    Byte *byte = (Byte *)characteristics.value.bytes;
                    NSInteger time = byte[1];
                    Byte flag = byte[2];
                    //保存历史运动数据到数据库
                    [weakSelf saveNewHistroyData:characteristics.value time:time];
                    
                    //读取历史运动数据结束
                    if (flag == 0xEE) {
                        [weakSelf.baby cancelNotify:weakSelf.bindingPeripheral.peripheral
                                     characteristic:weakSelf.FFF1characteristic];
                        [[NSNotificationCenter defaultCenter] postNotificationName:READ_HISTORY_SPORTDATA_SUCCESS
                                                                            object:nil];
                        weakSelf.writing = NO;
                        [weakSelf handleBluetoothQueue];
                        
                        [weakSelf.hud hide:YES];
                        weakSelf.hud = nil;
                        
                        [MBProgressHUD showHUDByContent:@"同步成功" view:UI_Window afterDelay:1.5];

                    }
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
        self.firstSynchron = NO;
        return;
    }
    
    _tag = BluetoothHistroyReadSportData;
    _writing = YES;
    
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
    
    
    __weak BluetoothManager *weakSelf = self;
    [self.baby notify:weakSelf.bindingPeripheral.peripheral
       characteristic:weakSelf.FFF1characteristic
                block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                    NSLog(@"获取蓝牙设备中3天的运动数据成功 name:%@ value is:%@",characteristics.UUID,characteristics.value);
                    Byte *byte = (Byte *)characteristics.value.bytes;
                    NSInteger time = byte[1];
                    Byte flag = byte[2];
                    //保存历史运动数据到数据库
                    [weakSelf saveNewHistroyData:characteristics.value time:time];
                    weakSelf.writing = NO;
                    weakSelf.firstSynchron = NO;
                    //读取历史运动数据结束
                    if (flag == 0xEE) {

                        [weakSelf.baby cancelNotify:weakSelf.bindingPeripheral.peripheral
                                     characteristic:weakSelf.FFF1characteristic];
                        [weakSelf firstReadHistroySportDataSuccess];
                        
                        [weakSelf.hud hide:YES];
                        weakSelf.hud = nil;
                    }
                }];
    
    
}

- (void)firstReadHistroySportDataSuccess {
    self.isReadedPripheralAllData = YES;
    _writing = NO;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:BlueToothIsReadedPripheralAllData];
    //绑定成功保存设备uuid
    if (!self.isBindingPeripheral) {
        [BluetoothManager saveBindingPeripheralUUID:self.bindingPeripheral.peripheral];
    }
    self.isBindingPeripheral = YES;
    if (self.deleagete && [self.deleagete respondsToSelector:@selector(didBindingPeripheralFinished)]) {
        [self.deleagete didBindingPeripheralFinished];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FIRST_READ_SPORTDATA_SUCCESS
                                                        object:nil];
    //同步完成后上传数据
    OperateViewModel *operateVM = [OperateViewModel viewModel];
    [operateVM saveStepData:[DBManager selectHistorySportData]];
    [operateVM saveSleepData:[DBManager selectHistorySleepData]];
}

/*!
 *  读取心率数据
 *
 *  @param value
 */
- (void)readHeartRate {
    if (_writing && self.isReadedPripheralAllData) {
        NSDictionary *dictionary = @{@"tag":@(BluetoothHeartRate)};
        [_bluetoothQueue addObject:dictionary];
        return;
    }
    [self startTiming];
    
    _writing = YES;
    _tag = BluetoothHeartRate;
    
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
   characteristic:self.FFF1characteristic
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
                                forCharacteristic:self.FFF1characteristic
                                             type:CBCharacteristicWriteWithResponse];
    [_heartRateTimer invalidate];
    [_baby cancelNotify:self.bindingPeripheral.peripheral
         characteristic:self.FFF1characteristic];
    _writing = NO;
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
    if (_writing && self.isReadedPripheralAllData) {
        NSDictionary *dictionary = @{@"tag":@(BluetoothCallAlert)};
        [_bluetoothQueue addObject:dictionary];
        return;
    }
    NSInteger remindWay = [[[NSUserDefaults standardUserDefaults] objectForKey:callAlertOpen] integerValue];
    [self startTiming];
    
    _writing = YES;
    _tag = BluetoothCallAlert;
    
    Byte b[20];
    b[0] = 0xAA;
    b[1] = 0xE1;
    b[2] = remindWay;
    b[19] = [BluetoothManager calculateTotal:b];
    NSData *data = [NSData dataWithBytes:b length:sizeof(b)];
    [[BluetoothManager share] writeValue:data];
    
}

//设备防丢失开关
- (void)lostDevice:(BOOL)open {
    if (_writing && self.isReadedPripheralAllData) {
        NSDictionary *dictionary = @{@"tag":@(BluetoothLostDevice)};
        [_bluetoothQueue addObject:dictionary];
        return;
    }
    [self startTiming];
    
    _tag = BluetoothLostDevice;
    _writing = YES;
    
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
    
    _tag = BluetoothLostDevice;
    _writing = YES;
    
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
    
    _tag = BluetoothSetTimestamp;
    _writing = YES;
    
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
    if (_writing && self.isReadedPripheralAllData) {
        NSDictionary *dictionary = @{@"tag":@(BluetoothSetBasicInfomation),
                                    @"model":model};
        [_bluetoothQueue addObject:dictionary];
        return;
    }
    _writing = YES;
    _tag = BluetoothSetBasicInfomation;
    
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
    if (self.bindingPeripheral.peripheral && self.FFF1characteristic) {
        [self.bindingPeripheral.peripheral writeValue:data
                                    forCharacteristic:self.FFF1characteristic
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
    if (!_FFF1characteristic || !_isReadedPripheralAllData ) {
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
//        self.connectionType = BluetoothConnectingSuccess;
//        self.successType = BluetoothConnectingAllSuccess;
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


#pragma mark - new


@end
