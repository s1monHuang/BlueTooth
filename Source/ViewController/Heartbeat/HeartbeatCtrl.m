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

@interface HeartbeatCtrl ()<PNChartDelegate> {
    UILabel *remindTextView;
}

@property (nonatomic) PNLineChart * lineChart;

@property (nonatomic) UILabel *lblHeartBeatNumber;
@property (nonatomic) UIButton *startButton;

@end

@implementation HeartbeatCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = BTLocalizedString(@"心率");
    self.view.backgroundColor = kThemeGrayColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLanguage:)
                                                 name:NOTIFY_CHANGE_LANGUAGE
                                               object:nil];
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
    _lblHeartBeatNumber.font = [UIFont boldSystemFontOfSize:18];
    _lblHeartBeatNumber.attributedText = [self attributeTextWithString:@"0"];
//    _lblHeartBeatNumber.text = [NSString stringWithFormat:@"0%@",BTLocalizedString(@"次/分钟")];
    
    _lblHeartBeatNumber.textAlignment = NSTextAlignmentCenter;
    _lblHeartBeatNumber.textColor = [UIColor blackColor];
    [self.view addSubview:_lblHeartBeatNumber];
    
    UIImageView *TipView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 150, SCREEN_WIDTH - 40, 10)];
    TipView.image = [UIImage imageNamed:@"scope"];
    [self.view addSubview:TipView];
    
    UILabel *lblNumber01 = [[UILabel alloc] initWithFrame:CGRectMake(20, 170, (SCREEN_WIDTH - 40)/3, 20)];
    lblNumber01.text = @"< 60";
    lblNumber01.font = [UIFont boldSystemFontOfSize:13];
    lblNumber01.textAlignment = NSTextAlignmentCenter;
    lblNumber01.textColor = [UIColor blackColor];
    [self.view addSubview:lblNumber01];
    
    UILabel *lblNumber02 = [[UILabel alloc] initWithFrame:CGRectMake(20+(SCREEN_WIDTH - 40)/3, 170, (SCREEN_WIDTH - 40)/3, 20)];
    lblNumber02.text = @" 60 - 90 ";
    lblNumber02.font = [UIFont boldSystemFontOfSize:13];
    lblNumber02.textAlignment = NSTextAlignmentCenter;
    lblNumber02.textColor = [UIColor blackColor];
    [self.view addSubview:lblNumber02];
    
    UILabel *lblNumber03 = [[UILabel alloc] initWithFrame:CGRectMake(20+(SCREEN_WIDTH - 40)/3*2, 170, (SCREEN_WIDTH - 40)/3, 20)];
    lblNumber03.text = @"> 90";
    lblNumber03.font = [UIFont boldSystemFontOfSize:13];
    lblNumber03.textAlignment = NSTextAlignmentCenter;
    lblNumber03.textColor = [UIColor blackColor];
    [self.view addSubview:lblNumber03];
    
    remindTextView = [[UILabel alloc] initWithFrame:CGRectMake(10,
                                                                              lblNumber03.height + lblNumber03.y + 100 ,
                                                                              SCREEN_WIDTH - 20,
                                                                              100)];
    remindTextView.backgroundColor = [UIColor clearColor];
    remindTextView.font = [UIFont systemFontOfSize:16];
    remindTextView.text = BTLocalizedString(@"运动后心率加快属正常现象,请不要担心.心率信息仅提供参考.");
    remindTextView.numberOfLines = 0;
    [self.view addSubview:remindTextView];

    _startButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  70,
                                                                  30)];
    [_startButton addTarget:self
                action:@selector(clickButton:)
      forControlEvents:UIControlEventTouchUpInside];
    [_startButton setTitle:BTLocalizedString(@"开始") forState:UIControlStateNormal];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:_startButton];
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickButton:(UIButton *)button {
    //没有绑定设备
    if (![BluetoothManager getBindingPeripheralUUID]) {
        [MBProgressHUD showHUDByContent:BTLocalizedString(@"您尚未绑定设备") view:UI_Window afterDelay:1.5];
        return;
    }
    if (![[BluetoothManager share] isExistCharacteristic]) {
        [MBProgressHUD showHUDByContent:BTLocalizedString(@"设备自动连接中，请稍后") view:UI_Window afterDelay:1.5];
        return;
    }
    if (button.selected) {
        [button setTitle:BTLocalizedString(@"开始") forState:UIControlStateNormal];
        [[BluetoothManager share] closeReadHeartRate];
        [MBProgressHUD hideHUDForView:self.view
                             animated:YES];
    } else {
        [button setTitle:BTLocalizedString(@"取消") forState:UIControlStateNormal];
        [[BluetoothManager share] readHeartRate];
        [MBProgressHUD showHUDByContent:BTLocalizedString(@"测定心率中…")
                                   view:self.view
                             afterDelay:INT_MAX];
    }
    button.selected = !button.selected;
}

- (void)readHeartRateSuccess {
    NSString *rateStr = [NSString stringWithFormat:@"%@",@([BluetoothManager share].heartRate).stringValue];
    _lblHeartBeatNumber.attributedText = [self attributeTextWithString:rateStr];
//    _lblHeartBeatNumber.text = [NSString stringWithFormat:@"%@%@",@([BluetoothManager share].heartRate).stringValue,BTLocalizedString(@"次/分钟")];
}

- (void)readHeartRateFinished {
    [_startButton setTitle:BTLocalizedString(@"开始") forState:UIControlStateNormal];
    [MBProgressHUD hideHUDForView:self.view
                         animated:YES];
}

- (void)disConnectPeripheral {
    [_startButton setTitle:BTLocalizedString(@"开始") forState:UIControlStateNormal];
    [MBProgressHUD hideHUDForView:self.view
                         animated:YES];
}

- (void)changeLanguage:(NSNotification *)notification {
    self.title = BTLocalizedString(@"心率");
//    if (_startButton.selected) {
        [_startButton setTitle:BTLocalizedString(@"开始") forState:UIControlStateNormal];
//    } else {
//        [_startButton setTitle:BTLocalizedString(@"取消") forState:UIControlStateNormal];
//    }
    NSString *rateStr = [NSString stringWithFormat:@"%@",@([BluetoothManager share].heartRate).stringValue];
    _lblHeartBeatNumber.attributedText = [self attributeTextWithString:rateStr];
    remindTextView.text = BTLocalizedString(@"运动后心率加快属正常现象,请不要担心.心率信息仅提供参考.");
}

- (NSMutableAttributedString *)attributeTextWithString:(NSString *)string
{
    if (string.length > 0) {
        NSRange range = NSMakeRange(0, string.length);
        NSMutableAttributedString *textString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",string,BTLocalizedString(@"次/分钟")]];
        [textString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:36]} range:range];
        return textString;
    }else{
        NSRange range = NSMakeRange(0, 1);
        NSMutableAttributedString *textString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"0 %@",BTLocalizedString(@"次/分钟")]];
        [textString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:36]} range:range];
        return textString;
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
