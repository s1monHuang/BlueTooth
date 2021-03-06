//
//  PersonalCtrl.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/2.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "PersonalCtrl.h"
#import "DeviceManagerViewController.h"
#import "HistoryDataViewController.h"
#import "SexViewController.h"
#import "UtilityFunc.h"
#import "GTMBase64.h"
#import "AlarmClockViewController.h"
#import "AlertSettingsViewController.h"
#import "myDataController.h"
#import "LoginCtrl.h"
#import "TrainTargetController.h"
#import "CallAlertViewController.h"
#import "prenventLostController.h"
#import "SOSController.h"
#import "AboutUsController.h"
#import "DBManager.h"
#import "LanguageViewController.h"
#import "TestTableViewController.h"

@interface PersonalCtrl ()<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    NSArray *dataArray;
    NSArray *imageArray;
    
    UIActionSheet *_imageActionSheet;
    UIImagePickerController *imagePicker;
}

@property (strong, nonatomic) UITableView *personalTable;

@property (nonatomic , strong) UILabel *lblUserName;

@property (nonatomic , assign) BOOL setpasswordEmpty;

@property (nonatomic , strong) UIImageView *headerImageBg;



@end

@implementation PersonalCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLanguage:)
                                                 name:NOTIFY_CHANGE_LANGUAGE
                                               object:nil];
    
    self.title = BTLocalizedString(@"个人");
    self.view.backgroundColor = kThemeGrayColor;
    UIButton *unDownloadBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [unDownloadBtn setImage:[UIImage imageNamed:@"exit"] forState:UIControlStateNormal];
    [unDownloadBtn addTarget:self action:@selector(exitDownload) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:unDownloadBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
//    imageArray = @[@"data",@"target",@"bell",@"clock",@"ic_call_remind",@"ic_antilost",@"ic_sos",@"setup",@"i",@"datacenter",@"ic_language"];
//    dataArray = [[NSArray alloc] initWithObjects:BTLocalizedString(@"我的资料"),BTLocalizedString(@"运动目标"),BTLocalizedString(@"久坐提醒"),BTLocalizedString(@"智能闹钟"),BTLocalizedString(@"来电提醒"),BTLocalizedString(@"防丢提醒"),BTLocalizedString(@"一键求救"),BTLocalizedString(@"设备管理"), BTLocalizedString(@"关于我们"),BTLocalizedString(@"数据中心"),BTLocalizedString(@"语言"),nil];
    
    imageArray = @[@"data",@"target",@"bell",@"clock",@"ic_call_remind",@"ic_antilost",@"ic_sos",@"setup",@"i",@"datacenter",@"ic_language",@""];
    dataArray = [[NSArray alloc] initWithObjects:BTLocalizedString(@"我的资料"),BTLocalizedString(@"运动目标"),BTLocalizedString(@"久坐提醒"),BTLocalizedString(@"智能闹钟"),BTLocalizedString(@"来电提醒"),BTLocalizedString(@"防丢提醒"),BTLocalizedString(@"一键求救"),BTLocalizedString(@"设备管理"), BTLocalizedString(@"关于我们"),BTLocalizedString(@"数据中心"),BTLocalizedString(@"语言"),@"测试历史数据",nil];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 150)];
    headerView.backgroundColor = [UtilityUI stringTOColor:@"#06bd90"];
    [self.view addSubview:headerView];
    
//    UITapGestureRecognizer *recognizer;
//    recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
//    [headerView addGestureRecognizer:recognizer];
    
    _headerImageBg = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 80)/2, 10, 80, 80)];
    NSString *imageStr = [CurrentUser.sex isEqualToString:@"男"] ? @"man":@"woman";
    _headerImageBg.image = [UIImage imageNamed:imageStr];
    [self.view addSubview:_headerImageBg];
    
    UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, ScreenWidth - 30, 26)];
    _lblUserName = lblUserName;
    lblUserName.text = CurrentUser.nickName;
    lblUserName.font = [UIFont boldSystemFontOfSize:20];
    lblUserName.textAlignment = NSTextAlignmentCenter;
    lblUserName.textColor = [UIColor whiteColor];
    [headerView addSubview:lblUserName];
    
    
    self.personalTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 150, ScreenWidth, ScreenHeight - 150 -68) style:UITableViewStylePlain];
    self.personalTable.dataSource = self;
    self.personalTable.delegate = self;
    self.personalTable.backgroundColor = [UIColor clearColor];
    [self.personalTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 80)]];
    [self.view addSubview:self.personalTable];
    
//    _imageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册",@"相机",nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNickName:) name:@"changeNickName" object:nil];
}

#pragma mark - exitClick

- (void)changeNickName:(NSNotification *)sender
{
    _lblUserName.text = sender.userInfo[@"nickName"];
    
    NSString *imageStr = [CurrentUser.sex isEqualToString:@"男"] ? @"man":@"woman";
    _headerImageBg.image = [UIImage imageNamed:imageStr];
}

- (void)exitDownload
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:BTLocalizedString(@"确认退出?退出后历史数据将被清除") message:nil delegate:self cancelButtonTitle:BTLocalizedString(@"取消") otherButtonTitles:BTLocalizedString(@"确定"), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        LoginCtrl *loginCtl = [[LoginCtrl alloc] init];
        loginCtl.hidesBottomBarWhenPushed = YES;
        [[UserManager defaultInstance] clearUser];
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:FIRSTDOWNLAOD];
        [self.navigationController pushViewController:loginCtl animated:YES];
        [DBManager deleteAllSportData];
        [BluetoothManager clearBindingPeripheral];
        [BluetoothManager share].isBindingPeripheral = NO;
    }
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier =@"PersonalCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    for (UIView *subview in cell.contentView.subviews)
    {
        [subview removeFromSuperview];
    }
    
    cell.imageView.image = [UIImage imageNamed:imageArray[indexPath.row]];
    cell.textLabel.text = dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            myDataController *VC = [[myDataController alloc] init];
//            VC.isJump = YES;
            VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
            break;
        case 1:
        {
            TrainTargetController *trainCtl = [[TrainTargetController alloc] init];
            trainCtl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:trainCtl animated:YES];
        
        }
            break;
        case 2:
        {
            AlertSettingsViewController *VC = [[AlertSettingsViewController alloc] init];
            VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
            break;
        case 3:
        {
            AlarmClockViewController *VC = [[AlarmClockViewController alloc] init];
            VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
            break;
        case 4:
        {
            CallAlertViewController *ctl = [[CallAlertViewController alloc] init];
            ctl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:ctl animated:YES];
        }
            break;
        case 5:
        {
            prenventLostController *ctl = [[prenventLostController alloc] init];
            ctl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:ctl animated:YES];
        }
            break;
        case 6:
        {
            SOSController *ctl = [[SOSController alloc] init];
            ctl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:ctl animated:YES];
        }
            break;
        case 7: {
            DeviceManagerViewController *VC = [[DeviceManagerViewController alloc] init];
            VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
            break;
        case 8: {
            AboutUsController *VC = [[AboutUsController alloc] init];
            VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
            break;
        case 9: {
            HistoryDataViewController *VC = [[HistoryDataViewController alloc] init];
            VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
            break;
        case 10: {
            LanguageViewController *VC = [[LanguageViewController alloc] init];
            VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
            break;
        default: {
            TestTableViewController *vc = [[TestTableViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
    }
}

- (void)handleTapFrom:(UITapGestureRecognizer*)recognizer {
    // 触发手勢事件后，在这里作些事情
    
//    [_imageActionSheet showInView:self.view];
    
}

#pragma mark - UIActionSheetDelegate method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //设置默认状态栏
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if (buttonIndex == 0)
    {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else if(buttonIndex == 1)
    {
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image= [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    image = [UtilityFunc compressImage:image];
    
    NSString *imgContent = [[NSString alloc] initWithData:[GTMBase64 encodeData:UIImageJPEGRepresentation(image, 0.8)] encoding:NSUTF8StringEncoding];
    
    
    
    //设置白色状态栏
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    if ([[[UIDevice currentDevice]systemVersion] floatValue] >= 7.0) {
        //设置白色状态栏
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }else{
        //设置默认状态栏
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeLanguage:(NSNotification *)notification {
    self.title = BTLocalizedString(@"个人");
    dataArray = [[NSArray alloc] initWithObjects:BTLocalizedString(@"我的资料"),BTLocalizedString(@"运动目标"),BTLocalizedString(@"久坐提醒"),BTLocalizedString(@"智能闹钟"),BTLocalizedString(@"来电提醒"),BTLocalizedString(@"防丢提醒"),BTLocalizedString(@"一键求救"),BTLocalizedString(@"设备管理"), BTLocalizedString(@"关于我们"),BTLocalizedString(@"数据中心"),BTLocalizedString(@"语言"),nil];
    [_personalTable reloadData];
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
