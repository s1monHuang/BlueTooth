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

@interface HeightViewController () <ZHRulerViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic , strong) UILabel *heightLabel;

@property (nonatomic , strong) ZHRulerView *rulerView;

@property (nonatomic , assign) NSInteger first;

@property (nonatomic , strong) NSString *heightStr;



@end

@implementation HeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = BTLocalizedString(@"我的资料");
    self.view.backgroundColor = kThemeGrayColor;
    self.navigationItem.leftBarButtonItem.title = @"";
    
    CGFloat labelX = self.view.width / 2 - 100;
    CGFloat labelY = 20;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, 70, 40)];
    label.textAlignment = NSTextAlignmentRight;
    label.text = BTLocalizedString(@"身高");
    [self.view addSubview:label];
    
    CGFloat heightLabelX = CGRectGetMaxX(label.frame);
    UILabel *heightLabel = [[UILabel alloc] initWithFrame:CGRectMake(heightLabelX+5, labelY, 200, 40)];
    _heightLabel = heightLabel;
    heightLabel.textAlignment = NSTextAlignmentLeft;
    heightLabel.font = [UIFont systemFontOfSize:20];
    NSString *tempStr = [CurrentUser.high isEqualToString:@"(null)"] ? @"100" : CurrentUser.high;
    _heightStr = tempStr;
    NSRange range = NSMakeRange(0, tempStr.length);
    NSMutableAttributedString *heightStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ cm",tempStr]];
    [heightStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:28],NSForegroundColorAttributeName:KThemeGreenColor}
                                 range:range];
    _heightLabel.attributedText = heightStr;
    
    [self.view addSubview:heightLabel];
    
    NSString *sexNamed = [CurrentUser.sex isEqualToString:BTLocalizedString(@"男")]?@"man2":@"woman2";
    CGFloat heightViewHeight = kScreenHeight > 480 ? 350 : 280;
    UIImageView *heightView = [[UIImageView alloc] initWithFrame:CGRectMake(48, 80, 100, heightViewHeight)];
    heightView.image = [UIImage imageNamed:sexNamed];
    [self.view addSubview:heightView];
    
    //创建尺子
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
    CGFloat rulerX = kScreenWidth / 2 + 20;
    CGFloat rulerY = CGRectGetMaxY(_heightLabel.frame) + 10;
    CGFloat rulerWidth = kScreenWidth / 2 - 60;
    CGFloat rulerHeight = kScreenHeight > 480 ? 350 : 280;
    
    CGRect rulerFrame = CGRectMake(rulerX, rulerY, rulerWidth, rulerHeight);
    
    ZHRulerView *rulerView = [[ZHRulerView alloc] initWithMixNuber:55 maxNuber:245 showType:rulerViewshowVerticalType rulerMultiple:10];
    _rulerView = rulerView;
    rulerView.backgroundColor = [UIColor whiteColor];
    rulerView.defaultVaule = [[CurrentUser.high isEqualToString:@"(null)"] ? @"100" : CurrentUser.high integerValue];
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
//    _heightStr = _heightLabel.text;
    if (_first == 1) {
        WeightViewController *VC = [[WeightViewController alloc] init];
        CurrentUser.high = _heightStr;
        [self.navigationController pushViewController:VC animated:YES];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:heightIsChangeNotification object:_heightStr];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark - rulerviewDelagete
-(void)getRulerValue:(CGFloat)rulerValue withScrollRulerView:(ZHRulerView *)rulerView{
    if (rulerValue > 250.0) {
        rulerValue = 250;
    }
    if (rulerValue < 0) {
        rulerValue = 0;
    }
    NSString *valueStr =[NSString stringWithFormat:@"%.0f",rulerValue];
    _heightStr = valueStr;
    NSRange range = NSMakeRange(0, valueStr.length);
    NSMutableAttributedString *heightStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ cm",valueStr]];
    [heightStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:28],NSForegroundColorAttributeName:KThemeGreenColor}
                       range:range];
    _heightLabel.attributedText = heightStr;
    
//    //修改数据库信息
//    BasicInfomationModel *changeModel = [DBManager selectBasicInfomation];
//    changeModel.height = [valueStr integerValue];
//    BOOL change = [DBManager insertOrReplaceBasicInfomation:changeModel];
//    if (!change) {
//        DLog(@"修改身高失败");
//    }
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
