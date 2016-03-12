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

#pragma mark -

#define kDBDocumentSubDirectory              @"DataBase"
#define kDBDefaultName                       @"com.dachen.DGroupDoctor.sqlite.db"

+ (NSString *)defaultDBPathWithName:(NSString *)name {
    NSString *ret = [DDFileManager getFilePathWithDirectoryType:DDSubDirectoryTypeDocuments subDirectory:kDBDocumentSubDirectory fileName:name ?: kDBDefaultName extensionType:nil];
    NSLog(@"db path:%@", ret);
    return ret;
}

@end
