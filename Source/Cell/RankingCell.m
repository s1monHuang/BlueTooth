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
@property (nonatomic , strong) UILabel *lblStepNumber;
@property (nonatomic , strong) UIImageView *ismeimg;


@end

@implementation RankingCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)configRankingCell:(RankingEntity *)rankEntity rankNo:(NSInteger)row
{
    self.lblRankName.text = rankEntity.userName;
    
    self.lblStepNumber = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 170, 15, 150, 25)];
    self.lblStepNumber.textAlignment = NSTextAlignmentRight;
    NSRange StepDataRange = NSMakeRange(0, rankEntity.sumSteps.length);
    NSMutableAttributedString *StepDataString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",rankEntity.sumSteps,BTLocalizedString(@"步")]];
    
    if ([rankEntity.userId isEqualToString:CurrentUser.userId]) {
        self.ismeimg = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 25, 3, 12, 12)];
        NSString *imageName = BTLocalizedString(@"me");
        self.ismeimg.image = [UIImage imageNamed:imageName];
        [self.contentView addSubview:self.ismeimg];[StepDataString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:22],NSForegroundColorAttributeName:[UIColor orangeColor]}
                                                                           range:StepDataRange];
    }else{
        self.ismeimg.hidden = YES;
        [StepDataString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:22],NSForegroundColorAttributeName:[UIColor blackColor]}
                                                          range:StepDataRange];
    }
    self.lblStepNumber.attributedText = StepDataString;
    [self.contentView addSubview:self.lblStepNumber];
//    CGFloat lblRankNameW = kScreenWidth - _lblStepNumber.x;
//    _lblRankName.width = lblRankNameW;

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

            
        }
            break;
        default:
            break;
    }
 }

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
