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
#import "SportDataModel.h"

@interface HeartbeatCtrl ()<PNChartDelegate> {
    UILabel *remindTextView;
}

@property (nonatomic) PNLineChart * lineChart;

@property (nonatomic) UILabel *lblHeartBeatNumber;
@property (nonatomic) UIButton *startButton;

@property (nonatomic , strong) UIImageView *heatRateImageView;

@property (nonatomic , strong) NSTimer *heatRateTimer;

@property (nonatomic,strong) UISwitch *onceSwitch;

@property (nonatomic,strong) UILabel *onceLabel;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showHeatRate:)
                                                 name:READ_SPORTDATA_SUCCESS
                                               object:nil];
    
    _heatRateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 30, ScreenHeight * 0.15, 60, 60)];
    _heatRateImageView.image = [UIImage imageNamed:@"heatRate"];
    [self.view addSubview:_heatRateImageView];
    
    _onceSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(kScreenWidth - 80, ScreenHeight *0.31, 40, 40)];
    [self.view addSubview:_onceSwitch];
    _onceSwitch.enabled = YES;
    _onceSwitch.backgroundColor = [UIColor grayColor];
    _onceSwitch.layer.cornerRadius = _onceSwitch.height/2;
    _onceSwitch.layer.masksToBounds = YES;
    [_onceSwitch setOn:YES];
    
    _onceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 160, ScreenHeight *0.31-5, 70, 40)];
    _onceLabel.text = BTLocalizedString(@"单次");
    _onceLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:_onceLabel];
    _onceLabel.textColor = KThemeGreenColor;
    _onceLabel.font = [UIFont boldSystemFontOfSize:19];
    
    CGFloat beatNumberLabelY = ScreenHeight * 0.5;
    _lblHeartBeatNumber = [[UILabel alloc] initWithFrame:CGRectMake(20, beatNumberLabelY, ScreenWidth - 40, 30)];
    _lblHeartBeatNumber.font = [UIFont boldSystemFontOfSize:18];
    _lblHeartBeatNumber.attributedText = [self attributeTextWithString:@"0"];
    
    _lblHeartBeatNumber.textAlignment = NSTextAlignmentCenter;
    _lblHeartBeatNumber.textColor = [UIColor blackColor];
    [self.view addSubview:_lblHeartBeatNumber];
    
    UIImageView *TipView = [[UIImageView alloc] initWithFrame:CGRectMake(20, beatNumberLabelY+40, SCREEN_WIDTH - 40, 10)];
    TipView.image = [UIImage imageNamed:@"scope"];
    [self.view addSubview:TipView];
    
    CGFloat numberLabelY = beatNumberLabelY+60;
    UILabel *lblNumber01 = [[UILabel alloc] initWithFrame:CGRectMake(20, numberLabelY, (SCREEN_WIDTH - 40)/3, 20)];
    lblNumber01.text = @"< 60";
    lblNumber01.font = [UIFont boldSystemFontOfSize:13];
    lblNumber01.textAlignment = NSTextAlignmentCenter;
    lblNumber01.textColor = [UIColor blackColor];
    [self.view addSubview:lblNumber01];
    
    UILabel *lblNumber02 = [[UILabel alloc] initWithFrame:CGRectMake(20+(SCREEN_WIDTH - 40)/3, numberLabelY, (SCREEN_WIDTH - 40)/3, 20)];
    lblNumber02.text = @" 60 - 90 ";
    lblNumber02.font = [UIFont boldSystemFontOfSize:13];
    lblNumber02.textAlignment = NSTextAlignmentCenter;
    lblNumber02.textColor = [UIColor blackColor];
    [self.view addSubview:lblNumber02];
    
    UILabel *lblNumber03 = [[UILabel alloc] initWithFrame:CGRectMake(20+(SCREEN_WIDTH - 40)/3*2, numberLabelY, (SCREEN_WIDTH - 40)/3, 20)];
    lblNumber03.text = @"> 90";
    lblNumber03.font = [UIFont boldSystemFontOfSize:13];
    lblNumber03.textAlignment = NSTextAlignmentCenter;
    lblNumber03.textColor = [UIColor blackColor];
    [self.view addSubview:lblNumber03];
    
//    remindTextView = [[UILabel alloc] initWithFrame:CGRectMake(10,
//                                                                              lblNumber03.height + lblNumber03.y + 100 ,
//                                                                              SCREEN_WIDTH - 20,
//                                                                              100)];
//    remindTextView.backgroundColor = [UIColor clearColor];
//    remindTextView.font = [UIFont systemFontOfSize:16];
//    remindTextView.text = BTLocalizedString(@"运动后心率加快属正常现象,请不要担心.心率信息仅提供参考.");
//    remindTextView.numberOfLines = 0;
//    [self.view addSubview:remindTextView];

    _startButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  50,
                                                                  30)];
    [_startButton addTarget:self
                action:@selector(clickButtonForHeartBeat:)
      forControlEvents:UIControlEventTouchUpInside];
    _startButton.titleLabel.font = [UIFont systemFontOfSize:16];
    _startButton.titleLabel.textAlignment = NSTextAlignmentRight;
    [_startButton setTitle:BTLocalizedString(@"开始") forState:UIControlStateNormal];
    [_startButton.titleLabel sizeToFit];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:_startButton];
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([[BluetoothManager share] isExistCharacteristic]) {
        [[BluetoothManager share] closeReadHeartRate];
    }
    [self heartStopBeating];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickButtonForHeartBeat:(UIButton *)button {
    
    BOOL isOn = [[[NSUserDefaults standardUserDefaults] objectForKey:ManagerStatePoweredOn] boolValue];
    if (!isOn) {
        [MBProgressHUD showHUDByContent:BTLocalizedString(@"蓝牙功能未打开") view:UI_Window afterDelay:1.5];
        return;
    }
    //没有绑定设备
    NSString *connectDeviceUUID = [[NSUserDefaults standardUserDefaults] objectForKey:didConnectDevice];
    if (!connectDeviceUUID) {
        [MBProgressHUD showHUDByContent:BTLocalizedString(@"您尚未绑定设备") view:UI_Window afterDelay:1.5];
        return;
    }
    if (![[BluetoothManager share] isExistCharacteristic]) {
        [MBProgressHUD showHUDByContent:BTLocalizedString(@"设备自动连接中，请稍后") view:UI_Window afterDelay:1.5];
        return;
    }
    if (button.selected) {
        [button setTitle:BTLocalizedString(@"开始") forState:UIControlStateNormal];
        [_startButton.titleLabel sizeToFit];
        [[BluetoothManager share] closeReadHeartRate];
        [self heartStopBeating];
        _onceSwitch.enabled = YES;
//        [MBProgressHUD hideHUDForView:self.view
//                             animated:YES];
    } else {
        [button setTitle:BTLocalizedString(@"结束") forState:UIControlStateNormal];
        [_startButton.titleLabel sizeToFit];
        _lblHeartBeatNumber.attributedText = [self attributeTextWithString:@"0"];
        if (_onceSwitch.isOn) {
            
            [[BluetoothManager share] readHeartRateIsOnce:YES];
        }else{
            
            [[BluetoothManager share] readHeartRateIsOnce:NO];
        }
        _onceSwitch.enabled = NO;
        
        [_heatRateTimer invalidate];
        _heatRateTimer = nil;
        _heatRateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(heatRating) userInfo:nil repeats:YES];
        [_heatRateTimer fire];
//        [MBProgressHUD showHUDByContent:BTLocalizedString(@"测定心率中...")
//                                   view:self.view
//                             afterDelay:INT_MAX];
    }
    button.selected = !button.selected;
}

- (void)heatRating
{
    [UIView animateWithDuration:0.6 animations:^{
        CGRect heatRect = CGRectMake(ScreenWidth*0.5 -60, ScreenHeight * 0.15, 120, 120);
        _heatRateImageView.frame = heatRect;
    } completion:^(BOOL finished) {
        CGRect heatRect = CGRectMake(ScreenWidth*0.5 - 30, ScreenHeight * 0.15, 60, 60);
        _heatRateImageView.frame = heatRect;
    }];
}

- (void)readHeartRateSuccess {
    NSString *rateStr = [NSString stringWithFormat:@"%@",@([BluetoothManager share].heartRate).stringValue];
    _lblHeartBeatNumber.attributedText = [self attributeTextWithString:rateStr];
//    _lblHeartBeatNumber.text = [NSString stringWithFormat:@"%@%@",@([BluetoothManager share].heartRate).stringValue,BTLocalizedString(@"次/分钟")];
}

- (void)readHeartRateFinished {
    [self heartStopBeating];
    _onceSwitch.enabled = YES;
    [_startButton setTitle:BTLocalizedString(@"开始") forState:UIControlStateNormal];
    [_startButton.titleLabel sizeToFit];
//    [MBProgressHUD hideHUDForView:self.view
//                         animated:YES];
}

- (void)disConnectPeripheral {
    [self heartStopBeating];
    if ([[BluetoothManager share] isExistCharacteristic]) {
        [[BluetoothManager share] closeReadHeartRate];
    }
    [_startButton setTitle:BTLocalizedString(@"开始") forState:UIControlStateNormal];
    [_startButton.titleLabel sizeToFit];
//    [MBProgressHUD hideHUDForView:self.view
//                         animated:YES];
}

- (void)changeLanguage:(NSNotification *)notification {
    self.title = BTLocalizedString(@"心率");
    
    _onceLabel.text = BTLocalizedString(@"单次");
//    if (_startButton.selected) {
    [_startButton setTitle:BTLocalizedString(@"开始") forState:UIControlStateNormal];
    [_startButton.titleLabel sizeToFit];
//    } else {
//        [_startButton setTitle:BTLocalizedString(@"取消") forState:UIControlStateNormal];
//    }
    NSString *rateStr = [NSString stringWithFormat:@"%@",@([BluetoothManager share].heartRate).stringValue];
    _lblHeartBeatNumber.attributedText = [self attributeTextWithString:rateStr];
//    remindTextView.text = BTLocalizedString(@"运动后心率加快属正常现象,请不要担心.心率信息仅提供参考.");
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

- (void)showHeatRate:(NSNotification *)notice
{
    SportDataModel *model = notice.object;
    NSString *heatRate = [NSString stringWithFormat:@"%ld",model.heatRate];
    NSMutableAttributedString *attribute = [self attributeTextWithString:heatRate];
    _lblHeartBeatNumber.attributedText = attribute;
}

- (void)heartStopBeating
{
    [_heatRateTimer invalidate];
    _heatRateTimer = nil;
    CGRect heatRect = CGRectMake(ScreenWidth*0.5 - 30, ScreenHeight * 0.15, 60, 60);
    _heatRateImageView.frame = heatRect;
    
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
