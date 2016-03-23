//
//  WeightViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/12.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "WeightViewController.h"
#import "RecommendViewController.h"
#import "ZHRulerView.h"

@interface WeightViewController () <ZHRulerViewDelegate>

@property (nonatomic , strong) ZHRulerView *rulerView;

@property (nonatomic , strong) UILabel *weightLabel;



@end

@implementation WeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"我的资料";
    self.view.backgroundColor = kThemeGrayColor;
    
    // 设置
    UIBarButtonItem *rightBarButton=[[UIBarButtonItem alloc] initWithTitle:@"跳过" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick:)];
    if(self.isJump)
        self.navigationItem.rightBarButtonItem = rightBarButton;
    
    CGFloat labelX = self.view.width / 2 - 60;
    CGFloat labelY = 30;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, 50, 40)];
    label.text = @"体重";
    [self.view addSubview:label];
    
    CGFloat weightLabelX = CGRectGetMaxX(label.frame) + 10;
    UILabel *weightLabel = [[UILabel alloc] initWithFrame:CGRectMake(weightLabelX, labelY, 40, 40)];
    _weightLabel = weightLabel;
    weightLabel.text = @"50";
    weightLabel.font = [UIFont systemFontOfSize:22];
    weightLabel.textColor = KThemeGreenColor;
    [self.view addSubview:weightLabel];
    
    CGFloat otherLabelX = CGRectGetMaxX(weightLabel.frame) + 10;
    UILabel *otherLabel = [[UILabel alloc] initWithFrame:CGRectMake(otherLabelX, labelY, 30, 40)];
    otherLabel.text = @"kg";
    otherLabel.textColor = KThemeGreenColor;
    [self.view addSubview:otherLabel];
    
    NSString *sexNamed = [CurrentUser.sex isEqualToString:@"男"]?@"man3":@"woman3";
    CGFloat heightViewHeight = kScreenHeight > 480 ? 260 : 220;
    UIImageView *heightView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 70)/2, 80, 70, heightViewHeight)];
    heightView.image = [UIImage imageNamed:sexNamed];
    [self.view addSubview:heightView];
    
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
    
    [self setUpRulerView];
    
}

- (void)setUpRulerView
{
    CGFloat rulerX = 20;
    CGFloat rulerY = kScreenHeight > 480 ? kScreenHeight - 220 : kScreenHeight - 180;
    CGFloat rulerWidth = kScreenWidth  - 40;
    CGFloat rulerHeight = 60;
    
    CGRect rulerFrame = CGRectMake(rulerX, rulerY, rulerWidth, rulerHeight);
    
    ZHRulerView *rulerView = [[ZHRulerView alloc] initWithMixNuber:20 maxNuber:220 showType:rulerViewshowHorizontalType rulerMultiple:10];
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

- (void)PushToVC{
    
    RecommendViewController *VC = [[RecommendViewController alloc] init];
    VC.isJump = self.isJump;
    [self.navigationController pushViewController:VC animated:YES];
    
}

#pragma mark - rulerviewDelagete
-(void)getRulerValue:(CGFloat)rulerValue withScrollRulerView:(ZHRulerView *)rulerView{
    NSString *valueStr =[NSString stringWithFormat:@"%.0f",rulerValue];
    _weightLabel.text = valueStr;
    NSString *weightStr = [NSString stringWithFormat:@"%@kg",valueStr];
    CurrentUser.weight = weightStr;
//    [[NSNotificationCenter defaultCenter] postNotificationName:weightNotification object:weightStr];
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
