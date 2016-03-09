//
//  SheJiaoViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/4.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "SheJiaoViewController.h"
#import "ShareCtrl.h"

@interface SheJiaoViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SheJiaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"设计";
    self.view.backgroundColor = kThemeGrayColor;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setTableFooterView:[UIView new]];
    [self.tableView reloadData];
    
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 1;
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        return 130;
    }
    else{
        return 85;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 28;
    }
    else{
        return 48;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if(section == 0)
    {
        title = @"我的分享码";
    }else
    {
        title = @"添加好友";
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
    }
    
    if (indexPath.section == 0) {
        
        UIImageView *headerImageBg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
        headerImageBg.image = [UIImage imageNamed:@"portrait2"];
        [cell.contentView addSubview:headerImageBg];
    
        
        UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(100, 26, ScreenWidth - 120, 20)];
        lblUserName.text = @"赵大虎";
        lblUserName.font = [UIFont boldSystemFontOfSize:20];
        lblUserName.textAlignment = NSTextAlignmentLeft;
        lblUserName.textColor = [UIColor blackColor];
        [cell.contentView addSubview:lblUserName];
        
        UILabel *lblShareNumber = [[UILabel alloc] initWithFrame:CGRectMake(100, 52, ScreenWidth - 120, 20)];
        lblShareNumber.text = @"分享码: ZB8508";
        lblShareNumber.font = [UIFont boldSystemFontOfSize:16];
        lblShareNumber.textAlignment = NSTextAlignmentLeft;
        lblShareNumber.textColor = [UIColor blackColor];
        [cell.contentView addSubview:lblShareNumber];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 94, ScreenWidth, 1)];
        lineView.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:lineView];
        
        NSString *text = @"分享 (点击复制分享码)";
        
        CGSize textSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:13.0f] constrainedToSize:CGSizeMake(ScreenWidth, 15)];
        
        UIButton *btnShare = [[UIButton alloc] initWithFrame:CGRectMake((ScreenWidth - textSize.width - 20)/2, 105, 14, 14)];
        [btnShare setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [btnShare addTarget:self action:@selector(btnShareClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnShare];
        
        UILabel *lblShareText = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth - textSize.width)/2+14, 104, textSize.width+20, 14)];
        lblShareText.text = text;
        lblShareText.font = [UIFont boldSystemFontOfSize:13];
        lblShareText.textAlignment = NSTextAlignmentLeft;
        lblShareText.textColor = [UIColor blackColor];
        [cell.contentView addSubview:lblShareText];
        
    }else{
        
        UILabel *lbltiqutext = [[UILabel alloc] initWithFrame:CGRectMake(20, 35, 60, 20)];
        lbltiqutext.text = @"提取码";
        lbltiqutext.font = [UIFont boldSystemFontOfSize:16];
        lbltiqutext.textAlignment = NSTextAlignmentLeft;
        lbltiqutext.textColor = [UIColor blackColor];
        [cell.contentView addSubview:lbltiqutext];
        
        UITextField *txtqueryCode = [[UITextField alloc] initWithFrame:CGRectMake(88, 32, 145, 30)];
        txtqueryCode.background = [UIImage imageNamed:@"share_inputbox"];
        [cell.contentView addSubview:txtqueryCode];
        
        UIButton *btnAddShare = [[UIButton alloc] initWithFrame:CGRectMake(txtqueryCode.frame.origin.x+txtqueryCode.frame.size.width+20, 32, 75, 30)];
        [btnAddShare setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnAddShare setTitle:@"添加" forState:UIControlStateNormal];
        [btnAddShare setBackgroundImage:[UIImage imageNamed:@"share_button"] forState:UIControlStateNormal];
        [cell.contentView addSubview:btnAddShare];
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)btnShareClick:(id)sender
{
    ShareCtrl *VC = [[ShareCtrl alloc] init];
    [self presentViewController:VC animated:YES completion:nil];
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
