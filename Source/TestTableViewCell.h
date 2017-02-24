//
//  TestTableViewCell.h
//  tztsockettest
//
//  Created by Hsn on 2017/2/16.
//  Copyright © 2017年 com.tzt.monitor. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestTableViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *stepLabel;
@property (retain, nonatomic) IBOutlet UILabel *sleepLabel;

@end
