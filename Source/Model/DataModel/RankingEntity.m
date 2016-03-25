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
        self.userId = [NSString stringWithFormat:@"%@",dict[@"userId"]];
//        self.headerPicFileName = [NSString stringWithFormat:@"%@",dict[@"headerPicFileName"]];
//        self.RankNo = [NSString stringWithFormat:@"%@",dict[@"RankNo"]];
        self.userName = [NSString stringWithFormat:@"%@",dict[@"userName"]];
        self.sumSteps = [NSString stringWithFormat:@"%@",dict[@"sumSteps"]];
    }
    return self;
}

@end
