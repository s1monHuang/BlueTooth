//
//  myDataController.m
//  BlueToothBracelet
//
//  Created by azz on 16/3/15.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "myDataController.h"
#import "myDataCell.h"
#import "StepLongController.h"
#import "HeightViewController.h"
#import "WeightViewController.h"
#import "SexViewController.h"
#import "AgeViewController.h"
#import "nickNameController.h"
#import "OperateViewModel.h"
#import "TrainTargetController.h"

@interface myDataController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic , strong) UITableView *tableView;

@property (nonatomic , strong) NSArray *keyArray;

@property (nonatomic , strong) NSArray *valueArray;

@property (nonatomic , strong) UIView *bottomView;

//@property (nonatomic , assign) NSInteger targetValue;

@property (nonatomic , strong) myDataCell *selectedCell;

@property (nonatomic,strong) OperateViewModel *operateVM;


@end

@implementation myDataController

static NSString* identifier =@"PersonalCell";

-(NSArray *)keyArray
{
    if (!_keyArray) {
        _keyArray = @[@"昵称",@"性别",@"年龄",@"身高",@"体重",@"步长"];
    }
    return _keyArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的资料";
    self.view.backgroundColor = kThemeGrayColor;
    self.navigationController.navigationBar.backgroundColor = kThemeColor;
    self.navigationItem.leftBarButtonItem.title = @"";
    self.operateVM = [OperateViewModel viewModel];
    //tableView
    [self setUpTableView];
    
    //bottomView
    [self setUpBottomView];
    
    //属性改变通知
    //年龄
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authorPropertyIsChange:) name:ageIsChangeNotification object:nil];
    
    //性别
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authorPropertyIsChange:) name:sexIsChangeNotification object:nil];
    
    //身高
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authorPropertyIsChange:) name:heightIsChangeNotification object:nil];
    
    //体重
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authorPropertyIsChange:) name:weightIsChangeNotification object:nil];
    
    //步长
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authorPropertyIsChange:) name:steoLongIsChangeNotification object:nil];
    
    //昵称
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authorPropertyIsChange:) name:nickNameIsChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSInteger first = [[[NSUserDefaults standardUserDefaults] objectForKey:@"firstDownload"] integerValue];
    if (first == 1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.size = CGSizeMake(40, 40);
        button.alpha = 0;
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = item;
    }
    _valueArray = @[CurrentUser.nickName, CurrentUser.sex, CurrentUser.age, CurrentUser.high, CurrentUser.weight, CurrentUser.stepLong];
//    [_tableView reloadData];
}

- (void)setUpTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, self.view.width, 44 * 6) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
        [self.view addSubview:_tableView];
}

- (void)setUpBottomView
{
    CGFloat bottomViewY = CGRectGetMaxY(_tableView.frame);
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, bottomViewY + 20, self.view.width, 60)];
    _bottomView = bottomView;
    bottomView.backgroundColor = kThemeGrayColor;
    
    CGFloat buttonWidth = (self.view.width - 45) *0.5;
    
    UIButton *resetBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.width - buttonWidth) / 2, 10, buttonWidth, 40)];
    resetBtn.backgroundColor = KThemeGreenColor;
    [resetBtn setTitle:@"重新设置" forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(resetClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:resetBtn];
    
    [self.view addSubview:bottomView];
    
}

#pragma mark - 通知方法

- (void)authorPropertyIsChange:(NSNotification *)sender
{
    _selectedCell.valueLabel.text = sender.object;
}
//
#pragma mark - buttonClick

- (void)resetClick
{
//    __weak myDataController *blockSelf = self;
    [self.operateVM editWithUserNickName:CurrentUser.nickName sex:CurrentUser.sex high:CurrentUser.high weight:CurrentUser.weight age:CurrentUser.age stepLong:CurrentUser.stepLong];
    DLog(@"%@",CurrentUser);
    self.operateVM.finishHandler = ^(BOOL finished, id userInfo) { // 网络数据回调
        if (finished) {
            //修改数据库信息
            BasicInfomationModel *changeModel = [DBManager selectBasicInfomation];
            if (!changeModel) {
                changeModel = [[BasicInfomationModel alloc] init];
            }
            changeModel.nickName = CurrentUser.nickName;
            changeModel.gender = CurrentUser.sex;
            changeModel.height = [CurrentUser.high integerValue];
            changeModel.weight = [CurrentUser.weight integerValue];
            changeModel.age = CurrentUser.age;
            changeModel.distance = [CurrentUser.stepLong integerValue];
            BOOL change = [DBManager insertOrReplaceBasicInfomation:changeModel];
            if (!change) {
                DLog(@"修改用户信息失败");
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeNickName" object:CurrentUser.nickName];
            [MBProgressHUD showHUDByContent:@"个人信息设置成功" view:UI_Window afterDelay:2];
        }else
        {
            [MBProgressHUD showHUDByContent:userInfo view:UI_Window afterDelay:2];
        }
    };
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    myDataCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[myDataCell alloc] init];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = self.keyArray[indexPath.row];
    [cell.valueLabel setText:self.valueArray[indexPath.row]];

    cell.valueLabel.textAlignment = NSTextAlignmentRight;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:{
            nickNameController *nickNameCtl = [[nickNameController alloc] init];
            [self.navigationController pushViewController:nickNameCtl animated:YES];
        }
            break;
        case 1:{
            SexViewController *sexCtl = [[SexViewController alloc] init];
            [self.navigationController pushViewController:sexCtl animated:YES];
        }
            break;
        case 2:{
            AgeViewController *ageCtl = [[AgeViewController alloc] init];
            [self.navigationController pushViewController:ageCtl animated:YES];
        }
            
            break;
        case 3:{
            HeightViewController *heightCtl = [[HeightViewController alloc] init];
            [self.navigationController pushViewController:heightCtl animated:YES];
        }
            
            break;
        case 4:{
            WeightViewController *weightCtl = [[WeightViewController alloc] init];
            [self.navigationController pushViewController:weightCtl animated:YES];
        }
            
            break;
        case 5:{
            StepLongController *stepLongCtl = [[StepLongController alloc] init];
            [self.navigationController pushViewController:stepLongCtl animated:YES];
        }
            break;
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
