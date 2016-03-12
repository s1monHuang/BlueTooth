//
//  DataStoreHelper.h
//  MobileDoctor
//
//  Created by Ddread Li on 6/5/15.
//  Copyright (c) 2015 DCS Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKKeyValueStore.h"
#import "PeripheralModel.h"
#import "BluetoothManager.h"

#define DStoreHelper  [DataStoreHelper store]

extern NSString *const TBNameUser; // 用户表
extern NSString *const TBKeyUserInfo; // 用户个人信息

@interface DataStoreHelper : NSObject

+ (YTKKeyValueStore *)store;
+ (void)clearAllTable;

+ (BOOL)isBindingPeripheral:(CBPeripheral *)peripheral
          advertisementData:(NSDictionary *)advertisementData;

@end
