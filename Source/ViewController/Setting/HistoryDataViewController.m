//
//  HistoryDataViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/4.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "HistoryDataViewController.h"

@interface HistoryDataViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation HistoryDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"数据中心";
    self.view.backgroundColor = kThemeGrayColor;
    
    NSArray *arr = [[NSArray alloc]initWithObjects:@"运动历史记录",@"睡眠历史记录", nil];
    UISegmentedControl *segmentedControl = [ [ UISegmentedControl alloc ]
                                            initWithItems:arr];
    [segmentedControl setApportionsSegmentWidthsByContent:YES];
    segmentedControl.frame = CGRectMake(10, 10, ScreenWidth - 20 , 40);
    [segmentedControl setTintColor:[UtilityUI stringTOColor:@"#3ed0ab"]]; //设置segments的颜色
    self.dataType = 0;
     segmentedControl.selectedSegmentIndex = 0;//选中第几个segment 一般用于初始化时选中
    [segmentedControl addTarget:self action:@selector(selected:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, ScreenWidth, ScreenHeight - 60) style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.estimatedSectionHeaderHeight = 10;
    [self.view addSubview:self.tableView];
    [self.tableView setTableFooterView:[UIView new]];
    
    [self queryData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount = [self.dataArray count];
    return rowCount;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //定义标记，用于标记单元格
    static NSString* identifier =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    for (UIView *subview in cell.contentView.subviews)
    {
        [subview removeFromSuperview];
    }
    
    UILabel *lbl1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, (ScreenWidth - 40)/3, 20)];
    lbl1.text = @"";
    lbl1.font = [UIFont systemFontOfSize:15];
    lbl1.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:lbl1];
    
    UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake(20+(ScreenWidth - 40)/3, 14, (ScreenWidth - 40)/3, 20)];
    lbl2.text = @"";
    lbl2.font = [UIFont systemFontOfSize:15];
    lbl2.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:lbl2];
    
    UILabel *lbl3 = [[UILabel alloc] initWithFrame:CGRectMake(20+(ScreenWidth - 40)/3*2, 14, (ScreenWidth - 40)/3, 20)];
    lbl3.text = @"";
    lbl3.font = [UIFont systemFontOfSize:15];
    lbl3.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:lbl3];
    
    NSDictionary *dict = self.dataArray[indexPath.row];
    
    if(self.dataType == 0)
    {
        lbl1.text = dict[@"date"];
        lbl2.text = [NSString stringWithFormat:@"%@步",dict[@"step"]];
        lbl3.text = [NSString stringWithFormat:@"%@kcal",dict[@"kali"]];
    }else{
        lbl1.text = dict[@"date"];
        lbl2.text = dict[@"time"];
    }
    
    return cell;
}

-(void)selected:(id)sender{
    UISegmentedControl* control = (UISegmentedControl*)sender;
    switch (control.selectedSegmentIndex) {
        case 0:
        {
            self.dataType = 0;
            [self queryData];
        }
            break;
        case 1:
        {
            self.dataType = 1;
            [self queryData];
        }
            break;
        default:
            break;
    }
}

- (void)queryData
{
    switch (self.dataType) {
        case 0:
        {
            NSArray *tempArray = @[@{@"date":@"2015-05-26",@"step":@"28979",@"kali":@"3890"},@{@"date":@"2015-05-27",@"step":@"38979",@"kali":@"5890"},@{@"date":@"2015-05-28",@"step":@"28179",@"kali":@"3290"}];
            self.dataArray = tempArray.mutableCopy;
        }
            break;
        case 1:
        {
            NSArray *tempArray = @[@{@"date":@"2015-05-26",@"time":@"时长8小时05分"},@{@"date":@"2015-05-27",@"time":@"时长7小时60分"}];
            self.dataArray = tempArray.mutableCopy;
        }
            break;
        default:
            break;
    }
    
    [self.tableView reloadData];
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
