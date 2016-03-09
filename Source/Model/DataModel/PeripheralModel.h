//
//  PeripheralModel.h
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/9.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PeripheralModel : NSObject

@property (nonatomic,strong)CBPeripheral *peripheral;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSArray<CBUUID *> *UUIDs;

@property (nonatomic,assign)NSInteger connectable;
@property (nonatomic,assign)NSInteger level;


- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                 advertisementData:(NSDictionary *)advertisementData;

@end
