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
#import "OperateViewModel.h"
#import "MJExtension.h"

@interface RankingCtrl ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *rankingtable;
@property (strong, nonatomic) RankingEntity *mRankEntity;
@property (strong, nonatomic) NSMutableArray *dataArray;

@property (nonatomic , strong) OperateViewModel *operateVM;

@property (nonatomic , assign) NSInteger myRankNo;

@end

@implementation RankingCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLanguage:)
                                                 name:NOTIFY_CHANGE_LANGUAGE
                                               object:nil];
    
    self.title = BTLocalizedString(@"排名");
    self.view.backgroundColor = kThemeGrayColor;
    self.operateVM = [[OperateViewModel alloc] init];
//    [self getRankData];
    self.dataArray = @[].mutableCopy;
//    self.rankingtable.delegate = self;
//    self.rankingtable.dataSource = self;
    self.rankingtable.alpha = 0;
    
    // 设置
    UIBarButtonItem *rightBarButton=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick:)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRankData) name:@"getRankInfo" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getRankData];
//    [MBProgressHUD showHUDByContent:@"排名信息加载中..." view:UI_Window afterDelay:INT_MAX];
    
}

- (void)getRankData
{
    __weak RankingCtrl *blockSelf = self;;
    NSDate *startDate = [NSDate date];
//    NSDate *endDate = [startDate dateByAddingTimeInterval:(-24 * 60 * 60 * 3)];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *startDateStr = [formatter stringFromDate:startDate];
     NSString *endDateStr = [formatter stringFromDate:startDate];
    [self.operateVM requestRankingListStartDate:startDateStr endDate:endDateStr];
    self.operateVM.finishHandler = ^(BOOL finished, id userInfo) {
        if (finished) {
            
        blockSelf.dataArray = [RankingEntity mj_objectArrayWithKeyValuesArray:userInfo];
        if (blockSelf.dataArray.count > 1) {
            NSArray *tempArray = [NSArray arrayWithArray:blockSelf.dataArray];
//            for (NSInteger i = 0; i < blockSelf.dataArray.count; i++) {
//                for (NSInteger j = 0; j < i; j++) {
//                    RankingEntity *model = tempArray[i];
//                    RankingEntity *otherModel = tempArray[j];
//                    if ([model.sumSteps integerValue] < [otherModel.sumSteps integerValue]) {
//                        [blockSelf.dataArray exchangeObjectAtIndex:i withObjectAtIndex:j];
//                    }
//                }
//            }
            for (NSInteger i = 0; i < tempArray.count; i++) {
                RankingEntity *entity = blockSelf.dataArray[i];
                if ([entity.userId isEqualToString:CurrentUser.userId]) {
                    blockSelf.mRankEntity = entity;
                    blockSelf.myRankNo = i;
                }
            }
        }else
        {
            if (blockSelf.dataArray.count) {
               blockSelf.mRankEntity = blockSelf.dataArray[0];
            }else{
                blockSelf.mRankEntity = [[RankingEntity alloc] init];
                blockSelf.mRankEntity.sumSteps = @"0";
                blockSelf.mRankEntity.userName = CurrentUser.nickName;
                blockSelf.mRankEntity.userId = CurrentUser.userId;
                blockSelf.myRankNo = 0;
            }
            
        }
            blockSelf.rankingtable.delegate = blockSelf;
            blockSelf.rankingtable.dataSource = blockSelf;
            blockSelf.rankingtable.alpha = 1;
            [blockSelf.rankingtable setTableFooterView:[UIView new]];
            [blockSelf.rankingtable reloadData];
            [MBProgressHUD hideAllHUDsForView:UI_Window animated:YES];
        }else
        {
            [MBProgressHUD hideAllHUDsForView:UI_Window animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:BTLocalizedString(@"排名信息获取失败") message:nil delegate:blockSelf cancelButtonTitle:BTLocalizedString(@"确定") otherButtonTitles:nil, nil];
            [alert show];
        }
    };

}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
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
        numberOfRows = self.dataArray.count;
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
        title = BTLocalizedString(@"我的排名");
    }else
    {
        title = BTLocalizedString(@"当前排名");
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
        [cell configRankingCell:self.mRankEntity rankNo:self.myRankNo + 1];
    }else{
    
        RankingEntity *rankEntity = self.dataArray[indexPath.row];
        [cell configRankingCell:rankEntity rankNo:indexPath.row + 1];
        
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


- (void)rightBarButtonClick:(id)sender
{
    SheJiaoViewController *VC = [[SheJiaoViewController alloc] init];
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)changeLanguage:(NSNotification *)notification {
    self.title = BTLocalizedString(@"排名");
    [_rankingtable reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
