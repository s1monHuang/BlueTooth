//
//  AgeViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/12.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "AgeViewController.h"
#import "HeightViewController.h"

@interface AgeViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSMutableArray *ageArray;
@property (strong, nonatomic) UILabel *lblAgeValue;

@property (nonatomic , assign) NSInteger first;

@property (nonatomic , copy) NSString *ageStr;

@end

@implementation AgeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = BTLocalizedString(@"我的资料");
    self.view.backgroundColor = kThemeGrayColor;
    self.navigationItem.leftBarButtonItem.title = @"";
    self.ageArray = @[].mutableCopy;
    // 设置
    NSString *sexNamed = [CurrentUser.sex isEqualToString:@"男"]?@"man":@"woman";
    
    UIButton *btnHeader = [[UIButton alloc] initWithFrame:CGRectMake((ScreenWidth - 110)/2, 60, 110, 110)];
    [btnHeader setBackgroundImage:[UIImage imageNamed:sexNamed] forState:UIControlStateNormal];
    [self.view addSubview:btnHeader];
    
    UILabel *lblAge = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth - 110)/2, 60 + 120, 110, 20)];
    lblAge.text = BTLocalizedString(@"年龄");
    lblAge.font = [UIFont systemFontOfSize:18];
    lblAge.textAlignment = NSTextAlignmentCenter;
    lblAge.textColor = KThemeGreenColor;
    [self.view addSubview:lblAge];
    
    self.lblAgeValue = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth - 110)/2, 60 + 120+28, 110, 20)];
    DLog(@"%ld",CurrentUser.age.length);
    self.lblAgeValue.text = [CurrentUser.age isEqualToString:@"(null)"] ? @"18" : CurrentUser.age;
    self.lblAgeValue.font = [UIFont systemFontOfSize:18];
    self.lblAgeValue.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.lblAgeValue];
    
    for (int i = 1; i < 100; i++) {
        [self.ageArray addObject:[@(i) stringValue]];
    }
    CGFloat pickerViewHeight = kScreenHeight > 480 ? 200 : 160;
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 60 + 120+60, ScreenWidth, pickerViewHeight)];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    [self.pickerView selectRow:17 inComponent:0 animated:YES];
    [self.view addSubview:self.pickerView];
    
    if([CurrentUser.age integerValue] > 0){
        [self.pickerView selectRow:[CurrentUser.age integerValue] - 1 inComponent:0 animated:YES];
    }
    
    
    //[self pickerView:nil didSelectRow:25 inComponent:0];
    
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
         BTLocalizedString(@"完成")forState:UIControlStateNormal];
        [rightButton addTarget:self
                        action:@selector(PushToVC)
              forControlEvents:UIControlEventTouchUpInside];
        rightButton.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        rightButton.accessibilityLabel =BTLocalizedString(@"完成") ;
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = rightBarButton;
    }
    
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
    _ageStr = self.lblAgeValue.text;
    if (_first == 1) {
        HeightViewController *VC = [[HeightViewController alloc] init];
        CurrentUser.age = _ageStr;
        [self.navigationController pushViewController:VC animated:YES];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:ageIsChangeNotification object:_ageStr];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//返回有几列
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    //返回有几列 ，注意
    return 1;
}

//返回指定列的行数
- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.ageArray.count;
}

//返回指定列，行的高度，就是自定义行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return  30;
}

//替换text居中
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)];
    
    label.text = self.ageArray[row];//[m_mutArrSensorList objectAtIndex:row-1];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
 {
     //获取对应列，对应行的数据
     NSString *age= self.ageArray[row];
     self.lblAgeValue.text = age;

//     [[NSNotificationCenter defaultCenter] postNotificationName:ageNotification object:age];
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
