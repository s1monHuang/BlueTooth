//
//  RankingCell.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/3.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "RankingCell.h"
#import "RankingEntity.h"

@interface RankingCell ()
@property (weak, nonatomic) IBOutlet UILabel *lblRankNo;
@property (weak, nonatomic) IBOutlet UIImageView *rankNoimg;
@property (weak, nonatomic) IBOutlet UILabel *lblRankName;
@property (weak, nonatomic) IBOutlet UILabel *lblStepNumber;
@property (weak, nonatomic) IBOutlet UIImageView *ismeimg;

@end

@implementation RankingCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)configRankingCell:(RankingEntity *)rankEntity rankNo:(NSInteger)row
{
    switch (row) {
        case 1:
        {
            self.lblRankNo.hidden = YES;
            self.rankNoimg.image = [UIImage imageNamed:@"goldmedal"];
        }
            break;
        case 2:
        {
            self.lblRankNo.hidden = YES;
            self.rankNoimg.image = [UIImage imageNamed:@"silvermedal"];
        }
            break;
        case 3:
        {
            self.lblRankNo.hidden = YES;
            self.rankNoimg.image = [UIImage imageNamed:@"bronzemedal"];
        }
            break;
        case 4:
        {
            self.lblRankNo.hidden = NO;
            self.lblRankNo.text = @"4";
            self.rankNoimg.hidden = YES;
        }
            break;
        case 5:
        {
            self.lblRankNo.hidden = NO;
            self.lblRankNo.text = @"5";
            self.rankNoimg.hidden = YES;
            self.ismeimg.image = [UIImage imageNamed:@"me"];
        }
            break;
        default:
            break;
    }
    
    self.lblRankName.text = rankEntity.userName;
    self.lblStepNumber.text = [NSString stringWithFormat:@"%@步",rankEntity.sumSteps];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
