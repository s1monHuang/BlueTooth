//
//  DDFileManager.h
//  DDInputToolBarDemo
//
//  Created by Ddread Li on 3/4/14.
//  Copyright (c) 2014 ddread. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DDSubDirectoryType){
    DDSubDirectoryTypeHome,
    DDSubDirectoryTypeDocuments,
    DDSubDirectoryTypeTemp,
    DDSubDirectoryTypeCache,
};

@interface DDFileManager : NSObject

// 建立子文件夹和文件路径
+ (NSString *)getFilePathWithDirectoryType:(DDSubDirectoryType)subDirectoryType
                              subDirectory:(NSString *)subDirectory
                                  fileName:(NSString *)fileName
                             extensionType:(NSString *)extensionType;

// 异步保存图片到子文件夹
+ (void)storeImageWithDirectoryType:(DDSubDirectoryType)directoryType
                              image:(id)image
                           fileName:(NSString *)fileName
                       subDirectory:(NSString *)subDirectory
                      extensionType:(NSString *)extensionType
                           callBack:(void (^)(BOOL success, NSString *filePath))callBack;


@end
