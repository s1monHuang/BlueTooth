//
//  DDFileManager.m
//  DDInputToolBarDemo
//
//  Created by Ddread Li on 3/4/14.
//  Copyright (c) 2014 ddread. All rights reserved.
//

#import "DDFileManager.h"

@implementation DDFileManager


+ (void)storeImageWithDirectoryType:(DDSubDirectoryType)directoryType
                              image:(id)image
                           fileName:(NSString *)fileName
                       subDirectory:(NSString *)subDirectory
                      extensionType:(NSString *)extensionType
                           callBack:(void (^)(BOOL success, NSString *filePath))callBack
{
    if (!image) return;
    
     NSString *filePath = [DDFileManager getFilePathWithDirectoryType:directoryType subDirectory:subDirectory fileName:fileName extensionType:extensionType];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *data = nil;
        if ([image isKindOfClass:[NSData class]]) {
            data = image;
        }else if ([image isKindOfClass:[UIImage class]]){
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        
        if (data) {
            // Can't use defaultManager another thread
            NSFileManager *fileManager = NSFileManager.new;
            BOOL ret = [fileManager createFileAtPath:filePath contents:data attributes:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callBack) {
                    callBack(ret, filePath);
                }
            });
        }
    });
}

+ (NSString *)getFilePathWithDirectoryType:(DDSubDirectoryType)subDirectoryType
                              subDirectory:(NSString *)subDirectory
                                  fileName:(NSString *)fileName
                             extensionType:(NSString *)extensionType
{
    NSString *rootDirectory=[DDFileManager getSubDirectoryWithType:subDirectoryType];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (subDirectory) {
        rootDirectory = [rootDirectory stringByAppendingPathComponent:subDirectory];
        if (![fileManager fileExistsAtPath:rootDirectory]) {
            [fileManager createDirectoryAtPath:rootDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
        }
    }
    
    NSString *path = nil;
    if (extensionType) {
        path = [[rootDirectory stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:extensionType];
    } else {
        path = [rootDirectory stringByAppendingPathComponent:fileName];
    }
    
    return path;
}

+ (NSString *)getSubDirectoryWithType:(DDSubDirectoryType)type {
    
    NSString *subDirectoryPath = nil;
    switch (type) {
        case DDSubDirectoryTypeHome:
        {
            subDirectoryPath = NSHomeDirectory();
            break;
        }
        case DDSubDirectoryTypeDocuments:
        {
            subDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            break;
        }
        case DDSubDirectoryTypeTemp:
        {
            subDirectoryPath = NSTemporaryDirectory();
            break;
        }
            
        case DDSubDirectoryTypeCache:
        {
            subDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            break;
        }
            
        default:
            break;
    }
    
    return subDirectoryPath;
}

@end
