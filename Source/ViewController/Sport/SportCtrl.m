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

@property (nonatomic) UIButton *refreshBututton;
@property (nonatomic) UIProgressView *progressView;


@property (nonatomic,strong) SportDataModel *sportModel;

@property (nonatomic,strong) OperateViewModel *operateVM;

@end

@implementation SportCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"运动";
    self.view.backgroundColor = kThemeGrayColor;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshSportDataSuccess:)
                                                 name:READ_SPORTDATA_SUCCESS
                                               object:nil];
    _sportModel = [DBManager selectSportData];
    
    //自动登录
    [self autoDownload];
    
    _chartView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 200)];
    _chartView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_chartView];
    
    _circleBgView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, (_chartView.frame.size.width - 100), (_chartView.frame.size.width - 100))];
    _circleBgView.backgroundColor = [UIColor clearColor];
    [_chartView addSubview:_circleBgView];
    
    self.circleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(50,50.0, _circleBgView.frame.size.width, _circleBgView.frame.size.height)
                                                      total:@100
                                                    current:_sportModel?@(_sportModel.step / _sportModel.target * 100):@(0)
                                                  clockwise:YES shadow:YES shadowColor:[UIColor whiteColor]];
    
    self.circleChart.backgroundColor = [UIColor clearColor];
//    self.circleChart.lineWidth = _sportModel?@(_sportModel.step / _sportModel.target * 100):@(0);
    self.circleChart.lineWidth = @(20);
    [self.circleChart setStrokeColor:[UtilityUI stringTOColor:@"#6dabff"]];
    //[self.circleChart setStrokeColorGradientStart:[UIColor clearColor]];
    [self.circleChart strokeChart];
    [_chartView addSubview:self.circleChart];
    
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(30, 30, self.circleChart.frame.size.width - 60, self.circleChart.frame.size.width - 60)];
    tempView.contentMode = UIViewContentModeScaleAspectFill;
    tempView.clipsToBounds = YES;
    [tempView.layer setCornerRadius:CGRectGetHeight([tempView bounds])/2];
    tempView.layer.masksToBounds = YES;
    tempView.backgroundColor = [UIColor whiteColor];
    [_circleChart addSubview:tempView];
    
    _complateValue = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 60 - 22*2)/2,tempView.frame.size.width, 20)];
    CGFloat completionRateFloat = _sportModel.target?_sportModel.step / (double)_sportModel.target * 100:0;
    NSString *completionRate = [NSString stringWithFormat:@"%0.lf",completionRateFloat];
    completionRate = [NSString stringWithFormat:@"完成率%@%%",_sportModel?completionRate:@(0).stringValue];
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
    NSString *target = [NSString stringWithFormat:@"目标 %@",_sportModel?@(_sportModel.target).stringValue:@(0).stringValue];
    _totalStep.text = target;
    _totalStep.textAlignment = NSTextAlignmentCenter;
    _totalStep.textColor = [UIColor blackColor];
    [tempView addSubview:_totalStep];
    
    UIImageView *threeBox = [[UIImageView alloc] initWithFrame:CGRectMake(10, ScreenHeight - 138 - 88, ScreenWidth - 20, 88)];
    threeBox.image = [UIImage imageNamed:@"threebox"];
    [self.view addSubview:threeBox];
    
    CGFloat boxWidth = ScreenWidth - 20;
    
    // 步数
    _lblBoxoneValue = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, boxWidth/3, 22)];
    _lblBoxoneValue.textAlignment = NSTextAlignmentCenter;
    _lblBoxoneValue.font = [UIFont systemFontOfSize:22];
    _lblBoxoneValue.text = [NSString stringWithFormat:@"%@",_sportModel?@(_sportModel.step).stringValue:@(0).stringValue];
    [threeBox addSubview:_lblBoxoneValue];
    
    UILabel *lblBoxoneText = [[UILabel alloc] initWithFrame:CGRectMake(0, 20+22+10, boxWidth/3, 22)];
    lblBoxoneText.textAlignment = NSTextAlignmentCenter;
    lblBoxoneText.font = [UIFont systemFontOfSize:12];
    lblBoxoneText.text = @"当天步数(步)";
    [threeBox addSubview:lblBoxoneText];
    
    // 距离
    _lblBoxtwoValue = [[UILabel alloc] initWithFrame:CGRectMake(boxWidth/3, 20, boxWidth/3, 22)];
    _lblBoxtwoValue.textAlignment = NSTextAlignmentCenter;
    _lblBoxtwoValue.font = [UIFont systemFontOfSize:22];
    _lblBoxtwoValue.text = [NSString stringWithFormat:@"%@",_sportModel?@(_sportModel.distance).stringValue:@(0).stringValue];
    [threeBox addSubview:_lblBoxtwoValue];
    
    UILabel *lblBoxtwoText = [[UILabel alloc] initWithFrame:CGRectMake(boxWidth/3, 20+22+10, boxWidth/3, 22)];
    lblBoxtwoText.textAlignment = NSTextAlignmentCenter;
    lblBoxtwoText.font = [UIFont systemFontOfSize:12];
    lblBoxtwoText.text = @"活动距离(km)";
    [threeBox addSubview:lblBoxtwoText];
    
    // 消耗能量
    _lblBoxthreeValue = [[UILabel alloc] initWithFrame:CGRectMake(boxWidth/3*2, 20, boxWidth/3, 22)];
    _lblBoxthreeValue.textAlignment = NSTextAlignmentCenter;
    _lblBoxthreeValue.font = [UIFont systemFontOfSize:22];
    _lblBoxthreeValue.text = [NSString stringWithFormat:@"%@",_sportModel?@(_sportModel.calorie).stringValue:@(0).stringValue];
    [threeBox addSubview:_lblBoxthreeValue];
    
    UILabel *lblBoxthreeText = [[UILabel alloc] initWithFrame:CGRectMake(boxWidth/3*2, 20+22+10, boxWidth/3, 22)];
    lblBoxthreeText.textAlignment = NSTextAlignmentCenter;
    lblBoxthreeText.font = [UIFont systemFontOfSize:12];
    lblBoxthreeText.text = @"消耗能量(kCall)";
    [threeBox addSubview:lblBoxthreeText];
    
    _refreshBututton = [[UIButton alloc] initWithFrame:CGRectMake(_circleChart.width + 30,
                                                                  _circleChart.height + _circleChart.y,
                                                                  35,
                                                                  35)];
    [_refreshBututton setBackgroundImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [_refreshBututton addTarget:self
                        action:@selector(refreshSportData)
              forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_refreshBututton];
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(_circleChart.x - 25,
                                                                     _circleChart.height + _circleChart.y + (35 / 2),
                                                                     50,
                                                                     20)];
    _progressView.tintColor = [UIColor greenColor];
    _progressView.progress = _sportModel?_sportModel.battery / 100.0 :0;
    [self.view addSubview:_progressView];
    
}

- (void)autoDownload
{
    
    self.operateVM = [OperateViewModel viewModel];
    @weakify(self);
    
//        [self.operateVM loginWithUserName:self.txtUserAccount.text password:self.txtUserPassword.text];
    
    self.operateVM.finishHandler = ^(BOOL finished, id userInfo) { // 网络数据回调
        @strongify(self);
        if (finished) {
            [[UserManager defaultInstance] saveUser:userInfo];
            
            BasicInfomationModel *infoModel = [[BasicInfomationModel alloc] init];
            infoModel.nickName = CurrentUser.nickName;
            infoModel.gender = CurrentUser.sex;
            infoModel.age = CurrentUser.age;
            infoModel.height = [CurrentUser.high integerValue];
            infoModel.weight = [CurrentUser.weight integerValue];
            infoModel.distance = [CurrentUser.stepLong integerValue];
            BOOL Info = [DBManager insertOrReplaceBasicInfomation:infoModel];
            if (!Info) {
                DLog(@"存入用户信息失败");
            }
            [[AppDelegate defaultDelegate] exchangeRootViewControllerToMain];
            
        } else {
            [self showHUDText:userInfo];
        }
    };
}



- (void)updateData
{
    [self.circleChart updateChartByCurrent:@86];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshSportData {
    if (![[BluetoothManager share] isExistCharacteristic]) {
        return;
    }
    [[BluetoothManager share] readSportData];
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 2;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = NSIntegerMax;
    
    [_refreshBututton.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)refreshSportDataSuccess:(NSNotification *)notification {
    [_refreshBututton.layer removeAllAnimations];
    _sportModel = [notification object];
    
    self.circleChart.lineWidth = _sportModel?@(_sportModel.step / _sportModel.target * 100):@(0);
    
    CGFloat completionRateFloat = _sportModel.target?_sportModel.step / (double)_sportModel.target * 100:0;
    NSString *completionRate = [NSString stringWithFormat:@"%0.lf",completionRateFloat];
    completionRate = [NSString stringWithFormat:@"完成率%@%%",_sportModel?completionRate:@(0).stringValue];
    _complateValue.text = completionRate;
    _complateStep.text = [NSString stringWithFormat:@"%@",@(_sportModel.step).stringValue];
    NSString *target = [NSString stringWithFormat:@"目标 %@",_sportModel?@(_sportModel.target).stringValue:@(0).stringValue];
    _totalStep.text = target;
    
    _lblBoxoneValue.text = [NSString stringWithFormat:@"%@",_sportModel?@(_sportModel.step).stringValue:@(0).stringValue];
    _lblBoxtwoValue.text = [NSString stringWithFormat:@"%@",_sportModel?@(_sportModel.distance).stringValue:@(0).stringValue];
    _lblBoxthreeValue.text = [NSString stringWithFormat:@"%@",_sportModel?@(_sportModel.calorie).stringValue:@(0).stringValue];
    
    _progressView.progress = _sportModel?_sportModel.battery / 100.0 :0;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
