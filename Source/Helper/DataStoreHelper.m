//
//  DataStoreHelper.m
//  MobileDoctor
//
//  Created by Ddread Li on 6/5/15.
//  Copyright (c) 2015 DCS Technology. All rights reserved.
//

#import "DataStoreHelper.h"
#import "DDFileManager.h"

NSString *const TBNameUser = @"tb_user";
NSString *const TBKeyUserInfo = @"TBKeyUserInfo";

static YTKKeyValueStore *keyValueStore;

@implementation DataStoreHelper

+ (void)initialize {
    NSString *path = [self defaultDBPathWithName:nil];
    keyValueStore = [[YTKKeyValueStore alloc] initWithDBWithPath:path];
    [keyValueStore createTableWithName:TBNameUser];
}

+ (YTKKeyValueStore *)store {
    return keyValueStore;
}

+ (void)clearAllTable {
    [keyValueStore clearTable:TBNameUser];
}

+ (BOOL)savePeripheral:(PeripheralModel *)model {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:model.name forKey:@"peripheralName"];
    [defaults setObject:@(model.connectable) forKey:@"peripheralConnectable"];
    [defaults setObject:model.UUIDs forKey:@"peripheralUUIDs"];
    [defaults setObject:@(model.level) forKey:@"peripheralLevel"];
    [defaults setObject:@(YES) forKey:@"isbindingPeripheral"];
    return [defaults synchronize];
}

+ (PeripheralModel *)getPeripheral {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    PeripheralModel *model = [[PeripheralModel alloc] init];
    model.name = [defaults objectForKey:@"peripheralName"];
    model.connectable = [[defaults objectForKey:@"peripheralConnectable"] integerValue];
    model.UUIDs = [defaults objectForKey:@"peripheralUUIDs"];
    model.level = [[defaults objectForKey:@"peripheralLevel"] integerValue];
    return model;
}

+ (BOOL)isBindingPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData {
    PeripheralModel *model = [[PeripheralModel alloc] initWithPeripheral:peripheral
                                                       advertisementData:advertisementData];
    PeripheralModel *bindingModel = [BluetoothManager share].bindingPeripheral;
    
    BOOL isBingdingPeripheral = NO;
    
    //如果设备名,connectable,level,UUIDs都一样,则代表是同一台设备
    if ([model.name isEqualToString:bindingModel.name] &&
        model.connectable == bindingModel.connectable &&
        model.level == bindingModel.level &&
        model.UUIDs.count == bindingModel.UUIDs.count) {
        
        for (NSInteger i = 0 ; i < bindingModel.UUIDs.count; i ++ ) {
            NSString *bindingUUID = [bindingModel.UUIDs objectAtIndex:i];
            NSString *uuid = [model.UUIDs objectAtIndex:i];
            if (![bindingUUID isEqualToString:uuid]) {
                isBingdingPeripheral = NO;
                break;
            } else {
                isBingdingPeripheral = YES;
            }
        }
    }
    return isBingdingPeripheral;
}

#pragma mark -

#define kDBDocumentSubDirectory              @"DataBase"
#define kDBDefaultName                       @"com.dachen.DGroupDoctor.sqlite.db"

+ (NSString *)defaultDBPathWithName:(NSString *)name {
    NSString *ret = [DDFileManager getFilePathWithDirectoryType:DDSubDirectoryTypeDocuments subDirectory:kDBDocumentSubDirectory fileName:name ?: kDBDefaultName extensionType:nil];
    NSLog(@"db path:%@", ret);
    return ret;
}

@end
