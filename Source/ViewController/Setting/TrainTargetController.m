//
//  TrainTargetController.m
//  BlueToothBracelet
//
//  Created by azz on 16/3/22.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "TrainTargetController.h"
#import "myDataController.h"
#import "OperateViewModel.h"

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

@property (nonatomic , strong) BasicInfomationModel *changeModel;

@property (nonatomic , assign) NSInteger stepCount;

@property (nonatomic,strong) OperateViewModel *operateVM;


@end

@implementation TrainTargetController

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的资料";
    self.view.backgroundColor = kThemeGrayColor;
    self.operateVM = [OperateViewModel viewModel];
    self.navigationItem.leftBarButtonItem.title = @"";
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    _rightBtn = rightBtn;
    [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(changeTrainTarget) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    
    _changeModel = [DBManager selectBasicInfomation];
    if (!_changeModel) {
        _changeModel = [[BasicInfomationModel alloc] init];
    }
    
    _everydayTrainLabel.alpha = 0.8;
    _leftImageView.image = [UIImage imageNamed:@"pic-distance"];
    _rightImageView.image = [UIImage imageNamed:@"pic-fire"];
    
    //设置绿条
    [self setUpGreenBar];
    
    _targetSlider.minimumValue = 0.5;
    _targetSlider.maximumValue = 3;
    UIImage *thumbImage = [self OriginImage:[UIImage imageNamed:@"tuodong"] scaleToSize:CGSizeMake(20, 35)];
    [_targetSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    _targetSlider.minimumTrackTintColor = [UIColor clearColor];
    _targetSlider.maximumTrackTintColor = [UIColor clearColor];
    NSInteger stepCount = [[[NSUserDefaults standardUserDefaults] objectForKey:targetStepCount] integerValue];
    CGFloat targetSlider = stepCount > 0 ? (CGFloat)stepCount *0.0001 : 1;
    _targetSlider.value = targetSlider;
    
    [_targetSlider addTarget:self action:@selector(valueChange) forControlEvents:UIControlEventValueChanged];
    [self.view bringSubviewToFront:_targetSlider];
    _stepCountLabel.textColor = KThemeGreenColor;
    _stepCountLabel.textAlignment = NSTextAlignmentCenter;
    _stepCountLabel.font = [UIFont systemFontOfSize:25];
    _stepCountLabel.text = [NSString stringWithFormat:@"%2.0lf步",_targetSlider.value * 10000];
    _stepCount = 10000;
    
    CGFloat distance = (_targetSlider.value * [CurrentUser.stepLong floatValue] ) / 10;
    _leftLabel.text = [NSString stringWithFormat:@"%.1lfkm",distance];
    CGFloat fireEnergy = [CurrentUser.weight floatValue] * distance * 1.036 * 0.001;
    _rightLabel.text = [NSString stringWithFormat:@"%.2lf千卡",fireEnergy];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(setBasicInfomationSuccess:)
//                                                 name:SET_BASICINFOMATION_SUCCESS
//                                               object:nil];
    NSInteger first = [[[NSUserDefaults standardUserDefaults] objectForKey:FIRSTDOWNLAOD] integerValue];
    if (first == 1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.size = CGSizeMake(40, 40);
        button.alpha = 0;
        _rightBtn.alpha = 0;
//        _btnPre.alpha = 1;
//        _btnNext.alpha = 1;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = item;
        
        UIButton *btnPre = [[UIButton alloc] initWithFrame:CGRectMake(0, ScreenHeight - 50 - 64, ScreenWidth, 50)];
        [btnPre addTarget:self action:@selector(btnPreClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnPre setTitle:@"上一步" forState:UIControlStateNormal];
        [btnPre setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnPre setBackgroundImage:[UIImage imageNamed:@"square-button2"] forState:UIControlStateNormal];
        [self.view addSubview:btnPre];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSInteger first = [[[NSUserDefaults standardUserDefaults] objectForKey:FIRSTDOWNLAOD] integerValue];
    if (first == 1) {
        NSInteger targetInteger = [_leftLabel.text floatValue] * 10;
        [[NSNotificationCenter defaultCenter] postNotificationName:targetNotification object:@(targetInteger)];
        
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
    NSInteger first = [[[NSUserDefaults standardUserDefaults] objectForKey:FIRSTDOWNLAOD] integerValue];
    NSInteger targetInteger = [_leftLabel.text floatValue] * 10;
    _changeModel.target = targetInteger;
    //训练目标步数保存到本地
    [[NSUserDefaults standardUserDefaults] setObject:@(_stepCount) forKey:targetStepCount];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeStepCount" object:@(_stepCount)];
   
    __weak TrainTargetController *blockSelf = self;
    if (first == 1) {
        [self.operateVM editWithUserNickName:CurrentUser.nickName sex:CurrentUser.sex high:CurrentUser.high weight:CurrentUser.weight age:CurrentUser.age stepLong:CurrentUser.stepLong];
        DLog(@"%@",CurrentUser);
        self.operateVM.finishHandler = ^(BOOL finished, id userInfo) { // 网络数据回调
            if (finished) {
                //修改数据库信息
                blockSelf.changeModel.nickName = CurrentUser.nickName;
                blockSelf.changeModel.gender = CurrentUser.sex;
                blockSelf.changeModel.height = [CurrentUser.high integerValue];
                blockSelf.changeModel.weight = [CurrentUser.weight integerValue];
                blockSelf.changeModel.age = CurrentUser.age;
                blockSelf.changeModel.distance = [CurrentUser.stepLong integerValue];
                BOOL change = [DBManager insertOrReplaceBasicInfomation:blockSelf.changeModel];
                if (!change) {
                    DLog(@"修改用户信息失败");
                }
                [[NSUserDefaults standardUserDefaults] setObject:@(2) forKey:FIRSTDOWNLAOD];
                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:DOWNLOADSUCCESS];
                [MBProgressHUD showHUDByContent:@"个人信息设置成功" view:UI_Window afterDelay:2];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[AppDelegate defaultDelegate] exchangeRootViewControllerToMain];
                });
                return;
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:userInfo message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                return;
            }
        };
        
    }else{
        BOOL change = [DBManager insertOrReplaceBasicInfomation:_changeModel];
        if (change) {
            [[BluetoothManager share] setBasicInfomation:_changeModel];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//改变步数
- (void)valueChange
{
    _stepCount = ((NSInteger)(_targetSlider.value * 10000 ) % 100) > 49 ? (100 - (NSInteger)(_targetSlider.value * 10000 ) % 100 + (NSInteger)(_targetSlider.value * 10000)) : ((NSInteger)(_targetSlider.value * 10000) - (NSInteger)(_targetSlider.value * 10000 ) % 100 );
    _stepCountLabel.text = [NSString stringWithFormat:@"%ld步",_stepCount];
    _stepCountLabel.textColor = KThemeGreenColor;
    
    CGFloat distance = (_targetSlider.value * [CurrentUser.stepLong floatValue] ) / 10;
    _leftLabel.text = [NSString stringWithFormat:@"%.1lfkm",distance];
    CGFloat fireEnergy = [CurrentUser.weight floatValue] * distance * 1.036 * 0.001;
    _rightLabel.text = [NSString stringWithFormat:@"%.2lf千卡",fireEnergy];
    
   

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
//    CurrentUser.stepCount = [NSString stringWithFormat:@"%ld",_stepCount];
    [[NSUserDefaults standardUserDefaults] setObject:@(_stepCount) forKey:targetStepCount];
    NSInteger targetInteger = [_leftLabel.text floatValue] * 10;
    [[NSNotificationCenter defaultCenter] postNotificationName:targetNotification object:@(targetInteger)];
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)setBasicInfomationSuccess:(NSNotification *)notification {
//    [MBProgressHUD hideHUDForView:UI_Window animated:YES];
//<<<<<<< HEAD
//    [MBProgressHUD showHUDByContent:@"修改成功" view:UI_Window afterDelay:1];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeStepCount" object:CurrentUser.stepCount];
//=======
//>>>>>>> 86d2b91434da1275f54201ce267b3ab768054200
//    BOOL change = [DBManager insertOrReplaceBasicInfomation:_changeModel];
//    if (!change) {
//        DLog(@"修改训练目标失败");
//    }
//}


@end
