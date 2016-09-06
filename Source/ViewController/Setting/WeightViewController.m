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
#import "StepLongController.h"

@interface WeightViewController () <ZHRulerViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic , strong) ZHRulerView *rulerView;

@property (nonatomic , strong) UILabel *weightLabel;

@property (nonatomic , assign) NSInteger first;

@property (nonatomic , strong) NSString *weightStr;


@end

@implementation WeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = BTLocalizedString(@"我的资料");
    self.view.backgroundColor = kThemeGrayColor;
    self.navigationItem.leftBarButtonItem.title = @"";
    
    CGFloat labelX = self.view.width / 2 - 100;
    CGFloat labelY = 30;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, 70, 40)];
    label.text = BTLocalizedString(@"体重");
    label.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:label];
    
    CGFloat weightLabelX = CGRectGetMaxX(label.frame);
    UILabel *weightLabel = [[UILabel alloc] initWithFrame:CGRectMake(weightLabelX+10, labelY, 200, 40)];
    _weightLabel = weightLabel;
    weightLabel.textAlignment = NSTextAlignmentLeft;
    weightLabel.font = [UIFont systemFontOfSize:20];
    NSString *tempStr = [CurrentUser.weight isEqualToString:@"(null)"] ? @"50" : CurrentUser.weight;
    _weightStr = tempStr;
    NSRange range = NSMakeRange(0, tempStr.length);
    NSMutableAttributedString *weightStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ kg",tempStr]];
    [weightStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:28],NSForegroundColorAttributeName:KThemeGreenColor}
                       range:range];
    weightLabel.attributedText = weightStr;
    [self.view addSubview:weightLabel];
    
    NSString *sexNamed = [CurrentUser.sex isEqualToString:BTLocalizedString(@"男")]?@"man3":@"woman3";
    CGFloat heightViewHeight = kScreenHeight > 480 ? 260 : 220;
    UIImageView *heightView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 70)/2, 80, 70, heightViewHeight)];
    heightView.image = [UIImage imageNamed:sexNamed];
    [self.view addSubview:heightView];
    
    
    
    [self setUpRulerView];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  30,
                                                                  44)];
    [button setTitle:nil forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_btn_back_nor"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_btn_back_pre"] forState:UIControlStateHighlighted];
    [button addTarget:self
               action:@selector(PushToVC)
     forControlEvents:UIControlEventTouchUpInside];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    button.accessibilityLabel = BTLocalizedString(@"返回");
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _first = [[[NSUserDefaults standardUserDefaults] objectForKey:FIRSTDOWNLAOD] integerValue];
    if (_first == 1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.size = CGSizeMake(40, 40);
        button.alpha = 0;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = item;
        
        UIButton *btnPre = [[UIButton alloc] initWithFrame:CGRectMake(0, ScreenHeight - 50 - 64, ScreenWidth/2, 50)];
        [btnPre addTarget:self action:@selector(btnPreClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnPre setTitle:BTLocalizedString(@"上一步") forState:UIControlStateNormal];
        [btnPre setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnPre setBackgroundImage:[UIImage imageNamed:@"square-button2"] forState:UIControlStateNormal];
        [self.view addSubview:btnPre];
        
        UIButton *btnNext = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2, ScreenHeight - 50 - 64, ScreenWidth/2, 50)];
        [btnNext addTarget:self action:@selector(btnNextClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnNext setTitle:BTLocalizedString(@"下一步") forState:UIControlStateNormal];
        [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnNext setBackgroundImage:[UIImage imageNamed:@"square-button1"] forState:UIControlStateNormal];
        [self.view addSubview:btnNext];
    }else{
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           50,
                                                                           44)];
        [rightButton setTitle:
         BTLocalizedString(@"完成") forState:UIControlStateNormal];
        [rightButton addTarget:self
                        action:@selector(PushToVC)
              forControlEvents:UIControlEventTouchUpInside];
        rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        rightButton.accessibilityLabel = BTLocalizedString(@"完成");
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = rightBarButton;
    }
    
}


- (void)setUpRulerView
{
    CGFloat rulerX = 20;
    CGFloat rulerY = kScreenHeight > 480 ? kScreenHeight - 220 : kScreenHeight - 180;
    CGFloat rulerWidth = kScreenWidth  - 40;
    CGFloat rulerHeight = 60;
    
    CGRect rulerFrame = CGRectMake(rulerX, rulerY, rulerWidth, rulerHeight);
    
    ZHRulerView *rulerView = [[ZHRulerView alloc] initWithMixNuber:2 maxNuber:200 showType:rulerViewshowHorizontalType rulerMultiple:1];
    _rulerView = rulerView;
    rulerView.round = YES;
    rulerView.backgroundColor = [UIColor whiteColor];
    rulerView.defaultVaule = [[CurrentUser.weight isEqualToString:@"(null)"] ? @"50" : CurrentUser.weight integerValue];
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
    
    if (_first == 1) {
        StepLongController *VC = [[StepLongController alloc] init];
        CurrentUser.weight = _weightStr;
        [self.navigationController pushViewController:VC animated:YES];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:weightIsChangeNotification object:_weightStr];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark - rulerviewDelagete
-(void)getRulerValue:(CGFloat)rulerValue withScrollRulerView:(ZHRulerView *)rulerView{
    NSString *valueStr =[NSString stringWithFormat:@"%.0f",rulerValue];
    _weightStr = valueStr;
    NSRange range = NSMakeRange(0, valueStr.length);
    NSMutableAttributedString *weightStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ kg",valueStr]];
    [weightStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:28],NSForegroundColorAttributeName:KThemeGreenColor}
                       range:range];
    _weightLabel.attributedText = weightStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
