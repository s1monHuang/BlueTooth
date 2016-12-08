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

@property (nonatomic , strong) UILabel *stepLonglabel;

@property (nonatomic , assign) BOOL isEnglish;



@end

@implementation StepLongController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = BTLocalizedString(@"我的资料");
    self.view.backgroundColor = kThemeGrayColor;
    self.navigationItem.leftBarButtonItem.title = @"";
    _isEnglish = [self systemLanguageIsEnglish];
    CGFloat tempX = 0;
    if (_isEnglish) {
        tempX = kScreenWidth > 320 ? 110 : 100;
    }else{
        tempX = kScreenWidth > 320 ? 140 : 140;
    }
    
    CGFloat labelX = self.view.width / 2 - tempX;
    CGFloat labelY = 30;
    _stepLonglabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, 120, 40)];
    _stepLonglabel.text = BTLocalizedString(@"步长");
    _stepLonglabel.textAlignment = NSTextAlignmentRight;
//    label.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:_stepLonglabel];
    
    CGFloat stepLabelX = CGRectGetMaxX(_stepLonglabel.frame);
    UILabel *stepLabel = [[UILabel alloc] initWithFrame:CGRectMake(stepLabelX +10, labelY, 200, 40)];
    _stepLabel = stepLabel;
    _stepLabel.textAlignment = NSTextAlignmentLeft;
    _stepLabel.textColor = KThemeGreenColor;
    _stepLabel.font = [UIFont systemFontOfSize:20];
    NSString *tempStr = [CurrentUser.stepLong isEqualToString:@"(null)"] ? @"50" : CurrentUser.stepLong;
    _stepLongStr = tempStr;
    NSRange range = NSMakeRange(0, tempStr.length);
    NSMutableAttributedString *stepStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@cm",tempStr]];
    [stepStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:28],NSForegroundColorAttributeName:KThemeGreenColor}
                       range:range];
    _stepLabel.attributedText = stepStr;
    [self.view addSubview:stepLabel];
    
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
    rulerView.defaultVaule = [[CurrentUser.stepLong isEqualToString:@"(null)"] ? @"50" : CurrentUser.stepLong integerValue];
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
    _stepLongStr = valueStr;
    NSRange range = NSMakeRange(0, valueStr.length);
    NSMutableAttributedString *stepStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@cm",valueStr]];
    [stepStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:28],NSForegroundColorAttributeName:KThemeGreenColor}
                     range:range];
    _stepLabel.attributedText = stepStr;
  
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
