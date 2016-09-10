//
//  AppDelegate.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/2.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "AppDelegate.h"
#import "BluetoothManager.h"
#import "UserManager.h"
#import "SportCtrl.h"
#import "RankingCtrl.h"
#import "SleepCtrl.h"
#import "HeartbeatCtrl.h"
#import "PersonalCtrl.h"
#import "LoginCtrl.h"
#import "WXApi.h"
#import "WeiboSDK.h"

#import <MessageUI/MessageUI.h>



@interface AppDelegate () <UIAlertViewDelegate,WXApiDelegate,WeiboSDKDelegate,MFMessageComposeViewControllerDelegate> {
    UITabBarItem * tabBarItem1;
    UITabBarItem * tabBarItem2;
    UITabBarItem * tabBarItem3;
    UITabBarItem * tabBarItem4;
}

#define WX_KEY @"wx5ac8c621e7ca98a9"
#define WB_KEY @"1468435197"




@property (nonatomic,strong) OperateViewModel *operateVM;

@property (nonatomic , assign) NSInteger firstDownload;

@property (nonatomic , strong) LoginCtrl *loginVC;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _languageIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SELECTED_LANGUAGE] integerValue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLanguage:)
                                                 name:NOTIFY_CHANGE_LANGUAGE
                                               object:nil];
    _isEnglish = [self systemLanguageIsEnglish];
    
    [WXApi registerApp:WX_KEY];
    [WeiboSDK registerApp:WB_KEY];
    
    [DBManager initApplicationsDB];
    
    self.operateVM = [[OperateViewModel alloc] init];
    BOOL first = [[NSUserDefaults standardUserDefaults] objectForKey:FIRSTDOWNLAOD]?YES:NO;
    if (!first) {
        DLog(@"第一次登陆");
        _firstDownload = 1;
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:FIRSTDOWNLAOD];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }else{
        _firstDownload = [[[NSUserDefaults standardUserDefaults] objectForKey:FIRSTDOWNLAOD] integerValue];
    }
    if([[UserManager defaultInstance] hasUser] && _firstDownload == 2)
    {
        [self exchangeRootViewControllerToMain];
        [BluetoothManager share];
    }
    else{
        [self exchangeRootViewControllerToLogin];
    }

    return YES;
}



// 切换到登录界面
- (void)exchangeRootViewControllerToLogin
{
    LoginCtrl *loginVC = [[LoginCtrl alloc] init];
    UINavigationController *nav
    = [[UINavigationController alloc] initWithRootViewController:loginVC];
    nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [UtilityUI setNavigationStyle:nav.navigationBar];
    nav.navigationBar.barTintColor = [UtilityUI stringTOColor:@"#06bd90"];
    
    
    nav.navigationBar.translucent = NO;
    self.window.rootViewController = nav;
}

- (void)exchangeRootViewControllerToMain
{
    
    __weak AppDelegate *blockSelf = self;
    
    //自动登陆
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    BOOL downloadSuccess = [[[NSUserDefaults standardUserDefaults] objectForKey:DOWNLOADSUCCESS] boolValue];

    if (downloadSuccess) {
        if (userName && password) {
        [self.operateVM loginWithUserName:userName password:password];
        self.operateVM.finishHandler = ^(BOOL finished, id userInfo) { // 网络数据回调
            if (finished) {
                [[UserManager defaultInstance] saveUser:userInfo];
                
                BasicInfomationModel *infoModel = [DBManager selectBasicInfomation];
                if (!infoModel) {
                    infoModel = [[BasicInfomationModel alloc] init];
                }
                infoModel.nickName = CurrentUser.nickName;
                infoModel.gender = CurrentUser.sex;
                infoModel.age = CurrentUser.age;
                infoModel.height = [CurrentUser.high integerValue];
                infoModel.weight = [CurrentUser.weight integerValue];
                infoModel.distance = [CurrentUser.stepLong integerValue];
                BOOL Info = [DBManager insertOrReplaceBasicInfomation:infoModel];
                if (!Info) {
                    DLog(@"存入用户信息失败");
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:DOWNLOADSUCCESS];
                [blockSelf translateToMainController];
            }else{
                [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:DOWNLOADSUCCESS];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:BTLocalizedString(@"登录失败") message:nil delegate:blockSelf cancelButtonTitle:nil otherButtonTitles:BTLocalizedString(@"确定"), nil];
                [alert show];
                return;
            }
        };

    }
    }else{
//        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"appDelegateToLogin"];
        LoginCtrl *loginVC = [[LoginCtrl alloc] init];
        
        UINavigationController *nav
        = [[UINavigationController alloc] initWithRootViewController:loginVC];
        nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
        [UtilityUI setNavigationStyle:nav.navigationBar];
        nav.navigationBar.barTintColor = [UtilityUI stringTOColor:@"#06bd90"];
        
        
        nav.navigationBar.translucent = NO;
        self.window.rootViewController = nav;
    }
    
}

- (void)translateToMainController
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessage) name:@"SOSSendMessage" object:nil];
    SportCtrl *sportVC = [[SportCtrl alloc] init];
    UINavigationController *navSport
    = [[UINavigationController alloc] initWithRootViewController:sportVC];
    UIImage * normalImage1 = [[UIImage imageNamed:@"movement2.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage * selectImage1 = [[UIImage imageNamed:@"movement1.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem1 = [[UITabBarItem alloc]initWithTitle:BTLocalizedString(@"运动") image:normalImage1 selectedImage:selectImage1];
    navSport.tabBarItem = tabBarItem1;
    [UtilityUI setNavigationStyle:navSport.navigationBar];
    [UtilityUI setTabBarStyle:tabBarItem1];
    
    RankingCtrl *RankVC = [[RankingCtrl alloc] init];
    UINavigationController *navRanding
    = [[UINavigationController alloc] initWithRootViewController:RankVC];
    UIImage * normalImage2 = [[UIImage imageNamed:@"ranking2.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage * selectImage2 = [[UIImage imageNamed:@"ranking1.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem2 =[[UITabBarItem alloc]initWithTitle:BTLocalizedString(@"排名") image:normalImage2 selectedImage:selectImage2];
    navRanding.tabBarItem = tabBarItem2;
    [UtilityUI setNavigationStyle:navRanding.navigationBar];
    [UtilityUI setTabBarStyle:navRanding.tabBarItem];
    
    SleepCtrl *sleepVC = [[SleepCtrl alloc] init];
    UINavigationController *navSleep
    = [[UINavigationController alloc] initWithRootViewController:sleepVC];
    UIImage * normalImage3 = [[UIImage imageNamed:@"sleep2.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage * selectImage3 = [[UIImage imageNamed:@"sleep1.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem3 = [[UITabBarItem alloc]initWithTitle:BTLocalizedString(@"睡眠") image:normalImage3 selectedImage:selectImage3];
    navSleep.tabBarItem = tabBarItem3;
    [UtilityUI setNavigationStyle:navSleep.navigationBar];
    [UtilityUI setTabBarStyle:tabBarItem3];
    
    HeartbeatCtrl *heartVC = [[HeartbeatCtrl alloc] init];
    UINavigationController *navHeart
    = [[UINavigationController alloc] initWithRootViewController:heartVC];
    UIImage * normalImage4 = [[UIImage imageNamed:@"heartbeat2.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage * selectImage4 = [[UIImage imageNamed:@"heartbeat1.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem4 = [[UITabBarItem alloc]initWithTitle:BTLocalizedString(@"心率") image:normalImage4 selectedImage:selectImage4];
    navHeart.tabBarItem = tabBarItem4;
    [UtilityUI setNavigationStyle:navHeart.navigationBar];
    [UtilityUI setTabBarStyle:tabBarItem4];
    
    
    PersonalCtrl *personalVC = [[PersonalCtrl alloc] init];
    UINavigationController *navPersonal
    = [[UINavigationController alloc] initWithRootViewController:personalVC];
    UIImage * normalImage5 = [[UIImage imageNamed:@"personal2.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage * selectImage5 = [[UIImage imageNamed:@"personal1.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem * tabBarItem5 = [[UITabBarItem alloc]initWithTitle:BTLocalizedString(@"个人") image:normalImage5 selectedImage:selectImage5];
    navPersonal.tabBarItem = tabBarItem5;
    //[navSetting.navigationBarAppearance setShadowImage:[UIImage new]];
    //navSetting.navigationBar.shadowImage = [UIImage imagewi]
    [navPersonal.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [UtilityUI setNavigationStyle:navPersonal.navigationBar];
    [UtilityUI setTabBarStyle:tabBarItem5];
    
    self.mainTabBarController = [[UITabBarController alloc] init];
    self.mainTabBarController.viewControllers = [NSArray arrayWithObjects:
                                                 navSport,
                                                 navRanding,
                                                 navSleep,
                                                 navHeart,
                                                 navPersonal,nil];
    [self.window addSubview:self.mainTabBarController.view];
    self.mainTabBarController.selectedIndex = 0;
    //self.mainTabBarController.tabBar.barTintColor = [[Tools shareToolsObj] stringTOColor:@"#595959"];
    self.mainTabBarController.tabBar.translucent = NO;
    self.window.rootViewController = self.mainTabBarController;
}

- (void)sendMessage
{
    //没有绑定设备
    if (![BluetoothManager getBindingPeripheralUUID]) {
//        [MBProgressHUD showHUDByContent:@"您尚未绑定设备" view:UI_Window afterDelay:1.5];
        return;
    }
    if (![[BluetoothManager share] isExistCharacteristic]) {
//        [MBProgressHUD showHUDByContent:@"设备自动连接中，请稍后" view:UI_Window afterDelay:1.5];
        return;
    }
    NSString *phoneNO = [[NSUserDefaults standardUserDefaults] objectForKey:SETPHONENO];
    MFMessageComposeViewController *messageController=[[MFMessageComposeViewController alloc]init];
    messageController.recipients= @[phoneNO];
    messageController.body = BTLocalizedString(@"[EasyFit提醒]我需要您的帮助，请尽快和TA联系！");
    messageController.messageComposeDelegate = self;
    [self.mainTabBarController presentViewController:messageController animated:YES completion:nil];
}


+ (AppDelegate *)defaultDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication]delegate];
}
#pragma mark - 短信发送界面代理
//短信发送状态
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [BluetoothManager share].isCalling = NO;
    
    switch (result) {
        case MessageComposeResultSent:
        {
            [MBProgressHUD showHUDByContent:BTLocalizedString(@"发送成功") view:UI_Window afterDelay:2];
        }
            
            break;
        case MessageComposeResultFailed:
        {
            [MBProgressHUD showHUDByContent:BTLocalizedString(@"发送失败") view:UI_Window afterDelay:2];
        }
            
            break;
            
        case MessageComposeResultCancelled:
        {
            //            [MBProgressHUD showHUDByContent:@"发送成功" view:UI_Window afterDelay:2];
        }
            
            break;
            
        default:
            break;
    }
    
    [self.mainTabBarController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
//    [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"appDelegateToLogin"];
    LoginCtrl *loginVC = [[LoginCtrl alloc] init];
    
    UINavigationController *nav
    = [[UINavigationController alloc] initWithRootViewController:loginVC];
    nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [UtilityUI setNavigationStyle:nav.navigationBar];
    nav.navigationBar.barTintColor = [UtilityUI stringTOColor:@"#06bd90"];
    
    
    nav.navigationBar.translucent = NO;
    self.window.rootViewController = nav;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:APPISCALLING];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [BluetoothManager share].isCalling = NO;

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(nonnull NSURL *)url {
    
    return [WXApi handleOpenURL:url delegate:self] && [WeiboSDK handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation {
    return [WXApi handleOpenURL:url delegate:self] && [WeiboSDK handleOpenURL:url delegate:self];
}

/**
 收到一个来自微博客户端程序的请求
 
 收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
 @param request 具体的请求对象
 */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {
    
}

/**
 收到一个来自微博客户端程序的响应
 
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    
}

- (NSString *)localizedString:(NSString *)string {
    switch (_languageIndex) {
        case 1:
            return CustomLocalizedString(string,@"zh-Hans");
        case 2:
            return CustomLocalizedString(string,@"en");
        default: {
            NSArray *languages = [NSLocale preferredLanguages];
            NSString *currentLanguage = [languages objectAtIndex:0];
            if (!([currentLanguage isEqualToString:@"en-US"] ||
                  [currentLanguage isEqualToString:@"en-CN"])) {
                return CustomLocalizedString(string,@"zh-Hans");
            }
            return NSLocalizedString(string, nil);
        }
    }
}

- (BOOL)systemLanguageIsEnglish
{
    if ([(AppDelegate *)[UIApplication sharedApplication].delegate languageIndex] == 0) {
        //获取系统当前语言版本（中文zh-Hans,英文en)
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *currentLanguage = [languages objectAtIndex:0];
        if ([currentLanguage isEqualToString:@"en-US"] ||[currentLanguage isEqualToString:@"en-CN"]) {
            return YES;
        }else{
            return NO;
        }
    }
    else if ([(AppDelegate *)[UIApplication sharedApplication].delegate languageIndex] == 1) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void)changeLanguage:(NSNotification *)notification {
    
    _isEnglish = [self systemLanguageIsEnglish];
    tabBarItem1.title = BTLocalizedString(@"运动");
    tabBarItem2.title = BTLocalizedString(@"排名");
    tabBarItem3.title = BTLocalizedString(@"睡眠");
    tabBarItem4.title = BTLocalizedString(@"心率");
}


@end
