//
//  SportCtrl.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/2.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "SportCtrl.h"
#import "PNCircleChart.h"
#import "OperateViewModel.h"
#import "SportDataModel.h"
#import "ShareCtrl.h"
#import "TrainTargetController.h"

@interface SportCtrl ()

@property (strong,nonatomic) UIView *chartView;
@property (strong,nonatomic) UIView *circleBgView;
@property (strong,nonatomic) UIView *footerView;

@property (nonatomic) PNCircleChart * circleChart;

@property (nonatomic) UILabel *complateValue;
@property (nonatomic) UILabel *complateStep;
@property (nonatomic) UILabel *totalStep;

@property (nonatomic) UILabel *lblBoxoneValue;      //当天步数
@property (nonatomic) UILabel *lblBoxtwoValue;      //当天距离
@property (nonatomic) UILabel *lblBoxthreeValue;    //当天消耗能量
@property (nonatomic,strong) UILabel *lblBoxFourValue;    //当天脂肪燃烧

@property (nonatomic) UIButton *refreshBututton;
@property (nonatomic) UIProgressView *progressView;

@property (nonatomic , strong) UIImageView *battery;     //电池

@property (nonatomic , strong) UIImageView *electricity; //电量

@property (nonatomic , strong) UILabel *electricityPercent;    //电量百分比


@property (nonatomic,strong) SportDataModel *sportModel;
@property (nonatomic,strong) BasicInfomationModel *infomationModel;

@property (nonatomic,strong) OperateViewModel *operateVM;

@property (nonatomic,assign) NSInteger stepCount;

@property (nonatomic,assign) BOOL isLoading;        //是否正在同步数据
@property (nonatomic , assign) CGFloat imageX;

@property (nonatomic , strong) UIView *threeBoxView;


@end

@implementation SportCtrl

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
    
    self.title = @"运动";
    self.view.backgroundColor = kThemeGrayColor;
    NSArray *tempIconArray = @[@"pic-foot",@"pic-distance",@"pic-fire"];
    
    _isLoading = NO;
//    if ([BluetoothManager getBindingPeripheralUUID]) {
//        _sportModel = [DBManager selectSportData];
//    }
    _infomationModel = [DBManager selectBasicInfomation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshSportDataSuccess:)
                                                 name:READ_SPORTDATA_SUCCESS
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(firstRefreshSportDataSuccess:)
                                                 name:FIRST_READ_SPORTDATA_SUCCESS
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disConnectPeripheral)
                                                 name:DISCONNECT_PERIPHERAL
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeStepCount:)
                                                 name:@"changeStepCount"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideHudForConnect)
                                                 name:@"connect_success"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeDevice)
                                                 name:REMOVE_DEVICE
                                               object:nil];
    
    
    //自动登录
//    [self autoDownload];
    
    _chartView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 200)];
    _chartView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_chartView];
    
    _circleBgView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, (_chartView.frame.size.width - 100), (_chartView.frame.size.width - 100))];
    _circleBgView.backgroundColor = [UIColor clearColor];
    [_chartView addSubview:_circleBgView];
    
    _stepCount = [[[NSUserDefaults standardUserDefaults] objectForKey:targetStepCount] integerValue];
    
    CGFloat circleChartY = kScreenHeight > 480 ? 50 : 20;
    self.circleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(50,circleChartY, _circleBgView.frame.size.width, _circleBgView.frame.size.height)
                                                      total:@100
                                                    current:_sportModel?@(_sportModel.step / (double)_stepCount * 100):@(0)
                                                  clockwise:YES shadow:YES shadowColor:[UIColor whiteColor]];
    
    self.circleChart.backgroundColor = [UIColor clearColor];
    self.circleChart.lineWidth = @(20);
    [self.circleChart setStrokeColor:[UtilityUI stringTOColor:@"#6dabff"]];
    [self.circleChart strokeChart];
    [_chartView addSubview:self.circleChart];
    
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(30, 30, self.circleChart.frame.size.width - 60, self.circleChart.frame.size.width - 60)];
    tempView.contentMode = UIViewContentModeScaleAspectFill;
    tempView.clipsToBounds = YES;
    [tempView.layer setCornerRadius:CGRectGetHeight([tempView bounds])/2];
    tempView.layer.masksToBounds = YES;
    tempView.backgroundColor = [UIColor whiteColor];
    [_circleChart addSubview:tempView];
    
    CGFloat completionRateFloat = _stepCount == 0?_sportModel.step / 10000.0 * 100:_sportModel.step / (double)_stepCount * 100;
    NSString *completionRate = [NSString stringWithFormat:@"%0.lf",completionRateFloat];
    completionRate = [NSString stringWithFormat:@"完成%@%%",_sportModel?completionRate:@(0).stringValue];
    
    [_circleChart updateChartByCurrent:@(completionRateFloat)];
    
    _complateValue = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 60 - 22*2)/2,tempView.frame.size.width, 20)];
    _complateValue.text = completionRate;
    _complateValue.textAlignment = NSTextAlignmentCenter;
    _complateValue.textColor = [UIColor blackColor];
    [tempView addSubview:_complateValue];
    
    _complateStep = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 60 - 22*2)/2+35,tempView.frame.size.width, 30)];
    _complateStep.text = [NSString stringWithFormat:@"%@",@(_sportModel.step).stringValue];
    _complateStep.font = [UIFont systemFontOfSize:28];
    _complateStep.textAlignment = NSTextAlignmentCenter;
    _complateStep.textColor = [UIColor blackColor];
    [tempView addSubview:_complateStep];
    
    
    _totalStep = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 60 - 22*2)/2+35*2+10,tempView.frame.size.width, 20)];
    if (_stepCount) {
        NSString *target = [NSString stringWithFormat:@"目标 %@",@(_stepCount).stringValue];
        _totalStep.text = target;
    }else{
        _totalStep.text = @"目标 10000";
    }
    
    _totalStep.textAlignment = NSTextAlignmentCenter;
    _totalStep.textColor = [UIColor blackColor];
    [tempView addSubview:_totalStep];
    
//    UIImageView *threeBox = [[UIImageView alloc] initWithFrame:CGRectMake(10, ScreenHeight - 138 - 88, ScreenWidth - 20, 88)];
//    threeBox.image = [UIImage imageNamed:@"threebox"];
//    [self.view addSubview:threeBox];
    UIView *threeBox = [[UIView alloc] initWithFrame:CGRectMake(10, ScreenHeight - 138 - 88, ScreenWidth - 20, 88)];
    threeBox.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:threeBox];
    _threeBoxView = threeBox;
    
    CGFloat boxWidth = ScreenWidth - 20;
    CGFloat oneBoxWidth = boxWidth / 4;
    _imageX = boxWidth / 4;
    for (NSInteger i = 1; i < 4; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(oneBoxWidth * i, 0, 0.5, 88)];
        lineView.backgroundColor = kThemeGrayColor;
        [threeBox addSubview:lineView];
    }
    // 步数
    _lblBoxoneValue = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, oneBoxWidth, 22)];
    _lblBoxoneValue.textAlignment = NSTextAlignmentCenter;
    _lblBoxoneValue.font = [UIFont systemFontOfSize:20];
    _lblBoxoneValue.text = [NSString stringWithFormat:@"%@",_sportModel?@(_sportModel.step).stringValue:@(0).stringValue];
    [threeBox addSubview:_lblBoxoneValue];
    
    UILabel *lblBoxoneText = [[UILabel alloc] initWithFrame:CGRectMake(18, 20+22+10, oneBoxWidth-15, 30)];
    lblBoxoneText.textAlignment = NSTextAlignmentLeft;
    lblBoxoneText.font = [UIFont systemFontOfSize:10];
    lblBoxoneText.text = @"当天步数(步)";
    lblBoxoneText.numberOfLines = 0;
    [threeBox addSubview:lblBoxoneText];
    [self imageViewWithLabelCount:0 imageName:tempIconArray[0]];
    
    // 距离
    _lblBoxtwoValue = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth, 20, oneBoxWidth, 22)];
    _lblBoxtwoValue.textAlignment = NSTextAlignmentCenter;
    _lblBoxtwoValue.font = [UIFont systemFontOfSize:20];
    _lblBoxtwoValue.text = [NSString stringWithFormat:@"%.2lf",(_sportModel?_sportModel.step * [CurrentUser.stepLong floatValue]:0)*0.00001];
    [threeBox addSubview:_lblBoxtwoValue];
    
    UILabel *lblBoxtwoText = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth+18, 20+22+10, oneBoxWidth-15, 30)];
    lblBoxtwoText.textAlignment = NSTextAlignmentLeft;
    lblBoxtwoText.font = [UIFont systemFontOfSize:10];
    lblBoxtwoText.text = @"活动距离(km)";
    lblBoxtwoText.numberOfLines = 0;
    [threeBox addSubview:lblBoxtwoText];
    [self imageViewWithLabelCount:1 imageName:tempIconArray[1]];
    // 消耗能量
    _lblBoxthreeValue = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth*2, 20, oneBoxWidth, 22)];
    _lblBoxthreeValue.textAlignment = NSTextAlignmentCenter;
    _lblBoxthreeValue.font = [UIFont systemFontOfSize:20];
    _lblBoxthreeValue.text = [NSString stringWithFormat:@"%.2f",_sportModel?[CurrentUser.weight floatValue] * _sportModel.distance*0.01 * 1.036 * 0.001:0];
    [threeBox addSubview:_lblBoxthreeValue];
    
    UILabel *lblBoxthreeText = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth*2+18, 20+22+10, oneBoxWidth-15, 30)];
    lblBoxthreeText.textAlignment = NSTextAlignmentLeft;
    lblBoxthreeText.font = [UIFont systemFontOfSize:10];
    lblBoxthreeText.text = @"消耗能量(kCal)";
    lblBoxthreeText.numberOfLines = 0;
    [threeBox addSubview:lblBoxthreeText];
    [self imageViewWithLabelCount:2 imageName:tempIconArray[2]];
    
    // 脂肪燃烧
    _lblBoxFourValue = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth*3, 20, oneBoxWidth-15, 22)];
    _lblBoxFourValue.textAlignment = NSTextAlignmentCenter;
    _lblBoxFourValue.font = [UIFont systemFontOfSize:20];
    _lblBoxFourValue.text = [NSString stringWithFormat:@"%.2lf",(_sportModel?[CurrentUser.weight floatValue] * _sportModel.distance*0.01 * 1.036 * 0.001:0)/9.0];
    [threeBox addSubview:_lblBoxFourValue];
    
    UILabel *lblBoxFourText = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth*3+18, 20+22+10, oneBoxWidth, 30)];
    lblBoxFourText.textAlignment = NSTextAlignmentLeft;
    lblBoxFourText.font = [UIFont systemFontOfSize:10];
    lblBoxFourText.text = @"脂肪燃烧(g)";
    lblBoxFourText.numberOfLines = 0;
    [threeBox addSubview:lblBoxFourText];
    [self imageViewWithLabelCount:3 imageName:tempIconArray[2]];
    
    
    CGFloat refreshY = kScreenHeight > 480 ? 0 : 20;
    _refreshBututton = [[UIButton alloc] initWithFrame:CGRectMake(_circleChart.width + 30,
                                                                  _circleChart.height + _circleChart.y + (35 / 2 - refreshY -5),
                                                                  35,
                                                                  35)];
    [_refreshBututton setBackgroundImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [_refreshBututton addTarget:self
                        action:@selector(refreshSportData)
              forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_refreshBututton];
    
    //电池
    _battery = [[UIImageView alloc] initWithFrame:CGRectMake(_circleChart.x - 25,
                                                                     _circleChart.height + _circleChart.y + (35 / 2 - refreshY),
                                                                     50,
                                                                     20)];
    _battery.image = [UIImage imageNamed:@"dianchi"];
    CGFloat electricityWidth = 50.0 * (_sportModel?_sportModel.battery / 100.0 :0);
    if (electricityWidth > 50.0) {
        electricityWidth = 50.0;
    }
    _electricity = [[UIImageView alloc] initWithFrame:CGRectMake(_circleChart.x - 25,
                                                             _circleChart.height + _circleChart.y + (35 / 2 - refreshY),
                                                             electricityWidth,
                                                             20)];
    _electricity.image = [UIImage imageNamed:@"dianliang"];
//    _progressView.progress = _sportModel?_sportModel.battery / 100.0 :0;
    [self.view addSubview:_battery];
    [self.view addSubview:_electricity];
    
    _electricityPercent = [[UILabel alloc] initWithFrame:CGRectMake(_electricity.x, _electricity.y + 28, 50, 12)];
    CGFloat percent = (_sportModel?_sportModel.battery / 100.0 :0 )* 100;
    if (percent > 100.0) {
        percent = 100.0;
    }
    NSString *percentStr = [NSString stringWithFormat:@"%.0f %%",percent];
    _electricityPercent.text = percentStr;
    _electricityPercent.font = [UIFont systemFontOfSize:8];
    _electricityPercent.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_electricityPercent];
    
    // 设置
    UIBarButtonItem *rightBarButton=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share2"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(rightBarButtonClick:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}

- (void)imageViewWithLabelCount:(NSInteger)count imageName:(NSString *)imageName
{
    UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(_imageX*count, 20+22+15, 15, 15)];
    iconImage.image = [UIImage imageNamed:imageName];
    [_threeBoxView addSubview:iconImage];
}

- (void)removeMBProgress
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)changeStepCount:(NSNotification *)sender
{
    _totalStep.text = [NSString stringWithFormat:@"目标 %@",sender.object];
    _stepCount = [sender.object integerValue];
    
    CGFloat completionRateFloat = _stepCount == 0?_sportModel.step / 10000.0 * 100:_sportModel.step / (double)_stepCount * 100;
    NSString *completionRate = [NSString stringWithFormat:@"%0.lf",completionRateFloat];
    completionRate = [NSString stringWithFormat:@"完成%@%%",_sportModel?completionRate:@(0).stringValue];
    _complateValue.text = completionRate;
    [_circleChart updateChartByCurrent:@(completionRateFloat)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)refreshSportData {
    //没有绑定设备
    if (![BluetoothManager getBindingPeripheralUUID]) {
        [MBProgressHUD showHUDByContent:@"您尚未绑定设备" view:UI_Window afterDelay:1.5];
        return;
    }
    if (![[BluetoothManager share] isExistCharacteristic]) {
        [MBProgressHUD showHUDByContent:@"设备自动连接中，请稍后" view:UI_Window afterDelay:1.5];
        return;
    }
    _isLoading = YES;
    _refreshBututton.userInteractionEnabled = NO;
    [[BluetoothManager share] readSportData];
    [self startAnimation];
}

- (void)refreshSportDataSuccess:(NSNotification *)notification {
    
    [[BluetoothManager share] readHistroySportData];
    [self firstRefreshSportDataSuccess:notification];
    
}

- (void)firstRefreshSportDataSuccess:(NSNotification *)notification {
    _isLoading = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_refreshBututton.layer removeAllAnimations];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
    
    id object = [notification object];
    if (!object) {
        _sportModel = [DBManager selectSportData];
    } else {
        _sportModel = [notification object];
    }
    
    CGFloat completionRateFloat = _stepCount == 0?_sportModel.step / 10000.0 * 100:_sportModel.step / (double)_stepCount * 100;
    NSString *completionRate = [NSString stringWithFormat:@"%0.lf",completionRateFloat];
    completionRate = [NSString stringWithFormat:@"完成%@%%",_sportModel?completionRate:@(0).stringValue];
    _complateValue.text = completionRate;
    
    _complateStep.text = [NSString stringWithFormat:@"%@",@(_sportModel.step).stringValue];
    if (_stepCount) {
        NSString *target = [NSString stringWithFormat:@"目标 %@",@(_stepCount).stringValue];
        _totalStep.text = target;
    }else{
        _totalStep.text = @"目标 10000";
    }
    
    [_circleChart updateChartByCurrent:@(completionRateFloat)];
    
    _lblBoxoneValue.text = [NSString stringWithFormat:@"%@",_sportModel?@(_sportModel.step).stringValue:@(0).stringValue];
    _lblBoxtwoValue.text = [NSString stringWithFormat:@"%.2lf",(_sportModel?_sportModel.step * [CurrentUser.stepLong floatValue]:0)*0.00001];
    _lblBoxthreeValue.text = [NSString stringWithFormat:@"%.2f",_sportModel?[CurrentUser.weight floatValue] * _sportModel.distance*0.01 * 1.036 * 0.001:0];
    
    _progressView.progress = _sportModel?_sportModel.battery / 100.0 :0;
    _refreshBututton.userInteractionEnabled = YES;
    
    CGFloat electricityWidth = 50.0 * (_sportModel?_sportModel.battery / 100.0 :0);
    if (electricityWidth > 50.0) {
        electricityWidth = 50.0;
    }
    _electricity.width = electricityWidth;
    CGFloat percent = (_sportModel?_sportModel.battery / 100.0 :0 )* 100;
    if (percent > 100.0) {
        percent = 100.0;
    }
    NSString *percentStr = [NSString stringWithFormat:@"%.0f %%",percent];
    _electricityPercent.text = percentStr;
    _electricityPercent.textAlignment = NSTextAlignmentCenter;
}

//设备解除绑定,所有数据清零
- (void)removeDevice {
    [_circleChart updateChartByCurrent:@(0)];
    
    NSString *completionRate = [NSString stringWithFormat:@"完成0%%"];
    _complateValue.text = completionRate;
    _complateStep.text = @"0";
    
    _lblBoxoneValue.text = @"0";
    _lblBoxtwoValue.text = @"0";
    _lblBoxthreeValue.text = @"0";
    _electricity.width = 0;
    _electricityPercent.text = @"0%";
    
}

- (void)registerSOSNotification
{
    
}

- (void)disConnectPeripheral {
    [_refreshBututton.layer removeAllAnimations];
    _refreshBututton.userInteractionEnabled = YES;
    _isLoading = NO;
}

- (void)rightBarButtonClick:(id)sender {
    ShareCtrl *share = [[ShareCtrl alloc] init];
    [self presentViewController:share animated:YES completion:nil];
}

- (void)hideHudForConnect
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
