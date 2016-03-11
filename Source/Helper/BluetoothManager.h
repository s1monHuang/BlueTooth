//
//  BluetoothManager.h
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/9.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyBluetooth.h"

@protocol BluetoothManagerDelegate <NSObject>

- (void)didSearchPeripheral:(CBPeripheral *)peripheral
          advertisementData:(NSDictionary *)advertisementData;

- (void)didBindingPeripheral:(BOOL)success;

@end

@interface BluetoothManager : NSObject {
    BabyBluetooth *_baby;
}

@property (strong, nonatomic) BabyBluetooth *baby;
@property (strong, nonatomic) PeripheralModel *selecedPeripheral;
@property (assign, nonatomic) id<BluetoothManagerDelegate> deleagete;

@property (assign, nonatomic) BOOL isBindingPeripheral;         //是否绑定过蓝牙设备

@property (nonatomic,strong) PeripheralModel *bindingPeripheral;

@property (nonatomic,strong) CBCharacteristic *characteristics;

+ (BluetoothManager *)share;

- (void)start;

- (void)stop;

- (void)connectingBlueTooth:(CBPeripheral *)peripheral;

- (void)startBindingPeripheral;

- (void)confirmBindingPeripheral;

- (void)clearBindingPeripheral;

@end
