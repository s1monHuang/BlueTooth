//
//  SleepCtrl.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/2.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "SleepCtrl.h"
#import "PNCircleChart.h"
#import "BluetoothManager.h"
#import "HistorySportDataModel.h"
#import "DBManager.h"

@interface SleepCtrl ()

@property (strong,nonatomic) UIView *chartView;
@property (strong,nonatomic) UIView *circleBgView;

@property (strong,nonatomic) UIView *footerView;

@property (nonatomic) UIButton *refreshBututton;

@property (nonatomic) UILabel *sleepTimeValue;      //显示睡眠时长
@property (nonatomic) UILabel *ssleepTimeValue;     //深睡眠时长
@property (nonatomic) UILabel *qsleepTimeValue;     //浅睡眠时长

@property (nonatomic) PNCircleChart * circleChart;

@property (nonatomic) NSArray *historys;

@property (nonatomic,assign) NSInteger sleepValue;
@property (nonatomic,assign) NSInteger deepSleepValue;
@property (nonatomic,assign) NSInteger shallowSleepValue;

@property (nonatomic,assign) NSInteger deepSleepPercent;

@property (nonatomic,assign) BOOL isLoading;        //是否正在同步数据

@end

@implementation SleepCtrl

- (void)viewWillAppear:(BOOL)animated {
    if (_isLoading) {
        [self startAnimation];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [_refreshBututton.layer removeAllAnimations];
//    _refreshBututton.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"睡眠";
    self.view.backgroundColor = kThemeGrayColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshSleepDataSuccess)
                                                 name:READ_HISTORY_SPORTDATA_SUCCESS
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disConnectPeripheral)
                                                 name:DISCONNECT_PERIPHERAL
                                               object:nil];
    
    _isLoading = NO;
    
    [self resetSleepValue];
    
    _chartView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 200)];
    _chartView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_chartView];
    
    _circleBgView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, (_chartView.frame.size.width - 100), (_chartView.frame.size.width - 100))];
    _circleBgView.backgroundColor = [UIColor clearColor];
    [_chartView addSubview:_circleBgView];
    
    self.circleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(50,50.0, _circleBgView.frame.size.width, _circleBgView.frame.size.height)
                                                      total:@100
                                                    current:@(_deepSleepPercent)
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
    sleepTimeText.textColor = [UIColor grayColor];
    [tempView addSubview:sleepTimeText];
    
    _sleepTimeValue = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 50 - 22*2)/2+32,tempView.frame.size.width, 20)];
    _sleepTimeValue.textAlignment = NSTextAlignmentCenter;
    _sleepTimeValue.textColor = [UIColor grayColor];
    [tempView addSubview:_sleepTimeValue];
    
    _ssleepTimeValue = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 50 - 22*2)/2+32+30,tempView.frame.size.width, 20)];
    _ssleepTimeValue.font = [UIFont systemFontOfSize:12];
    _ssleepTimeValue.textAlignment = NSTextAlignmentCenter;
    _ssleepTimeValue.textColor = [UIColor grayColor];
    [tempView addSubview:_ssleepTimeValue];
    
    _qsleepTimeValue = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 50 - 22*2)/2+32+50,tempView.frame.size.width, 20)];
    _qsleepTimeValue.font = [UIFont systemFontOfSize:12];
    _qsleepTimeValue.textAlignment = NSTextAlignmentCenter;
    _qsleepTimeValue.textColor = [UIColor grayColor];
    [tempView addSubview:_qsleepTimeValue];
    
//    _refreshBututton = [[UIButton alloc] initWithFrame:CGRectMake(_circleChart.width + 30,
//                                                                  _circleChart.height + _circleChart.y,
//                                                                  35,
//                                                                  35)];
//    [_refreshBututton setBackgroundImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
//    [_refreshBututton addTarget:self
//                         action:@selector(refreshSleepData)
//               forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_refreshBututton];
    
    [self setSleepTimeValues];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//重置睡眠时间
- (void)resetSleepValue {
    _sleepValue = 0;
    _deepSleepValue = 0;
    _shallowSleepValue = 0;
    
    _deepSleepValue = [DBManager selectTodayssmNumber];
    _shallowSleepValue = [DBManager selectTodayqsmNumber];
    _sleepValue = _deepSleepValue + _shallowSleepValue;
    _deepSleepPercent = (_deepSleepValue * 1.0 / _sleepValue) * 100;
}

- (void)startAnimation {
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 2;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = NSIntegerMax;
    [_refreshBututton.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)refreshSleepData {
    if (![[BluetoothManager share] isExistCharacteristic]) {
        return;
    }
    _isLoading = YES;
    _refreshBututton.userInteractionEnabled = NO;
    [self startAnimation];
    [[BluetoothManager share] readHistroySportData];
}

- (void)refreshSleepDataSuccess {
    _isLoading = NO;
    [self resetSleepValue];
    [_circleChart updateChartByCurrent:@(_deepSleepPercent) byTotal:@(100)];
    [self setSleepTimeValues];
    [MBProgressHUD showHUDByContent:@"同步成功" view:UI_Window afterDelay:1.5];
}

- (void)setSleepTimeValues {
    NSRange sleepHourRange = NSMakeRange(0, _sleepValue >= 10? 2:1);
    NSRange sleepMinuteRagne = NSMakeRange(sleepHourRange.length + 2, 2);
    NSMutableAttributedString *sleepValueString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@小时00分钟",@(_sleepValue).stringValue]];
    [sleepValueString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:30],NSForegroundColorAttributeName:[UIColor blackColor]}
                              range:sleepHourRange];
    [sleepValueString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:30],NSForegroundColorAttributeName:[UIColor blackColor]}
                              range:sleepMinuteRagne];
    _sleepTimeValue.attributedText = sleepValueString;
    
    NSRange deepSleepRange = NSMakeRange(0, 3);
    NSMutableAttributedString *deepSleepValueString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"★深睡%@小时00分钟",@(_deepSleepValue).stringValue]];
    [deepSleepValueString addAttributes:@{NSForegroundColorAttributeName:[UtilityUI stringTOColor:@"#1b6cff"]}
                              range:deepSleepRange];
    _ssleepTimeValue.attributedText = deepSleepValueString;
    
    NSRange shallowSleepRange = NSMakeRange(0, 3);
    NSMutableAttributedString *shallowSleepValueString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"☆浅睡%@小时00分钟",@(_shallowSleepValue).stringValue]];
    [shallowSleepValueString addAttributes:@{NSForegroundColorAttributeName:[UtilityUI stringTOColor:@"#6dabff"]}
                              range:shallowSleepRange];
    _qsleepTimeValue.attributedText = shallowSleepValueString;
}

- (void)disConnectPeripheral {
    [_refreshBututton.layer removeAllAnimations];
    _refreshBututton.userInteractionEnabled = YES;
    _isLoading = NO;
}

@end
