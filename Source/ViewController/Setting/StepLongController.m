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
    
    ZHRulerView *rulerView = [[ZHRulerView alloc] initWithMixNuber:20 maxNuber:120 showType:rulerViewshowVerticalType rulerMultiple:10];
    _rulerView = rulerView;
    rulerView.backgroundColor = [UIColor whiteColor];
    rulerView.defaultVaule = 70;
    rulerView.delegate = self;
    rulerView.frame = rulerFrame;
    
    [self.view addSubview:rulerView];
    
    
}

#pragma mark - rulerviewDelagete
-(void)getRulerValue:(CGFloat)rulerValue withScrollRulerView:(ZHRulerView *)rulerView{
    NSString *valueStr =[NSString stringWithFormat:@"%.0f",rulerValue];
    _stepLabel.text = valueStr;
    NSString *stepLongStr = [NSString stringWithFormat:@"%@cm",valueStr];
    CurrentUser.stepLong = stepLongStr;
//    [[NSNotificationCenter defaultCenter] postNotificationName:stepLongNotification object:stepLongStr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
