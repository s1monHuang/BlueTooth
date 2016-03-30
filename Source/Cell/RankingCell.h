//
//  RankingCell.h
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/3.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RankingEntity;

@interface RankingCell : UITableViewCell

- (void)configRankingCell:(RankingEntity *)rankEntity rankNo:(NSInteger)row;

@end
