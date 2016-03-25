//
//  UserEntity.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/5.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "UserEntity.h"

@implementation UserEntity

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{@"userId" : @"userId",
             @"passwd" : @"passwd",
             @"realName" : @"realName",
             @"token" : @"token",
             @"_tk" : @"_tk",
             @"phone" : @"phone",
             @"departments" : @"departments",
             @"doctorNum" : @"doctorNum",
             @"hospital" : @"hospital",
             @"title" : @"title",
             @"qrImageUrl" : @"qrImageUrl",
             @"skill" : @"skill",
             @"introduction" : @"introduction",
             @"entryTime" : @"entryTime",
             @"sex" : @"sex",
             @"status" : @"status",
             @"headPortraitName" : @"headPortraitName",
             @"cerImageUrls" : @"cerImageUrls",
             @"needToVerifyPatient" : @"needToVerifyPatient",
             @"needToVerifyFrient" : @"needToVerifyFrient",
             @"needReceiveNotifi" : @"needReceiveNotifi",
             @"needMsgDetail" : @"needMsgDetail",
             @"hospitalId" : @"hospitalId",
             @"voipInfo" : @"voipInfo"
             };
}

- (instancetype)initUserEntityWithDic:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.userId = [NSString stringWithFormat:@"%@",dict[@"id"]];
        self.password = [NSString stringWithFormat:@"%@",dict[@"password"]];
        self.nickName = [NSString stringWithFormat:@"%@",dict[@"nickName"]];
        self.mobile = [NSString stringWithFormat:@"%@",dict[@"mobile"]];
        self.high = [NSString stringWithFormat:@"%@",dict[@"high"]];
        self.ex_deviceId = [NSString stringWithFormat:@"%@",dict[@"ex_deviceId"]];
        self.sex = [NSString stringWithFormat:@"%@",dict[@"sex"]];
        self.stepLong = [NSString stringWithFormat:@"%@",dict[@"stepLong"]];
        self.weight = [NSString stringWithFormat:@"%@",dict[@"weight"]];
        self.high = [NSString stringWithFormat:@"%@",dict[@"high"]];
        self.deviceId = [NSString stringWithFormat:@"%@",dict[@"deviceId"]];
        self.age = [NSString stringWithFormat:@"%@",dict[@"age"]];
        self.token = [NSString stringWithFormat:@"%@",dict[@"token"]];
        self.inviteCode = [NSString stringWithFormat:@"%@",dict[@"inviteCode"]];
    }
    return self;
}

@end
