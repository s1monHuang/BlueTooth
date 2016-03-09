//
//  PeripheralModel.m
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/9.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "PeripheralModel.h"

@implementation PeripheralModel

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData
{
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        _connectable = [[advertisementData objectForKey:@"kCBAdvDataIsConnectable"] integerValue];
        _name = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
        _UUIDs = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
        _level = [[advertisementData objectForKey:@"kCBAdvDataTxPowerLevel"] integerValue];
    }
    return self;
}


@end
