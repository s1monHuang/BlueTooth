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

@interface StepLongController () <ZHRulerViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic , strong) UILabel *stepLabel;

@property (nonatomic , strong) ZHRulerView *rulerView;

@property (nonatomic , strong) UIView *footView;

@property (nonatomic , assign) NSInteger first;

@property (nonatomic , strong) NSString *stepLongStr;


@end

@implementation StepLongController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"步长";
    self.view.backgroundColor = kThemeGrayColor;
    self.navigationItem.leftBarButtonItem.title = @"";
    
    CGFloat tempX = kScreenWidth > 320 ? 40 : 50;
    CGFloat labelX = self.view.width / 2 - tempX;
    CGFloat labelY = 30;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, 50, 40)];
    label.text = @"步长";
    [self.view addSubview:label];
    
    CGFloat stepLabelX = CGRectGetMaxX(label.frame);
    UILabel *stepLabel = [[UILabel alloc] initWithFrame:CGRectMake(stepLabelX, labelY, 60, 40)];
    _stepLabel = stepLabel;
    stepLabel.text = [CurrentUser.stepLong isEqualToString:@"(null)"] ? @"70" : CurrentUser.stepLong;
    stepLabel.font = [UIFont systemFontOfSize:25];
    stepLabel.textColor = KThemeGreenColor;
    [self.view addSubview:stepLabel];
    
    CGFloat otherLabelX = CGRectGetMaxX(stepLabel.frame);
    UILabel *otherLabel = [[UILabel alloc] initWithFrame:CGRectMake(otherLabelX, labelY, 30, 40)];
    otherLabel.text = @"cm";
    otherLabel.textColor = KThemeGreenColor;
    [self.view addSubview:otherLabel];
    
    //设置脚印
    [self setUpFootView];
    
    //设置步长尺子
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
    button.accessibilityLabel = @"返回";
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
    }else{
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           30,
                                                                           44)];
        [rightButton setTitle:
         @"完成"forState:UIControlStateNormal];
        [rightButton addTarget:self
                        action:@selector(PushToVC)
              forControlEvents:UIControlEventTouchUpInside];
        rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        rightButton.accessibilityLabel = @"完成";
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = rightBarButton;
    }
}


- (void)setUpFootView
{
    CGFloat imageViewX = 45;
    CGFloat imageViewY = kScreenHeight > 480 ? 150 : 120;
    CGFloat imageViewW = 80;
    CGFloat imageViewH = kScreenHeight > 480 ? 250 : 200;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH)];
    _footView = footView;
    _footView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_footView];
    
    UIImageView *rightFoot = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0 , imageViewW, imageViewH)];
    rightFoot.image = [UIImage imageNamed:@"jiaochicun"];
    [_footView addSubview:rightFoot];
   
}

- (void)setUpRulerView
{
    CGFloat rulerX = kScreenWidth / 2 + 20;
    CGFloat tempY = kScreenHeight > 480 ? 20 : 10;
    CGFloat rulerY = CGRectGetMaxY(_stepLabel.frame) + tempY;
    CGFloat rulerWidth = kScreenWidth / 2 - 60;
    CGFloat rulerHeight = kScreenHeight > 480 ? 350 : 250;
    
    CGRect rulerFrame = CGRectMake(rulerX, rulerY, rulerWidth, rulerHeight);
    
    ZHRulerView *rulerView = [[ZHRulerView alloc] initWithMixNuber:2 maxNuber:85 showType:rulerViewshowVerticalType rulerMultiple:1];
    _rulerView = rulerView;
    rulerView.round = YES;
    rulerView.backgroundColor = [UIColor whiteColor];
    rulerView.defaultVaule = [[CurrentUser.stepLong isEqualToString:@"(null)"] ? @"70" : CurrentUser.stepLong integerValue];
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
    _stepLongStr = _stepLabel.text;
    if (_first == 1) {
        TrainTargetController *VC = [[TrainTargetController alloc] init];
        CurrentUser.stepLong = _stepLongStr;
        [self.navigationController pushViewController:VC animated:YES];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:steoLongIsChangeNotification object:_stepLongStr];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - rulerviewDelagete
-(void)getRulerValue:(CGFloat)rulerValue withScrollRulerView:(ZHRulerView *)rulerView{
    NSString *valueStr =[NSString stringWithFormat:@"%.0f",rulerValue];
    _stepLabel.text = valueStr;
  
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
