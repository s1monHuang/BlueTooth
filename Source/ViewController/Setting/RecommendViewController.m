//
//  RecommendViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/16.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "RecommendViewController.h"

@interface RecommendViewController ()

@property (strong,nonatomic) UIImageView *pieView;

@end

@implementation RecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"我的资料";
    self.view.backgroundColor = kThemeGrayColor;
    
    UILabel *lblTip = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, ScreenWidth - 15*2, 20)];
    lblTip.text = @"依据您的年龄、身高，我们评估您现在实际的体重如下:";
    lblTip.font = [UIFont systemFontOfSize:13];
    lblTip.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:lblTip];
    
    self.pieView = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 210)/2, 50, 210, 180)];
    self.pieView.image = [UIImage imageNamed:@"scale"];
    [self.view addSubview:self.pieView];
    
    UILabel *lblWeight = [[UILabel alloc] initWithFrame:CGRectMake(65, 55, (210-60)/2, 20)];
    lblWeight.textAlignment = NSTextAlignmentCenter;
    lblWeight.font = [UIFont systemFontOfSize:15];
    lblWeight.text = [NSString stringWithFormat:@"%@",CurrentUser.weight];
    [self.pieView addSubview:lblWeight];
    
    UILabel *lblWeightText = [[UILabel alloc] initWithFrame:CGRectMake(65, 60 + 22, (210-60)/2, 25)];
    lblWeightText.textAlignment = NSTextAlignmentCenter;
    lblWeightText.font = [UIFont boldSystemFontOfSize:24];
    lblWeightText.text = [NSString stringWithFormat:@"%@",@"偏重"];
    [self.pieView addSubview:lblWeightText];
    
    UILabel *lblBZWeight = [[UILabel alloc] initWithFrame:CGRectMake(65, 60 + 52, (210-60)/2, 20)];
    lblBZWeight.textAlignment = NSTextAlignmentCenter;
    lblBZWeight.font = [UIFont boldSystemFontOfSize:14];
    lblBZWeight.text = [NSString stringWithFormat:@"标准%@",@"70kg"];
    [self.pieView addSubview:lblBZWeight];
    
    UILabel *lblCCWeight = [[UILabel alloc] initWithFrame:CGRectMake(65, 60 + 70, (210-60)/2, 20)];
    lblCCWeight.textAlignment = NSTextAlignmentCenter;
    lblCCWeight.font = [UIFont boldSystemFontOfSize:14];
    lblCCWeight.text = [NSString stringWithFormat:@"超出%@",@"16kg"];
    [self.pieView addSubview:lblCCWeight];
    
    [self.pieView addSubview:[self showRecommendText:CGRectMake(45, 165, 60, 30)]];
    
    UILabel *lbltotalKali = [[UILabel alloc] initWithFrame:CGRectMake(20, 260, ScreenWidth - 20*2, 20)];
    lbltotalKali.textAlignment = NSTextAlignmentCenter;
    lbltotalKali.font = [UIFont boldSystemFontOfSize:18];
    lbltotalKali.text = [NSString stringWithFormat:@"需要总消耗卡路里3000kcal"];
    [self.view addSubview:lbltotalKali];
    
    UIImageView *recommendimg = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 171)/2, 298, 171, 28)];
    recommendimg.image = [UIImage imageNamed:@"flag3"];
    [self.view addSubview:recommendimg];
    
    UILabel *lbltuijian = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, recommendimg.frame.size.width, 20)];
    lbltuijian.textAlignment = NSTextAlignmentCenter;
    lbltuijian.font = [UIFont boldSystemFontOfSize:13];
    lbltuijian.textColor = [UIColor whiteColor];
    lbltuijian.text = [NSString stringWithFormat:@"推荐方案"];
    [recommendimg addSubview:lbltuijian];
    
    UIImageView *bg1 = [[UIImageView alloc] initWithFrame:CGRectMake(14, 298 + 30+15, ScreenWidth - 14*2, 41)];
    bg1.image = [UIImage imageNamed:@"inputbox2"];
    [self.view addSubview:bg1];
    
    UIImageView *bg2 = [[UIImageView alloc] initWithFrame:CGRectMake(14, 298 + 45 + 55, ScreenWidth - 14*2, 41)];
    bg2.image = [UIImage imageNamed:@"inputbox2"];
    [self.view addSubview:bg2];
    
    UIImageView *bg3 = [[UIImageView alloc] initWithFrame:CGRectMake(14, 298 + 45 + 55*2, ScreenWidth - 14*2, 41)];
    bg3.image = [UIImage imageNamed:@"inputbox2"];
    [self.view addSubview:bg3];
    
}

- (UIView *)showRecommendText:(CGRect)frame;
{
    UIView  *tempView = [[UIView alloc] initWithFrame:frame];
    NSArray *imgArray = @[@"star-green",@"star-green",@"star-orange",@"star-red"].mutableCopy;
    NSArray *TextArray = @[@"偏瘦",@"正常",@"偏重",@"偏胖"].mutableCopy;
    
    for (int i = 0; i < [imgArray count]; i++) {
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(20+i%2*40, i/2*15, 8, 8)];
        image.image = [UIImage imageNamed:imgArray[i]];
        [tempView addSubview:image];
        
        UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(image.frame.origin.x+12, image.frame.origin.y - 4, 24, 15)];
        lblText.font = [UIFont systemFontOfSize:12];
        lblText.text = TextArray[i];
        [tempView addSubview:lblText];
    }
    
    return tempView;
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
