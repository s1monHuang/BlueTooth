//
//  SleepCtrl.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/2.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "SleepCtrl.h"
#import "PNCircleChart.h"

@interface SleepCtrl ()

@property (strong,nonatomic) UIView *chartView;
@property (strong,nonatomic) UIView *circleBgView;

@property (strong,nonatomic) UIView *footerView;

@property (nonatomic) PNCircleChart * circleChart;


@end

@implementation SleepCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"睡眠";
    self.view.backgroundColor = kThemeGrayColor;
    
    _chartView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 200)];
    _chartView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_chartView];
    
    _circleBgView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, (_chartView.frame.size.width - 100), (_chartView.frame.size.width - 100))];
    _circleBgView.backgroundColor = [UIColor clearColor];
    [_chartView addSubview:_circleBgView];
    
    self.circleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(50,50.0, _circleBgView.frame.size.width, _circleBgView.frame.size.height)
                                                      total:@100
                                                    current:@68
                                                  clockwise:YES shadow:YES shadowColor:[UtilityUI stringTOColor:@"#6dabff"]];
    
    self.circleChart.backgroundColor = [UIColor clearColor];
    self.circleChart.lineWidth = @20;
    self.circleChart.lineCap = @"kCALineCapButt";
    [self.circleChart setStrokeColor:[UtilityUI stringTOColor:@"#1b6cff"]];
    //[self.circleChart setStrokeColorGradientStart:[UIColor clearColor]];
    [self.circleChart strokeChart];
    [_chartView addSubview:self.circleChart];
    
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(26, 26, self.circleChart.frame.size.width - 52, self.circleChart.frame.size.width - 52)];
    tempView.contentMode = UIViewContentModeScaleAspectFill;
    tempView.clipsToBounds = YES;
    [tempView.layer setCornerRadius:CGRectGetHeight([tempView bounds])/2];
    tempView.layer.masksToBounds = YES;
    tempView.backgroundColor = [UIColor whiteColor];
    [_circleChart addSubview:tempView];
    
    UILabel *sleepTimeText = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 50 - 22*2)/2,tempView.frame.size.width, 20)];
    sleepTimeText.text = @"睡眠时长";
    sleepTimeText.textAlignment = NSTextAlignmentCenter;
    sleepTimeText.textColor = [UIColor blackColor];
    [tempView addSubview:sleepTimeText];
    
    UILabel *sleepTimeValue = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 50 - 22*2)/2+32,tempView.frame.size.width, 20)];
    sleepTimeValue.text = @"7小时23分钟";
    sleepTimeValue.textAlignment = NSTextAlignmentCenter;
    sleepTimeValue.textColor = [UIColor blackColor];
    [tempView addSubview:sleepTimeValue];
    
    UILabel *ssleepTimeValue = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 50 - 22*2)/2+32+30,tempView.frame.size.width, 20)];
    ssleepTimeValue.text = @"★深睡4小时03分钟";
    ssleepTimeValue.font = [UIFont systemFontOfSize:12];
    ssleepTimeValue.textAlignment = NSTextAlignmentCenter;
    ssleepTimeValue.textColor = [UIColor blackColor];
    [tempView addSubview:ssleepTimeValue];
    
    UILabel *qsleepTimeValue = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 50 - 22*2)/2+32+50,tempView.frame.size.width, 20)];
    qsleepTimeValue.text = @"☆浅睡3小时20分钟";
    qsleepTimeValue.font = [UIFont systemFontOfSize:12];
    qsleepTimeValue.textAlignment = NSTextAlignmentCenter;
    qsleepTimeValue.textColor = [UIColor blackColor];
    [tempView addSubview:qsleepTimeValue];
    
    UIImageView *threeBox = [[UIImageView alloc] initWithFrame:CGRectMake(10, ScreenHeight - 148 - 108, ScreenWidth - 20, 108)];
    threeBox.backgroundColor = [UIColor blackColor];
    [self.view addSubview:threeBox];
    
    UIImageView *startSleep = [[UIImageView alloc] initWithFrame:CGRectMake(10, threeBox.frame.origin.y+threeBox.frame.size.height+10, 14, 14)];
    startSleep.image = [UIImage imageNamed:@"moon"];
    [self.view addSubview:startSleep];
    
    UILabel *startSleepTime = [[UILabel alloc] initWithFrame:CGRectMake(30, threeBox.frame.origin.y+threeBox.frame.size.height+7,60, 20)];
    startSleepTime.text = @"23:20";
    startSleepTime.font = [UIFont systemFontOfSize:13];
    startSleepTime.textAlignment = NSTextAlignmentLeft;
    startSleepTime.textColor = [UIColor blackColor];
    [self.view addSubview:startSleepTime];
    
    
    UIImageView *endSleep = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 10 - 15, threeBox.frame.origin.y+threeBox.frame.size.height+10, 14, 14)];
    endSleep.image = [UIImage imageNamed:@"sun"];
    [self.view addSubview:endSleep];
    
    UILabel *endSleepTime = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth - 10 - 15 - 66, threeBox.frame.origin.y+threeBox.frame.size.height+7,60, 20)];
    endSleepTime.text = @"7:03";
    endSleepTime.font = [UIFont systemFontOfSize:13];
    endSleepTime.textAlignment = NSTextAlignmentRight;
    endSleepTime.textColor = [UIColor blackColor];
    [self.view addSubview:endSleepTime];
    
    CGFloat boxWidth = (ScreenWidth - 30)/12;
    
    for (int i = 0; i < 12; i++) {
        
        UIView *boxView = [[UIView alloc] initWithFrame:CGRectMake(5+boxWidth*i, i%2==0?20:64, boxWidth, i%2==0?88:44)];
        boxView.backgroundColor = i%2==0?[UtilityUI stringTOColor:@"#1b6cff"]:[UtilityUI stringTOColor:@"#6dabff"];
        
        [threeBox addSubview:boxView];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
