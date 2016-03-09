//
//  RankingEntity.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/3.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "RankingEntity.h"

@implementation RankingEntity

- (instancetype)initRankingEntityWithDic:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.UserID = [NSString stringWithFormat:@"%@",dict[@"UserID"]];
        self.headerPicFileName = [NSString stringWithFormat:@"%@",dict[@"headerPicFileName"]];
        self.RankNo = [NSString stringWithFormat:@"%@",dict[@"RankNo"]];
        self.RankName = [NSString stringWithFormat:@"%@",dict[@"RankName"]];
        self.StepNumber = [NSString stringWithFormat:@"%@",dict[@"StepNumber"]];
    }
    return self;
}

@end
