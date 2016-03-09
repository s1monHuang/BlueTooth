//
//  RankingEntity.h
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/3.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RankingEntity : NSObject

@property (nonatomic,strong) NSString *UserID;
@property (nonatomic,strong) NSString *headerPicFileName;
@property (nonatomic,strong) NSString *RankNo;
@property (nonatomic,strong) NSString *RankName;
@property (nonatomic,strong) NSString *StepNumber;

- (instancetype)initRankingEntityWithDic:(NSDictionary *)dict;

@end
