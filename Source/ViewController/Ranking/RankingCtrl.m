//
//  RankingCtrl.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/2.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "RankingCtrl.h"
#import "RankingCell.h"
#import "RankingEntity.h"
#import "SheJiaoViewController.h"

@interface RankingCtrl ()<UITableViewDelegate,UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *rankingtable;
@property (strong, nonatomic) RankingEntity *mRankEntity;
@property (strong, nonatomic) NSMutableArray *dataArray;

@end

@implementation RankingCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"排名";
    self.view.backgroundColor = kThemeGrayColor;
    
    self.dataArray = @[].mutableCopy;
    [self queryRankingList];
    
    _rankingtable.delegate = self;
    _rankingtable.dataSource = self;
    [_rankingtable setTableFooterView:[UIView new]];
    [_rankingtable reloadData];
    
    // 设置
    UIBarButtonItem *rightBarButton=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    if(section == 0)
    {
        numberOfRows = 1;
    }else{
        numberOfRows = 5;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if(section == 0)
    {
        title = @"我的排名";
    }else
    {
        title = @"当前排名";
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier =@"RankCell";
    
    RankingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RankingCell" owner:self options:nil] lastObject];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
    }
    
    if (indexPath.section == 0) {
        [cell configRankingCell:self.mRankEntity];
    }else{
    
        RankingEntity *rankEntity = self.dataArray[indexPath.row];
        [cell configRankingCell:rankEntity];
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {}
            break;
        case 1:
        {}
            break;
        case 2:
        {}
            break;
        case 3:
        {}
            break;
        case 4:
        {
            
        }
            break;
        case 5:
        {}
            break;
        case 6:
        {}
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryRankingList
{
    NSArray *dataArray = @[@{@"RankNo":@"1",@"UserID":@"101",@"RankName":@"王老五",@"StepNumber":@"142600"},@{@"RankNo":@"2",@"UserID":@"102",@"RankName":@"小小小小明",@"StepNumber":@"14260"},@{@"RankNo":@"3",@"UserID":@"103",@"RankName":@"飞人刘翔",@"StepNumber":@"9908"},@{@"RankNo":@"4",@"UserID":@"104",@"RankName":@"lisa",@"StepNumber":@"8426"},@{@"RankNo":@"5",@"UserID":@"105",@"RankName":@"毛大虎",@"StepNumber":@"1426"}];
    
    [dataArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        
        RankingEntity *rankEntity = [[RankingEntity alloc] initRankingEntityWithDic:obj];
        
        if ([rankEntity.RankNo integerValue] == 5) {
            self.mRankEntity = rankEntity;
        }
        
        [self.dataArray addObject:rankEntity];
        
    }];
    
}

- (void)rightBarButtonClick:(id)sender
{
    SheJiaoViewController *VC = [[SheJiaoViewController alloc] init];
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
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
