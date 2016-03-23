//
//  HeightViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/12.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "HeightViewController.h"
#import "WeightViewController.h"
#import "ZHRulerView.h"

@interface HeightViewController () <ZHRulerViewDelegate>

@property (nonatomic , strong) UILabel *heightLabel;

@property (nonatomic , strong) ZHRulerView *rulerView;


@end

@implementation HeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"我的资料";
    self.view.backgroundColor = kThemeGrayColor;
    
    // 设置
    UIBarButtonItem *rightBarButton=[[UIBarButtonItem alloc] initWithTitle:@"跳过" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick:)];
    if(self.isJump)
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    CGFloat labelX = self.view.width / 2 - 50;
    CGFloat labelY = 20;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, 50, 40)];
    label.text = @"身高";
    [self.view addSubview:label];
    
    CGFloat heightLabelX = CGRectGetMaxX(label.frame) + 10;
    UILabel *heightLabel = [[UILabel alloc] initWithFrame:CGRectMake(heightLabelX, labelY, 40, 40)];
    _heightLabel = heightLabel;
    heightLabel.text = @"170";
    heightLabel.font = [UIFont systemFontOfSize:22];
    heightLabel.textColor = KThemeGreenColor;
    [self.view addSubview:heightLabel];
    
    CGFloat otherLabelX = CGRectGetMaxX(heightLabel.frame) + 10;
    UILabel *otherLabel = [[UILabel alloc] initWithFrame:CGRectMake(otherLabelX, labelY, 30, 40)];
    otherLabel.text = @"cm";
    otherLabel.textColor = KThemeGreenColor;
    [self.view addSubview:otherLabel];
    
    NSString *sexNamed = [CurrentUser.sex isEqualToString:@"男"]?@"man2":@"woman2";
    
    CGFloat heightViewHeight = kScreenHeight > 480 ? 350 : 280;
    UIImageView *heightView = [[UIImageView alloc] initWithFrame:CGRectMake(48, 80, 100, heightViewHeight)];
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
    
    //创建尺子
    [self setUpRulerView];
    
}

- (void)setUpRulerView
{
    CGFloat rulerX = kScreenWidth / 2 + 20;
    CGFloat rulerY = CGRectGetMaxY(_heightLabel.frame) + 10;
    CGFloat rulerWidth = kScreenWidth / 2 - 60;
    CGFloat rulerHeight = kScreenHeight > 480 ? 350 : 280;
    
    CGRect rulerFrame = CGRectMake(rulerX, rulerY, rulerWidth, rulerHeight);
    
    ZHRulerView *rulerView = [[ZHRulerView alloc] initWithMixNuber:120 maxNuber:220 showType:rulerViewshowVerticalType rulerMultiple:10];
    _rulerView = rulerView;
    rulerView.backgroundColor = [UIColor whiteColor];
    rulerView.defaultVaule = 170;
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
    WeightViewController *VC = [[WeightViewController alloc] init];
    VC.isJump = self.isJump;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - rulerviewDelagete
-(void)getRulerValue:(CGFloat)rulerValue withScrollRulerView:(ZHRulerView *)rulerView{
    NSString *valueStr =[NSString stringWithFormat:@"%.0f",rulerValue];
    _heightLabel.text = valueStr;
    NSString *heightStr = [NSString stringWithFormat:@"%@cm",valueStr];
    CurrentUser.high = heightStr;
    
    //修改数据库信息
    BasicInfomationModel *changeModel = [DBManager selectBasicInfomation];
    changeModel.height = [valueStr integerValue];
    BOOL change = [DBManager insertOrReplaceBasicInfomation:changeModel];
    if (!change) {
        DLog(@"修改身高失败");
    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:heightNotification object:heightStr];
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
