//
//  StepLongController.m
//  BlueToothBracelet
//
//  Created by azz on 16/3/21.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "StepLongController.h"
#import "ZHRulerView.h"
#import "StepLongView.h"
#import "TrainTargetController.h"

@interface StepLongController () <ZHRulerViewDelegate>

@property (nonatomic , strong) UILabel *stepLabel;

@property (nonatomic , strong) ZHRulerView *rulerView;

@property (nonatomic , strong) UIView *footView;

@end

@implementation StepLongController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"步长";
    self.view.backgroundColor = kThemeGrayColor;
    self.navigationItem.leftBarButtonItem.title = @"";
    
    CGFloat labelX = self.view.width / 2 - 40;
    CGFloat labelY = 30;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, 50, 40)];
    label.text = @"步长";
    [self.view addSubview:label];
    
    CGFloat stepLabelX = CGRectGetMaxX(label.frame) + 10;
    UILabel *stepLabel = [[UILabel alloc] initWithFrame:CGRectMake(stepLabelX, labelY, 40, 40)];
    _stepLabel = stepLabel;
    stepLabel.text = @"70";
    stepLabel.font = [UIFont systemFontOfSize:22];
    stepLabel.textColor = KThemeGreenColor;
    [self.view addSubview:stepLabel];
    
    CGFloat otherLabelX = CGRectGetMaxX(stepLabel.frame) + 10;
    UILabel *otherLabel = [[UILabel alloc] initWithFrame:CGRectMake(otherLabelX, labelY, 30, 40)];
    otherLabel.text = @"cm";
    otherLabel.textColor = KThemeGreenColor;
    [self.view addSubview:otherLabel];
    
    //设置脚印
    [self setUpFootView];
    
    //设置步长尺子
    [self setUpRulerView];
    
    UIButton *btnPre = [[UIButton alloc] initWithFrame:CGRectMake(0, ScreenHeight - 50 - 64, ScreenWidth/2, 50)];
    [btnPre addTarget:self action:@selector(btnPreClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnPre setTitle:@"上一步" forState:UIControlStateNormal];
    [btnPre setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnPre setBackgroundImage:[UIImage imageNamed:@"square-button2"] forState:UIControlStateNormal];
    [self.view addSubview:btnPre];
    
    UIButton *btnNext = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2, ScreenHeight - 50 - 64, ScreenWidth/2, 50)];
    [btnNext addTarget:self action:@selector(btnNextClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnNext setTitle:@"下一步" forState:UIControlStateNormal];
    [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNext setBackgroundImage:[UIImage imageNamed:@"square-button1"] forState:UIControlStateNormal];
    [self.view addSubview:btnNext];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSInteger first = [[[NSUserDefaults standardUserDefaults] objectForKey:@"firstDownload"] integerValue];
    if (first == 1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.size = CGSizeMake(40, 40);
        button.alpha = 0;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = item;
    }
    
}


- (void)setUpFootView
{
    CGFloat imageViewX = 30;
    CGFloat imageViewY = 150;
    CGFloat imageViewW = 40;
    CGFloat imageViewH = 60;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(imageViewX, imageViewY, 120, 200)];
    _footView = footView;
    _footView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_footView];
    
    StepLongView *stepLongView = [[StepLongView alloc] initWithFrame:CGRectMake(30, 0 , 60, 140)];
    stepLongView.backgroundColor = [UIColor clearColor];
    [_footView addSubview:stepLongView];
    
    UIImageView *rightFoot = [[UIImageView alloc] initWithFrame:CGRectMake(80, 0, imageViewW, imageViewH)];
    rightFoot.image = [UIImage imageNamed:@"pic-foot"];
    [_footView addSubview:rightFoot];
    
    UIImageView *leftFoot = [[UIImageView alloc] initWithFrame:CGRectMake(0, 140, imageViewW, imageViewH)];
    leftFoot.image = [UIImage imageNamed:@"pic-foot"];
    [_footView addSubview:leftFoot];
   
}

- (void)setUpRulerView
{
    CGFloat rulerX = kScreenWidth / 2 + 20;
    CGFloat rulerY = CGRectGetMaxY(_stepLabel.frame) + 20;
    CGFloat rulerWidth = kScreenWidth / 2 - 60;
    CGFloat rulerHeight = kScreenHeight > 480 ? 350 : 300;
    
    CGRect rulerFrame = CGRectMake(rulerX, rulerY, rulerWidth, rulerHeight);
    
    ZHRulerView *rulerView = [[ZHRulerView alloc] initWithMixNuber:20 maxNuber:85 showType:rulerViewshowVerticalType rulerMultiple:10];
    _rulerView = rulerView;
    rulerView.backgroundColor = [UIColor whiteColor];
    rulerView.defaultVaule = 50;
    rulerView.delegate = self;
    rulerView.frame = rulerFrame;
    
    [self.view addSubview:rulerView];
    
    
}

- (void)btnPreClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnNextClick:(id)sender
{
    
    [self PushToVC];
}

- (void)rightBarButtonClick:(id)sender
{
    [self PushToVC];
}

- (void)PushToVC
{
    TrainTargetController *VC = [[TrainTargetController alloc] init];
    //    VC.isJump = self.isJump;
    [self.navigationController pushViewController:VC animated:YES];
}


#pragma mark - rulerviewDelagete
-(void)getRulerValue:(CGFloat)rulerValue withScrollRulerView:(ZHRulerView *)rulerView{
    NSString *valueStr =[NSString stringWithFormat:@"%.0f",rulerValue];
    _stepLabel.text = valueStr;
    NSString *stepLongStr = [NSString stringWithFormat:@"%@cm",valueStr];
    CurrentUser.stepLong = stepLongStr;
    
    //修改数据库信息
    BasicInfomationModel *changeModel = [DBManager selectBasicInfomation];
    changeModel.distance = [valueStr integerValue];
    BOOL change = [DBManager insertOrReplaceBasicInfomation:changeModel];
    if (!change) {
        DLog(@"修改步长失败");
    }

//    [[NSNotificationCenter defaultCenter] postNotificationName:stepLongNotification object:stepLongStr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
