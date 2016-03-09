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
        _name = peripheral.name;
        NSArray *uuids = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
        _level = [[advertisementData objectForKey:@"kCBAdvDataTxPowerLevel"] integerValue];
        NSMutableArray *uuidStringArray = [[NSMutableArray alloc] init];
        for (CBUUID *uuid in uuids) {
            [uuidStringArray addObject:uuid.UUIDString];
        }
        _UUIDs = [[NSArray alloc] initWithArray:uuidStringArray];
    }
    return self;
}




@end
