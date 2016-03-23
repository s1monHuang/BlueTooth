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

@interface SportCtrl ()

@property (strong,nonatomic) UIView *chartView;
@property (strong,nonatomic) UIView *circleBgView;

@property (strong,nonatomic) UIView *footerView;

@property (nonatomic) PNCircleChart * circleChart;

@property (nonatomic) UILabel *complateValue;
@property (nonatomic) UILabel *complateStep;
@property (nonatomic) UILabel *totalStep;

@property (nonatomic,strong) OperateViewModel *operateVM;

@end

@implementation SportCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"运动";
    self.view.backgroundColor = kThemeGrayColor;
    
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
                                                    current:@32
                                                  clockwise:YES shadow:YES shadowColor:[UIColor whiteColor]];
    
    self.circleChart.backgroundColor = [UIColor clearColor];
    self.circleChart.lineWidth = @20;
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
    _complateValue.text = @"完成率72%";
    _complateValue.textAlignment = NSTextAlignmentCenter;
    _complateValue.textColor = [UIColor blackColor];
    [tempView addSubview:_complateValue];
    
    _complateStep = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 60 - 22*2)/2+35,tempView.frame.size.width, 30)];
    _complateStep.text = @"140526";
    _complateStep.font = [UIFont systemFontOfSize:28];
    _complateStep.textAlignment = NSTextAlignmentCenter;
    _complateStep.textColor = [UIColor blackColor];
    [tempView addSubview:_complateStep];
    
    _totalStep = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 60 - 22*2)/2+35*2+10,tempView.frame.size.width, 20)];
    _totalStep.text = @"目标 150526";
    _totalStep.textAlignment = NSTextAlignmentCenter;
    _totalStep.textColor = [UIColor blackColor];
    [tempView addSubview:_totalStep];
    
    UIImageView *threeBox = [[UIImageView alloc] initWithFrame:CGRectMake(10, ScreenHeight - 138 - 88, ScreenWidth - 20, 88)];
    threeBox.image = [UIImage imageNamed:@"threebox"];
    [self.view addSubview:threeBox];
    
    CGFloat boxWidth = ScreenWidth - 20;
    
    // 步数
    UILabel *lblBoxoneValue = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, boxWidth/3, 22)];
    lblBoxoneValue.textAlignment = NSTextAlignmentCenter;
    lblBoxoneValue.font = [UIFont systemFontOfSize:22];
    lblBoxoneValue.text = @"140526";
    [threeBox addSubview:lblBoxoneValue];
    
    UILabel *lblBoxoneText = [[UILabel alloc] initWithFrame:CGRectMake(0, 20+22+10, boxWidth/3, 22)];
    lblBoxoneText.textAlignment = NSTextAlignmentCenter;
    lblBoxoneText.font = [UIFont systemFontOfSize:12];
    lblBoxoneText.text = @"当天步数(步)";
    [threeBox addSubview:lblBoxoneText];
    
    // 距离
    UILabel *lblBoxtwoValue = [[UILabel alloc] initWithFrame:CGRectMake(boxWidth/3, 20, boxWidth/3, 22)];
    lblBoxtwoValue.textAlignment = NSTextAlignmentCenter;
    lblBoxtwoValue.font = [UIFont systemFontOfSize:22];
    lblBoxtwoValue.text = @"10.8";
    [threeBox addSubview:lblBoxtwoValue];
    
    UILabel *lblBoxtwoText = [[UILabel alloc] initWithFrame:CGRectMake(boxWidth/3, 20+22+10, boxWidth/3, 22)];
    lblBoxtwoText.textAlignment = NSTextAlignmentCenter;
    lblBoxtwoText.font = [UIFont systemFontOfSize:12];
    lblBoxtwoText.text = @"活动距离(km)";
    [threeBox addSubview:lblBoxtwoText];
    
    // 距离
    UILabel *lblBoxthreeValue = [[UILabel alloc] initWithFrame:CGRectMake(boxWidth/3*2, 20, boxWidth/3, 22)];
    lblBoxthreeValue.textAlignment = NSTextAlignmentCenter;
    lblBoxthreeValue.font = [UIFont systemFontOfSize:22];
    lblBoxthreeValue.text = @"10086";
    [threeBox addSubview:lblBoxthreeValue];
    
    UILabel *lblBoxthreeText = [[UILabel alloc] initWithFrame:CGRectMake(boxWidth/3*2, 20+22+10, boxWidth/3, 22)];
    lblBoxthreeText.textAlignment = NSTextAlignmentCenter;
    lblBoxthreeText.font = [UIFont systemFontOfSize:12];
    lblBoxthreeText.text = @"消耗能量(kCall)";
    [threeBox addSubview:lblBoxthreeText];
    
    [self performSelector:@selector(updateData) withObject:self afterDelay:2.5];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
