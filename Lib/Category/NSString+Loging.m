//
//  NSString+Loging.m
//  MobileDoctor
//
//  Created by Ddread Li on 6/11/15.
//  Copyright (c) 2015 DCS Technology. All rights reserved.
//

#import "NSString+Loging.h"

@implementation NSString (Loging)

- (NSString *)logUTF8String {
    
    NSString *tempStr = [self stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    tempStr = [tempStr stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    tempStr = [[@"\"" stringByAppendingString:tempStr] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString* returnStr = [NSPropertyListSerialization propertyListFromData:tempData
                                                           mutabilityOption:NSPropertyListImmutable
                                                                     format:NULL
                                                           errorDescription:NULL];
    return returnStr;
}
@end
