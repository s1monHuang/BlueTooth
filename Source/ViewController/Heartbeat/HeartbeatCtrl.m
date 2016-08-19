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

@property (nonatomic) UILabel *lblHeartBeatNumber;
@property (nonatomic) UIButton *button;

@end

@implementation HeartbeatCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"心率", nil);
    self.view.backgroundColor = kThemeGrayColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readHeartRateSuccess)
                                                 name:READ_HEARTRATE_SUCCESS
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disConnectPeripheral)
                                                 name:DISCONNECT_PERIPHERAL
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readHeartRateFinished)
                                                 name:READ_HEARTRATE_FINISHED
                                               object:nil];
    
    _lblHeartBeatNumber = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, ScreenWidth - 40, 30)];
    _lblHeartBeatNumber.text = [NSString stringWithFormat:@"0%@",NSLocalizedString(@"次/分钟", nil)];
    _lblHeartBeatNumber.font = [UIFont boldSystemFontOfSize:30];
    _lblHeartBeatNumber.textAlignment = NSTextAlignmentCenter;
    _lblHeartBeatNumber.textColor = [UtilityUI stringTOColor:@"#a4a9ad"];
    [self.view addSubview:_lblHeartBeatNumber];
    
    UIImageView *TipView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 150, SCREEN_WIDTH - 40, 10)];
    TipView.image = [UIImage imageNamed:@"scope"];
    [self.view addSubview:TipView];
    
    UILabel *lblNumber01 = [[UILabel alloc] initWithFrame:CGRectMake(20, 170, (SCREEN_WIDTH - 40)/3, 20)];
    lblNumber01.text = @"< 60";
    lblNumber01.font = [UIFont boldSystemFontOfSize:13];
    lblNumber01.textAlignment = NSTextAlignmentCenter;
    lblNumber01.textColor = [UtilityUI stringTOColor:@"#a4a9ad"];
    [self.view addSubview:lblNumber01];
    
    UILabel *lblNumber02 = [[UILabel alloc] initWithFrame:CGRectMake(20+(SCREEN_WIDTH - 40)/3, 170, (SCREEN_WIDTH - 40)/3, 20)];
    lblNumber02.text = @" 60 - 90 ";
    lblNumber02.font = [UIFont boldSystemFontOfSize:13];
    lblNumber02.textAlignment = NSTextAlignmentCenter;
    lblNumber02.textColor = [UtilityUI stringTOColor:@"#a4a9ad"];
    [self.view addSubview:lblNumber02];
    
    UILabel *lblNumber03 = [[UILabel alloc] initWithFrame:CGRectMake(20+(SCREEN_WIDTH - 40)/3*2, 170, (SCREEN_WIDTH - 40)/3, 20)];
    lblNumber03.text = @"> 90";
    lblNumber03.font = [UIFont boldSystemFontOfSize:13];
    lblNumber03.textAlignment = NSTextAlignmentCenter;
    lblNumber03.textColor = [UtilityUI stringTOColor:@"#a4a9ad"];
    [self.view addSubview:lblNumber03];
    
    UILabel *remindTextView = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                                              lblNumber03.height + lblNumber03.y + 100 ,
                                                                              SCREEN_WIDTH - 20,
                                                                              50)];
    remindTextView.backgroundColor = [UIColor clearColor];
    remindTextView.font = [UIFont systemFontOfSize:16];
    remindTextView.text = NSLocalizedString(@"运动后心率加快属正常现象,请不要担心.心率信息仅提供参考.", nil);
    remindTextView.numberOfLines = 0;
    [self.view addSubview:remindTextView];

    _button = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  50,
                                                                  30)];
    [_button setTitle:NSLocalizedString(@"开始", nil) forState:UIControlStateNormal];
    [_button addTarget:self
               action:@selector(clickButton:)
     forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:_button];
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickButton:(UIButton *)button {
    //没有绑定设备
    if (![BluetoothManager getBindingPeripheralUUID]) {
        [MBProgressHUD showHUDByContent:NSLocalizedString(@"您尚未绑定设备", nil) view:UI_Window afterDelay:1.5];
        return;
    }
    if (![[BluetoothManager share] isExistCharacteristic]) {
        [MBProgressHUD showHUDByContent:NSLocalizedString(@"设备自动连接中，请稍后", nil) view:UI_Window afterDelay:1.5];
        return;
    }
    if (button.selected) {
        [button setTitle:NSLocalizedString(@"开始", nil) forState:UIControlStateNormal];
        [[BluetoothManager share] closeReadHeartRate];
        [MBProgressHUD hideHUDForView:self.view
                             animated:YES];
    } else {
        [button setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        [[BluetoothManager share] readHeartRate];
        [MBProgressHUD showHUDByContent:NSLocalizedString(@"测定心率中…", nil)
                                   view:self.view
                             afterDelay:INT_MAX];
    }
    button.selected = !button.selected;
}

- (void)readHeartRateSuccess {
    _lblHeartBeatNumber.text = [NSString stringWithFormat:@"%@%@",@([BluetoothManager share].heartRate).stringValue,NSLocalizedString(@"次/分钟", nil)];
}

- (void)readHeartRateFinished {
    [_button setTitle:NSLocalizedString(@"开始", nil) forState:UIControlStateNormal];
    [MBProgressHUD hideHUDForView:self.view
                         animated:YES];
}

- (void)disConnectPeripheral {
    [_button setTitle:NSLocalizedString(@"开始", nil) forState:UIControlStateNormal];
    [MBProgressHUD hideHUDForView:self.view
                         animated:YES];
}


@end
