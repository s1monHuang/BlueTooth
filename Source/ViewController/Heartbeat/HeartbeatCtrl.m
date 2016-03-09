//
//  HeartbeatCtrl.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/2.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "HeartbeatCtrl.h"
#import "PNChartDelegate.h"
#import "PNChart.h"

@interface HeartbeatCtrl ()<PNChartDelegate>

@property (nonatomic) PNLineChart * lineChart;

@end

@implementation HeartbeatCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"心跳";
    self.view.backgroundColor = kThemeGrayColor;
    
    UILabel *lblHeartBeatNumber = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, ScreenWidth - 40, 30)];
    lblHeartBeatNumber.text = @"83次/分钟";
    lblHeartBeatNumber.font = [UIFont boldSystemFontOfSize:30];
    lblHeartBeatNumber.textAlignment = NSTextAlignmentCenter;
    lblHeartBeatNumber.textColor = [UtilityUI stringTOColor:@"#a4a9ad"];
    [self.view addSubview:lblHeartBeatNumber];
    
    UIImageView *TipView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 70, SCREEN_WIDTH - 40, 10)];
    TipView.image = [UIImage imageNamed:@"scope"];
    [self.view addSubview:TipView];
    
    UILabel *lblNumber01 = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, (SCREEN_WIDTH - 40)/3, 20)];
    lblNumber01.text = @"< 60";
    lblNumber01.font = [UIFont boldSystemFontOfSize:13];
    lblNumber01.textAlignment = NSTextAlignmentCenter;
    lblNumber01.textColor = [UtilityUI stringTOColor:@"#a4a9ad"];
    [self.view addSubview:lblNumber01];
    
    UILabel *lblNumber02 = [[UILabel alloc] initWithFrame:CGRectMake(20+(SCREEN_WIDTH - 40)/3, 90, (SCREEN_WIDTH - 40)/3, 20)];
    lblNumber02.text = @" 60 - 90 ";
    lblNumber02.font = [UIFont boldSystemFontOfSize:13];
    lblNumber02.textAlignment = NSTextAlignmentCenter;
    lblNumber02.textColor = [UtilityUI stringTOColor:@"#a4a9ad"];
    [self.view addSubview:lblNumber02];
    
    UILabel *lblNumber03 = [[UILabel alloc] initWithFrame:CGRectMake(20+(SCREEN_WIDTH - 40)/3*2, 90, (SCREEN_WIDTH - 40)/3, 20)];
    lblNumber03.text = @"> 90";
    lblNumber03.font = [UIFont boldSystemFontOfSize:13];
    lblNumber03.textAlignment = NSTextAlignmentCenter;
    lblNumber03.textColor = [UtilityUI stringTOColor:@"#a4a9ad"];
    [self.view addSubview:lblNumber03];
    
    UIView *chartBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 130, SCREEN_WIDTH, 260)];
    chartBgView.backgroundColor = [UtilityUI stringTOColor:@"#353e47"];
    [self.view addSubview:chartBgView];
    
    self.lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 60.0, SCREEN_WIDTH, 200.0)];
    self.lineChart.yLabelFormat = @"%1.1f";
    self.lineChart.backgroundColor = [UIColor clearColor];
    [self.lineChart setXLabelColor:[UIColor whiteColor]];
    [self.lineChart setXLabels:@[@"0",@"6",@"12",@"18",@"24"]];
    self.lineChart.showCoordinateAxis = NO;
    self.lineChart.yFixedValueMax = 150.0;
    self.lineChart.yFixedValueMin = 0.0;
    [self.lineChart setYLabelColor:[UIColor whiteColor]];
    [self.lineChart setYLabels:@[
                                 @"0",
                                 @"60",
                                 @"90",
                                 @"120",
                                 @"150",
                                 ]
     ];
    
    
    NSArray * dataArray = @[@139.1, @60.1, @26.4, @86.2, @86.2];
    PNLineChartData *data = [PNLineChartData new];
    data.dataTitle = @"Beta";
    data.color = PNTwitterColor;
    data.alpha = 0.8f;
    data.itemCount = dataArray.count;
    data.inflexionPointStyle = PNLineChartPointStyleCircle;
    data.getData = ^(NSUInteger index) {
        CGFloat yValue = [dataArray[index] floatValue];
        return [PNLineChartDataItem dataItemWithY:yValue];
    };
    self.lineChart.chartData = @[data];
    [self.lineChart strokeChart];
    self.lineChart.delegate = self;
    [chartBgView addSubview:self.lineChart];
    
    CGFloat lineWidth = 0;
    if(Iphone5Screen)
        lineWidth = 202;
    if(Iphone6Screen)
        lineWidth = 250;
    if(Iphone6PScreen)
        lineWidth = 276;
    
    UIImageView *line01Box = [[UIImageView alloc] initWithFrame:CGRectMake(75,203, lineWidth, 1)];
    line01Box.image = [UIImage imageNamed:@"line-dotted"];
    [self.view addSubview:line01Box];
    
    UIImageView *line02Box = [[UIImageView alloc] initWithFrame:CGRectMake(75,263, lineWidth, 1)];
    line02Box.image = [UIImage imageNamed:@"line-dotted"];
    [self.view addSubview:line02Box];
    
    UIImageView *line03Box = [[UIImageView alloc] initWithFrame:CGRectMake(75,293, lineWidth, 1)];
    line03Box.image = [UIImage imageNamed:@"line-dotted"];
    [self.view addSubview:line03Box];
    
    UIImageView *lineBox = [[UIImageView alloc] initWithFrame:CGRectMake(75,293+30, lineWidth, 1)];
    lineBox.image = [UIImage imageNamed:@"line"];
    [self.view addSubview:lineBox];
    
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
