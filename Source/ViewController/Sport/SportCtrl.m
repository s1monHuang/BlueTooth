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
#import "DeviceManagerViewController.h"

@interface SportCtrl () {
    UILabel *lblBoxoneText;
    UILabel *lblBoxtwoText;
    UILabel *lblBoxthreeText;
    UILabel *lblBoxFourText;
    
    NSTimer *_timer;
}

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
@property (nonatomic , strong) UILabel *lblBoxOneTextUnit;



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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLanguage:)
                                                 name:NOTIFY_CHANGE_LANGUAGE
                                               object:nil];
    
    _operateVM = [OperateViewModel viewModel];
    
    self.title = [NSString stringWithFormat:@"%@",BTLocalizedString(@"运动")];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshSportDataError:)
                                                 name:READ_SPORTDATA_ERROR
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
    completionRate = [NSString stringWithFormat:@"%@ %@%%",BTLocalizedString(@"完成"),_sportModel?completionRate:@(0).stringValue];
    
    [_circleChart updateChartByCurrent:@(completionRateFloat)];
    
    _complateValue = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 60 - 22*2)/2,tempView.frame.size.width, 20)];
    _complateValue.text = completionRate;
    _complateValue.textAlignment = NSTextAlignmentCenter;
    _complateValue.textColor = [UIColor blackColor];
    [tempView addSubview:_complateValue];
    
    _complateStep = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 60 - 22*2)/2+35,tempView.frame.size.width, 30)];
    NSString *tempStr = [NSString stringWithFormat:@"%@",@(_sportModel.step).stringValue];
    NSRange range = NSMakeRange(0, tempStr.length == 0?1:tempStr.length);
    NSMutableAttributedString *stepStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ ",tempStr,BTLocalizedString(@"步")]];
    [stepStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:28],NSForegroundColorAttributeName:[UIColor blackColor]}
                               range:range];
    
    _complateStep.attributedText = stepStr;
//    _complateStep.font = [UIFont systemFontOfSize:20];
    _complateStep.textAlignment = NSTextAlignmentCenter;
    _complateStep.textColor = [UIColor blackColor];
    [tempView addSubview:_complateStep];
    
    
    _totalStep = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 60 - 22*2)/2+35*2+10,tempView.frame.size.width, 20)];
    if (_stepCount) {
        NSString *target = [NSString stringWithFormat:@"%@ %@",BTLocalizedString(@"目标"),@(_stepCount).stringValue];
        _totalStep.text = target;
    }else{
        _totalStep.text = [NSString stringWithFormat:@"%@ 10000",BTLocalizedString(@"目标")];
    }
    
    _totalStep.textAlignment = NSTextAlignmentCenter;
    _totalStep.textColor = [UIColor blackColor];
    [tempView addSubview:_totalStep];
    
    UIView *threeBox = [[UIView alloc] initWithFrame:CGRectMake(10, ScreenHeight - 138 - 88, ScreenWidth - 20, 88)];
    threeBox.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:threeBox];
    _threeBoxView = threeBox;
    
    CGFloat boxWidth = ScreenWidth - 10;
    CGFloat oneBoxWidth = boxWidth / 4;
    _imageX = boxWidth / 4;
    for (NSInteger i = 1; i < 4; i++) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(oneBoxWidth * i, 0, 0.5, 88)];
        lineView.backgroundColor = kThemeGrayColor;
        [threeBox addSubview:lineView];
    }
    CGFloat boxTextY = 47;
    CGFloat boxTextH = 20;
    CGFloat fontSize = ScreenWidth > 320 ? 10 : 9;
    // 步数
    _lblBoxoneValue = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, oneBoxWidth, 22)];
    _lblBoxoneValue.textAlignment = NSTextAlignmentCenter;
    _lblBoxoneValue.font = [UIFont systemFontOfSize:20];
    _lblBoxoneValue.text = [NSString stringWithFormat:@"%@",_sportModel?@(_sportModel.step).stringValue:@(0).stringValue];
    [threeBox addSubview:_lblBoxoneValue];
    
    CGFloat lblBoxoneTextX = ScreenWidth > 320 ? 42 : 30;
    
    lblBoxoneText = [[UILabel alloc] initWithFrame:CGRectMake(_imageX /2 - lblBoxoneTextX, boxTextY, oneBoxWidth, boxTextH)];
    lblBoxoneText.textAlignment = NSTextAlignmentCenter;
    lblBoxoneText.font = [UIFont systemFontOfSize:fontSize];
    lblBoxoneText.text = [NSString stringWithFormat:@"%@",BTLocalizedString(@"当天步数")];
    [threeBox addSubview:lblBoxoneText];
    [self imageViewWithLabelCount:0 imageName:tempIconArray[0]];
   _lblBoxOneTextUnit = [[UILabel alloc] initWithFrame:CGRectMake(_imageX /2 - lblBoxoneTextX, boxTextY + 20, oneBoxWidth, boxTextH)];
    _lblBoxOneTextUnit.textAlignment = NSTextAlignmentCenter;
    _lblBoxOneTextUnit.font = [UIFont systemFontOfSize:fontSize];
    _lblBoxOneTextUnit.text = [NSString stringWithFormat:@"%@",BTLocalizedString(@"(步)")];
    [threeBox addSubview:_lblBoxOneTextUnit];
    
    // 距离
    _lblBoxtwoValue = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth, 20, oneBoxWidth, 22)];
    _lblBoxtwoValue.textAlignment = NSTextAlignmentCenter;
    _lblBoxtwoValue.font = [UIFont systemFontOfSize:20];
    _lblBoxtwoValue.text = [NSString stringWithFormat:@"%.2lf",(_sportModel?_sportModel.step * [CurrentUser.stepLong floatValue]:0)*0.00001];
    [threeBox addSubview:_lblBoxtwoValue];
    
    lblBoxtwoText = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth+20, boxTextY, oneBoxWidth, boxTextH)];
    lblBoxtwoText.textAlignment = NSTextAlignmentLeft;
    lblBoxtwoText.font = [UIFont systemFontOfSize:fontSize];
    lblBoxtwoText.text = [NSString stringWithFormat:@"%@",BTLocalizedString(@"活动距离")];
    lblBoxtwoText.numberOfLines = 0;
    [threeBox addSubview:lblBoxtwoText];
    [self imageViewWithLabelCount:1 imageName:tempIconArray[1]];
    
    UILabel *lblBoxTwoTextUnit = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth, boxTextY + 20, oneBoxWidth, boxTextH)];
    lblBoxTwoTextUnit.textAlignment = NSTextAlignmentCenter;
    lblBoxTwoTextUnit.font = [UIFont systemFontOfSize:fontSize];
    lblBoxTwoTextUnit.text = [NSString stringWithFormat:@"%@",@"(km)"];
    [threeBox addSubview:lblBoxTwoTextUnit];
    
    // 消耗能量
    _lblBoxthreeValue = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth*2, 20, oneBoxWidth, 22)];
    _lblBoxthreeValue.textAlignment = NSTextAlignmentCenter;
    _lblBoxthreeValue.font = [UIFont systemFontOfSize:20];
    _lblBoxthreeValue.text = [NSString stringWithFormat:@"%.2f",_sportModel?(long)(([CurrentUser.weight floatValue] * _sportModel.distance*0.01 * 1.036 * 0.001)*100 )/ 100.0:0];
    [threeBox addSubview:_lblBoxthreeValue];
    
    lblBoxthreeText = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth*2+18, boxTextY, oneBoxWidth, boxTextH)];
    lblBoxthreeText.textAlignment = NSTextAlignmentLeft;
    lblBoxthreeText.font = [UIFont systemFontOfSize:fontSize];
    lblBoxthreeText.text = [NSString stringWithFormat:@"%@",BTLocalizedString(@"消耗能量")];
    lblBoxthreeText.numberOfLines = 0;
    [threeBox addSubview:lblBoxthreeText];
    [self imageViewWithLabelCount:2 imageName:tempIconArray[2]];
    
    UILabel *lblBoxThreeTextUnit = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth*2, boxTextY + 20, oneBoxWidth, boxTextH)];
    lblBoxThreeTextUnit.textAlignment = NSTextAlignmentCenter;
    lblBoxThreeTextUnit.font = [UIFont systemFontOfSize:fontSize];
    lblBoxThreeTextUnit.text = [NSString stringWithFormat:@"%@",@"(kCal)"];
    [threeBox addSubview:lblBoxThreeTextUnit];
    
    // 脂肪燃烧
    _lblBoxFourValue = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth*3, 20, oneBoxWidth-15, 22)];
    _lblBoxFourValue.textAlignment = NSTextAlignmentCenter;
    _lblBoxFourValue.font = [UIFont systemFontOfSize:20];
    _lblBoxFourValue.text = [NSString stringWithFormat:@"%.2lf",(_sportModel?[CurrentUser.weight floatValue] * _sportModel.distance*0.01 * 1.036 * 0.001:0)/9.0];
    [threeBox addSubview:_lblBoxFourValue];
    
    lblBoxFourText = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth*3+18, boxTextY, oneBoxWidth, boxTextH)];
    lblBoxFourText.textAlignment = NSTextAlignmentLeft;
    lblBoxFourText.font = [UIFont systemFontOfSize:fontSize];
    lblBoxFourText.text = [NSString stringWithFormat:@"%@",BTLocalizedString(@"脂肪燃烧")];
    [threeBox addSubview:lblBoxFourText];
    [self imageViewWithLabelCount:3 imageName:tempIconArray[2]];
    
    UILabel *lblBoxFourTextUnit = [[UILabel alloc] initWithFrame:CGRectMake(oneBoxWidth*3, boxTextY + 20, oneBoxWidth, boxTextH)];
    lblBoxFourTextUnit.textAlignment = NSTextAlignmentCenter;
    lblBoxFourTextUnit.font = [UIFont systemFontOfSize:fontSize];
    lblBoxFourTextUnit.text = [NSString stringWithFormat:@"%@",@"(g)"];
    [threeBox addSubview:lblBoxFourTextUnit];
    
    
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
    if (count == 0) {
        CGFloat imageViewX = kScreenWidth > 320 ? 35 : 30;
        UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(_imageX / 2 - imageViewX, 20+22+15, 15, 15)];
        iconImage.image = [UIImage imageNamed:imageName];
        [_threeBoxView addSubview:iconImage];
    }else{
        UIImageView *iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(_imageX*count + 3, 20+22+15, 15, 15)];
        iconImage.image = [UIImage imageNamed:imageName];
        [_threeBoxView addSubview:iconImage];
    }
}

- (void)removeMBProgress
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)changeStepCount:(NSNotification *)sender
{
    _totalStep.text = [NSString stringWithFormat:@"%@ %@",BTLocalizedString(@"完成"),sender.object];
    _stepCount = [sender.object integerValue];
    
    CGFloat completionRateFloat = _stepCount == 0?_sportModel.step / 10000.0 * 100:_sportModel.step / (double)_stepCount * 100;
    NSString *completionRate = [NSString stringWithFormat:@"%0.lf",completionRateFloat];
    completionRate = [NSString stringWithFormat:@"%@ %@%%",BTLocalizedString(@"完成"),_sportModel?completionRate:@(0).stringValue];
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
    NSString *connectDeviceUUID = [[NSUserDefaults standardUserDefaults] objectForKey:didConnectDevice];
    if (!connectDeviceUUID) {
        [MBProgressHUD showHUDByContent:BTLocalizedString(@"您尚未绑定设备") view:UI_Window afterDelay:1.5];
        return;
    }
    if (![[BluetoothManager share] isExistCharacteristic]) {
        [MBProgressHUD showHUDByContent:BTLocalizedString(@"设备自动连接中，请稍后") view:UI_Window afterDelay:1.5];
        return;
    }
    _isLoading = YES;
    _refreshBututton.userInteractionEnabled = NO;
    [[BluetoothManager share] readSportData];

    _timer = [NSTimer scheduledTimerWithTimeInterval:30
                                              target:self
                                            selector:@selector(timeOut)
                                            userInfo:nil
                                             repeats:NO];
    [self startAnimation];
}

- (void)timeOut {
    [self releaseTimer];
    [_refreshBututton.layer removeAllAnimations];
    _isLoading = NO;
}

- (void)releaseTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)refreshSportDataSuccess:(NSNotification *)notification {
    
    [[BluetoothManager share] readHistroySportData];
    [self firstRefreshSportDataSuccess:notification];
    
}

- (void)refreshSportDataError:(NSNotification *)notification {
    [self releaseTimer];
    _isLoading = NO;
    _refreshBututton.userInteractionEnabled = YES;
    [MBProgressHUD showHUDByContent:BTLocalizedString(@"同步失败") view:UI_Window afterDelay:1.5];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_refreshBututton.layer removeAllAnimations];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
}

- (void)firstRefreshSportDataSuccess:(NSNotification *)notification {
    [self releaseTimer];
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
    NSInteger compeleteRate = (NSInteger)(completionRateFloat) / 1;
    NSString *completionRate = [NSString stringWithFormat:@"%ld",compeleteRate];
    completionRate = [NSString stringWithFormat:@"%@ %@%%",BTLocalizedString(@"完成"),_sportModel?completionRate:@(0).stringValue];
    _complateValue.text = completionRate;
    
//    _complateStep.text = [NSString stringWithFormat:@"%@",@(_sportModel.step).stringValue];
    
    NSString *tempStr = [NSString stringWithFormat:@"%@",@(_sportModel.step).stringValue];
    NSRange range = NSMakeRange(0, tempStr.length == 0?1:tempStr.length);
    NSMutableAttributedString *stepStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ ",tempStr,BTLocalizedString(@"步")]];
    [stepStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:28],NSForegroundColorAttributeName:[UIColor blackColor]}
                     range:range];
    
    _complateStep.attributedText = stepStr;
    
    if (_stepCount) {
        NSString *target = [NSString stringWithFormat:@"%@ %@",BTLocalizedString(@"目标"),@(_stepCount).stringValue];
        _totalStep.text = target;
    }else{
        _totalStep.text = [NSString stringWithFormat:@"%@ 10000",BTLocalizedString(@"目标")];
    }
    
    [_circleChart updateChartByCurrent:@(completionRateFloat)];
    
    _lblBoxoneValue.text = [NSString stringWithFormat:@"%@",_sportModel?@(_sportModel.step).stringValue:@(0).stringValue];
    _lblBoxtwoValue.text = [NSString stringWithFormat:@"%.2lf",(_sportModel?_sportModel.step * [CurrentUser.stepLong floatValue]:0)*0.00001];
    _lblBoxthreeValue.text = [NSString stringWithFormat:@"%.2f",_sportModel?(long)(([CurrentUser.weight floatValue] * _sportModel.distance*0.01 * 1.036 * 0.001) * 100)/ 100.0:0];
    
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
    
    //上传运动数据
//    NSString *stepData = [DBManager selectHistorySportData];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"运动数据" message:stepData delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//    [alert show];
//    [_operateVM saveStepData:[DBManager selectHistorySportData]];
    
}

//设备解除绑定,所有数据清零
- (void)removeDevice {
    [_circleChart updateChartByCurrent:@(0)];
    
    NSString *completionRate = [NSString stringWithFormat:@"%@0%%",BTLocalizedString(@"完成")];
    _complateValue.text = completionRate;
    NSString *tempStr = [NSString stringWithFormat:@"%@",@"0"];
    NSRange range = NSMakeRange(0, tempStr.length == 0?1:tempStr.length);
    NSMutableAttributedString *stepStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ ",tempStr,BTLocalizedString(@"步")]];
    [stepStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:28],NSForegroundColorAttributeName:[UIColor blackColor]}
                     range:range];
    
    _complateStep.attributedText = stepStr;
    
    _lblBoxoneValue.text = @"0";
    _lblBoxtwoValue.text = @"0";
    _lblBoxthreeValue.text = @"0";
    _lblBoxFourValue.text = @"0";
    _electricity.width = 0;
    _electricityPercent.text = @"0%";
    
}

- (void)registerSOSNotification
{
    
}

- (void)disConnectPeripheral {
    [_refreshBututton.layer removeAllAnimations];
    _refreshBututton.userInteractionEnabled = YES;
    [self releaseTimer];
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

- (BOOL)systemLanguageIsEnglish
{
    if ([(AppDelegate *)[UIApplication sharedApplication].delegate languageIndex] == 0) {
        //获取系统当前语言版本（中文zh-Hans,英文en)
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *currentLanguage = [languages objectAtIndex:0];
        if ([currentLanguage isEqualToString:@"en-US"] ||[currentLanguage isEqualToString:@"en-CN"]) {
            return YES;
        }else{
            return NO;
        }
    }
    else if ([(AppDelegate *)[UIApplication sharedApplication].delegate languageIndex] == 1) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void)changeLanguage:(NSNotification *)notification {
    self.title = [NSString stringWithFormat:@"%@",BTLocalizedString(@"运动")];
    [self firstRefreshSportDataSuccess:nil];
    lblBoxoneText.text = [NSString stringWithFormat:@"%@",BTLocalizedString(@"当天步数")];
    lblBoxtwoText.text = [NSString stringWithFormat:@"%@",BTLocalizedString(@"活动距离")];
    lblBoxthreeText.text = [NSString stringWithFormat:@"%@",BTLocalizedString(@"消耗能量")];
    lblBoxFourText.text = [NSString stringWithFormat:@"%@",BTLocalizedString(@"脂肪燃烧")];
    _lblBoxOneTextUnit.text = [NSString stringWithFormat:@"%@",BTLocalizedString(@"(步)")];
    NSString *tempStr = [NSString stringWithFormat:@"%@",@(_sportModel.step).stringValue];
    NSRange range = NSMakeRange(0, tempStr.length == 0?1:tempStr.length);
    NSMutableAttributedString *stepStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ ",tempStr,BTLocalizedString(@"步")]];
    [stepStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:28],NSForegroundColorAttributeName:[UIColor blackColor]}
                     range:range];
    
    _complateStep.attributedText = stepStr;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
