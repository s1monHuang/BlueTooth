//
//  TrainTargetController.m
//  BlueToothBracelet
//
//  Created by azz on 16/3/22.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "TrainTargetController.h"

@interface TrainTargetController ()
@property (weak, nonatomic) IBOutlet UILabel *everydayTrainLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@property (weak, nonatomic) IBOutlet UISlider *targetSlider;
@property (weak, nonatomic) IBOutlet UILabel *otherLabel;

@end

@implementation TrainTargetController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的资料";
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(changeTrainTarget) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    
    _everydayTrainLabel.alpha = 0.8;
    _leftImageView.image = [UIImage imageNamed:@"pic-distance"];
    _rightImageView.image = [UIImage imageNamed:@"pic-fire"];
    
    //设置绿条
    [self setUpGreenBar];
    
    _targetSlider.minimumValue = 0.5;
    _targetSlider.maximumValue = 3;
    _targetSlider.value = 1;
    UIImage *thumbImage = [self OriginImage:[UIImage imageNamed:@"pic-distance"] scaleToSize:CGSizeMake(30, 30)];
    [_targetSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    _targetSlider.minimumTrackTintColor = [UIColor clearColor];
    _targetSlider.maximumTrackTintColor = [UIColor clearColor];
    
    [_targetSlider addTarget:self action:@selector(valueChange) forControlEvents:UIControlEventValueChanged];
    [self.view bringSubviewToFront:_targetSlider];
    
    _stepCountLabel.text = [NSString stringWithFormat:@"%2.0lf步",_targetSlider.value * 10000];
    _stepCountLabel.textColor = KThemeGreenColor;
    _stepCountLabel.textAlignment = NSTextAlignmentCenter;
    _stepCountLabel.font = [UIFont systemFontOfSize:25];
    
    CGFloat distance = (_targetSlider.value * [CurrentUser.stepLong floatValue] ) / 10;
    _leftLabel.text = [NSString stringWithFormat:@"%.1lfkm",distance];
    CGFloat fireEnergy = [CurrentUser.weight floatValue] * distance * 1.036;
    _rightLabel.text = [NSString stringWithFormat:@"%.0lf千卡",fireEnergy];
    
}

- (void)setUpGreenBar
{
    CGFloat greenBarX = _targetSlider.x;
    CGFloat greenBarY = _targetSlider.y + 10;
    CGFloat greenBarW = (kScreenWidth - 100) / 3;
    CGFloat greenBarH = 20;
    UIImageView *leftGreen = [[UIImageView alloc] initWithFrame:CGRectMake(greenBarX, greenBarY, greenBarW, greenBarH)];
    UIImageView *middleGreen = [[UIImageView alloc] initWithFrame:CGRectMake(greenBarX + greenBarW, greenBarY, greenBarW, greenBarH)];
    UIImageView *rightGreen = [[UIImageView alloc] initWithFrame:CGRectMake(greenBarX + (2 * greenBarW), greenBarY, greenBarW, greenBarH)];
    leftGreen.backgroundColor = KThemeGreenColor;
    middleGreen.backgroundColor = KThemeGreenColor;
    rightGreen.backgroundColor = KThemeGreenColor;
    leftGreen.alpha = 0.3;
    middleGreen.alpha = 0.5;
    rightGreen.alpha = 0.7;
    [self.view addSubview:leftGreen];
    [self.view addSubview:middleGreen];
    [self.view addSubview:rightGreen];
}

//完成按钮点击
- (void)changeTrainTarget
{
    DLog(@"~~~~");
}

//改变步数
- (void)valueChange
{
    NSInteger count = ((NSInteger)(_targetSlider.value * 10000 ) % 100) > 49 ? (100 - (NSInteger)(_targetSlider.value * 10000 ) % 100 + (NSInteger)(_targetSlider.value * 10000)) : ((NSInteger)(_targetSlider.value * 10000) - (NSInteger)(_targetSlider.value * 10000 ) % 100 );
    _stepCountLabel.text = [NSString stringWithFormat:@"%ld步",count];
    _stepCountLabel.textColor = KThemeGreenColor;
    
    CGFloat distance = (_targetSlider.value * [CurrentUser.stepLong floatValue] ) / 10;
    _leftLabel.text = [NSString stringWithFormat:@"%.1lfkm",distance];
    CGFloat fireEnergy = [CurrentUser.weight floatValue] * distance * 1.036;
    _rightLabel.text = [NSString stringWithFormat:@"%.0lf千卡",fireEnergy];
}

//滑块图片大小
-(UIImage*) OriginImage:(UIImage*)image scaleToSize:(CGSize)size

{
    
    UIGraphicsBeginImageContext(size);//size为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
