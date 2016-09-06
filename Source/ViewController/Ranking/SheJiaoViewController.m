//
//  SheJiaoViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/4.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "SheJiaoViewController.h"
#import "ShareCtrl.h"
#import "OperateViewModel.h"

@interface SheJiaoViewController ()<UITableViewDataSource,UITableViewDelegate, UIAlertViewDelegate ,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic , strong) OperateViewModel *operateVM;

@property (nonatomic , strong) UITextField *txtqueryCode;


@end

@implementation SheJiaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = BTLocalizedString(@"社交");
    self.view.backgroundColor = kThemeGrayColor;
    self.operateVM = [[OperateViewModel alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setTableFooterView:[UIView new]];
    _tableView.bounces = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removetxtqueryCode)];
    [_tableView addGestureRecognizer:tap];
    
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
        return 150;
    }
    else{
        return 85;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 38;
    }
    else{
        return 35;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 38)];
    if(section == 0)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth - 20, 38)];
        label.text = BTLocalizedString(@"我的分享码");
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        [view addSubview:label];
        return view;
    }
    else{
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, -5, ScreenWidth - 20, 35)];
        label.text = BTLocalizedString(@"添加好友");
        label.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        label.textAlignment = NSTextAlignmentLeft;
        [view addSubview:label];
        return view;
    }
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *title = nil;
//    if(section == 0)
//    {
//        NSString *tempStr = BTLocalizedString(@"我的分享码");
//        title = tempStr;
//    }else
//    {
//        NSString *tempStr = BTLocalizedString(@"添加好友");
//        title = tempStr;
//    }
//    
//    return title;
//}

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
        
        UIImageView *headerImageBg = [[UIImageView alloc] initWithFrame:CGRectMake(20, 30, 60, 60)];
        NSString *imageStr = [CurrentUser.sex isEqualToString:@"男"] ? @"man":@"woman";
        headerImageBg.image = [UIImage imageNamed:imageStr];
        [cell.contentView addSubview:headerImageBg];
    
        
        UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(100, 26, ScreenWidth - 120, 20)];
        lblUserName.text = CurrentUser.nickName;
        lblUserName.font = [UIFont boldSystemFontOfSize:20];
        lblUserName.textAlignment = NSTextAlignmentLeft;
        lblUserName.textColor = [UIColor blackColor];
        [cell.contentView addSubview:lblUserName];
        
        UILabel *lblShareNumber = [[UILabel alloc] initWithFrame:CGRectMake(100, 62, 120, 20)];
        lblShareNumber.text = BTLocalizedString(@"分享码:");
        lblShareNumber.font = [UIFont boldSystemFontOfSize:16];
        lblShareNumber.textAlignment = NSTextAlignmentLeft;
        lblShareNumber.textColor = [UIColor blackColor];
        [cell.contentView addSubview:lblShareNumber];
        
        UILabel *inviteCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(215, 50, ScreenWidth - 220, 45)];
        inviteCodeLabel.text = CurrentUser.inviteCode;
        inviteCodeLabel.textColor = KThemeGreenColor;
        inviteCodeLabel.numberOfLines = 0;
        inviteCodeLabel.font = [UIFont systemFontOfSize:20];
        [cell.contentView addSubview:inviteCodeLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 104, ScreenWidth, 1)];
        lineView.backgroundColor = [UIColor grayColor];
        [cell.contentView addSubview:lineView];
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 95, ScreenWidth, 35)];
        
        
        NSString *text = BTLocalizedString(@"分享(点击复制分享码)");
        
        CGSize textSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:13.0f] constrainedToSize:CGSizeMake(ScreenWidth, 15)];
        
        UIButton *btnShare = [[UIButton alloc] initWithFrame:CGRectMake((ScreenWidth - textSize.width - 20)/2, 25, 14, 14)];
        [btnShare setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [btnShare addTarget:self action:@selector(btnShareClick:) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:btnShare];
        
        UILabel *lblShareText = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth - textSize.width)/2+14, 25, textSize.width+100, 14)];
        lblShareText.text = text;
        lblShareText.font = [UIFont boldSystemFontOfSize:13];
        lblShareText.textAlignment = NSTextAlignmentLeft;
        lblShareText.textColor = [UIColor blackColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnShareClick:)];
        [backView addGestureRecognizer:tap];
        backView.userInteractionEnabled = YES;
        [backView addSubview:lblShareText];
        [cell.contentView addSubview:backView];
        
    }else{
        
        UILabel *lbltiqutext = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 60, 40)];
        lbltiqutext.text = BTLocalizedString(@"提取码");
        lbltiqutext.numberOfLines = 0;
        lbltiqutext.font = [UIFont boldSystemFontOfSize:16];
        lbltiqutext.textAlignment = NSTextAlignmentLeft;
        lbltiqutext.textColor = [UIColor blackColor];
        [cell.contentView addSubview:lbltiqutext];
        
        UITextField *txtqueryCode = [[UITextField alloc] initWithFrame:CGRectMake(78, 32, ScreenWidth - 170, 30)];
        txtqueryCode.background = [UIImage imageNamed:@"share_inputbox"];
        _txtqueryCode = txtqueryCode;
        txtqueryCode.delegate = self;
        [cell.contentView addSubview:txtqueryCode];
        
        UIButton *btnAddShare = [[UIButton alloc] initWithFrame:CGRectMake(txtqueryCode.x+txtqueryCode.width+10, 32, 75, 30)];
        [btnAddShare setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnAddShare setTitle:BTLocalizedString(@"添加") forState:UIControlStateNormal];
        [btnAddShare setBackgroundImage:[UIImage imageNamed:@"share_button"] forState:UIControlStateNormal];
        [btnAddShare addTarget:self action:@selector(relateUserInfo) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnAddShare];
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)btnShareClick:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:CurrentUser.inviteCode];
    [MBProgressHUD showHUDByContent:BTLocalizedString(@"分享码已复制") view:UI_Window afterDelay:2];
}

- (void)relateUserInfo
{
    __weak SheJiaoViewController *blockSelf = self;
    [self.operateVM relateUserInfoInviteCode:_txtqueryCode.text];
    self.operateVM.finishHandler = ^(BOOL finished, id userInfo) {
        if (finished) {
            [MBProgressHUD showHUDByContent:userInfo view:UI_Window afterDelay:2];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getRankInfo" object:nil];
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [blockSelf.navigationController popViewControllerAnimated:YES];
            });
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:BTLocalizedString(@"获取排名失败，请重试") delegate:blockSelf cancelButtonTitle:BTLocalizedString(@"取消") otherButtonTitles:BTLocalizedString(@"重试"), nil];
            [alert show];
        }
            
    };
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self relateUserInfo];
    }
}

- (void)removetxtqueryCode
{
    [_txtqueryCode resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 400)]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.tableView setTableFooterView:[UIView new]];
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
