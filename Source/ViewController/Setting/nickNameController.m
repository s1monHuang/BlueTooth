//
//  nickNameController.m
//  BlueToothBracelet
//
//  Created by azz on 16/3/16.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "nickNameController.h"
#import "SexViewController.h"

@interface nickNameController ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nickNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@property (nonatomic , assign) NSInteger first;

@property (nonatomic , strong) NSString *nickName;


@end

@implementation nickNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"昵称", nil);
    self.view.backgroundColor = kThemeGrayColor;
    self.navigationItem.leftBarButtonItem.title = @"";
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  30,
                                                                  44)];
    [button setTitle:nil forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_btn_back_nor"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_btn_back_pre"] forState:UIControlStateHighlighted];
    [button addTarget:self
               action:@selector(clickBack)
     forControlEvents:UIControlEventTouchUpInside];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    button.accessibilityLabel = NSLocalizedString(@"返回", nil);
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    [_sureBtn setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
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
        [btnPre setTitle:NSLocalizedString(@"上一步", nil) forState:UIControlStateNormal];
        [btnPre setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnPre setBackgroundImage:[UIImage imageNamed:@"square-button2"] forState:UIControlStateNormal];
        [self.view addSubview:btnPre];
        
        UIButton *btnNext = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2, ScreenHeight - 50 - 64, ScreenWidth/2, 50)];
        [btnNext addTarget:self action:@selector(btnNextClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnNext setTitle:NSLocalizedString(@"下一步", nil) forState:UIControlStateNormal];
        [btnNext setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnNext setBackgroundImage:[UIImage imageNamed:@"square-button1"] forState:UIControlStateNormal];
        [self.view addSubview:btnNext];
    }
    
}

- (void)clickBack
{
   [self.navigationController popViewControllerAnimated:YES]; 
}

- (IBAction)btnClick:(id)sender
{
    [self PushToVC];
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
    _nickName = _nickNameTextField.text;
    if (!_nickName || _nickName.length < 4 || _nickName.length > 16 ) {
        [MBProgressHUD showHUDByContent:NSLocalizedString(@"昵称长度必须为4-16个字符！", nil) view:UI_Window afterDelay:2];
        return;
    }
    if (_first == 1) {
        SexViewController *VC = [[SexViewController alloc] init];
        CurrentUser.nickName = _nickName;
        [self.navigationController pushViewController:VC animated:YES];
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:nickNameIsChangeNotification object:_nickName];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_nickNameTextField resignFirstResponder];
}

@end
