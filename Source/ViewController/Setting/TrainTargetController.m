//
//  TrainTargetController.m
//  BlueToothBracelet
//
//  Created by azz on 16/3/22.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "TrainTargetController.h"
#import "myDataController.h"

@interface TrainTargetController ()
@property (weak, nonatomic) IBOutlet UILabel *everydayTrainLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

@property (weak, nonatomic) IBOutlet UISlider *targetSlider;
@property (weak, nonatomic) IBOutlet UILabel *otherLabel;

@property (nonatomic , strong) UIButton *btnPre;

@property (nonatomic , strong) UIButton *btnNext;

@property (nonatomic , strong) UIButton *rightBtn;


@end

@implementation TrainTargetController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的资料";
    self.view.backgroundColor = kThemeGrayColor;
    self.navigationItem.leftBarButtonItem.title = @"";
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    _rightBtn = rightBtn;
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
    UIImage *thumbImage = [self OriginImage:[UIImage imageNamed:@"tuodong"] scaleToSize:CGSizeMake(20, 35)];
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
    
    UIButton *btnPre = [[UIButton alloc] initWithFrame:CGRectMake(0, ScreenHeight - 50 - 64, ScreenWidth/2, 50)];
    _btnPre = btnPre;
    _btnPre.alpha = 0;
    [btnPre addTarget:self action:@selector(btnPreClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnPre setTitle:@"上一步" forState:UIControlStateNormal];
    [btnPre setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnPre setBackgroundImage:[UIImage imageNamed:@"square-button2"] forState:UIControlStateNormal];
    [self.view addSubview:btnPre];
    
    UIButton *btnNext = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2, ScreenHeight - 50 - 64, ScreenWidth/2, 50)];
    _btnNext = btnNext;
    _btnNext.alpha = 0;
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
        _rightBtn.alpha = 0;
        _btnPre.alpha = 1;
        _btnNext.alpha = 1;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = item;
    }
    
}

- (void)setUpGreenBar
{
    CGFloat greenBarX = _targetSlider.x;
    CGFloat greenBarY = _targetSlider.y + 22;
    CGFloat greenBarW = (kScreenWidth - 80);
    CGFloat greenBarH = 10;
    UIImageView *greenBar = [[UIImageView alloc] initWithFrame:CGRectMake(greenBarX, greenBarY, greenBarW, greenBarH)];
    greenBar.image = [UIImage imageNamed:@"chibiao"];
    [self.view addSubview:greenBar];
    
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
    
    
    //修改数据库信息
    BasicInfomationModel *changeModel = [DBManager selectBasicInfomation];
    changeModel.distance = [_leftLabel.text floatValue] * 10;
    BOOL change = [DBManager insertOrReplaceBasicInfomation:changeModel];
    if (!change) {
        DLog(@"修改步长失败");
    }

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
    myDataController *VC = [[myDataController alloc] init];
    //    VC.isJump = self.isJump;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
