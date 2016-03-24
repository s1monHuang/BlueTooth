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

@interface AppDelegate ()

@property (nonatomic,strong) OperateViewModel *operateVM;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [DBManager initApplicationsDB];
    self.operateVM = [OperateViewModel viewModel];
    if([[UserManager defaultInstance] hasUser])
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
    //自动登陆
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    
    if (userName && password) {
        [self.operateVM loginWithUserName:userName password:password];
        
        self.operateVM.finishHandler = ^(BOOL finished, id userInfo) { // 网络数据回调
            if (finished) {
                [[UserManager defaultInstance] saveUser:userInfo];
                
                BasicInfomationModel *infoModel = [[BasicInfomationModel alloc] init];
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
            }
        };

    }
    
    SportCtrl *sportVC = [[SportCtrl alloc] init];
    UINavigationController *navSport
    = [[UINavigationController alloc] initWithRootViewController:sportVC];
    UIImage * normalImage1 = [[UIImage imageNamed:@"movement2.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage * selectImage1 = [[UIImage imageNamed:@"movement1.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem * tabBarItem1 = [[UITabBarItem alloc]initWithTitle:@"运动" image:normalImage1 selectedImage:selectImage1];
    navSport.tabBarItem = tabBarItem1;
    [UtilityUI setNavigationStyle:navSport.navigationBar];
    [UtilityUI setTabBarStyle:tabBarItem1];
    
    RankingCtrl *RankVC = [[RankingCtrl alloc] init];
    UINavigationController *navRanding
    = [[UINavigationController alloc] initWithRootViewController:RankVC];
    UIImage * normalImage2 = [[UIImage imageNamed:@"ranking2.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage * selectImage2 = [[UIImage imageNamed:@"ranking1.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navRanding.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"排名" image:normalImage2 selectedImage:selectImage2];
    [UtilityUI setNavigationStyle:navRanding.navigationBar];
    [UtilityUI setTabBarStyle:navRanding.tabBarItem];
    
    SleepCtrl *sleepVC = [[SleepCtrl alloc] init];
    UINavigationController *navSleep
    = [[UINavigationController alloc] initWithRootViewController:sleepVC];
    UIImage * normalImage3 = [[UIImage imageNamed:@"sleep2.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage * selectImage3 = [[UIImage imageNamed:@"sleep1.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem * tabBarItem3 = [[UITabBarItem alloc]initWithTitle:@"睡眠" image:normalImage3 selectedImage:selectImage3];
    navSleep.tabBarItem = tabBarItem3;
    [UtilityUI setNavigationStyle:navSleep.navigationBar];
    [UtilityUI setTabBarStyle:tabBarItem3];
    
    HeartbeatCtrl *heartVC = [[HeartbeatCtrl alloc] init];
    UINavigationController *navHeart
    = [[UINavigationController alloc] initWithRootViewController:heartVC];
    UIImage * normalImage4 = [[UIImage imageNamed:@"heartbeat2.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage * selectImage4 = [[UIImage imageNamed:@"heartbeat1.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem * tabBarItem4 = [[UITabBarItem alloc]initWithTitle:@"心跳" image:normalImage4 selectedImage:selectImage4];
    navHeart.tabBarItem = tabBarItem4;
    [UtilityUI setNavigationStyle:navHeart.navigationBar];
    [UtilityUI setTabBarStyle:tabBarItem4];
    
    
    PersonalCtrl *personalVC = [[PersonalCtrl alloc] init];
    UINavigationController *navPersonal
    = [[UINavigationController alloc] initWithRootViewController:personalVC];
    UIImage * normalImage5 = [[UIImage imageNamed:@"personal2.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage * selectImage5 = [[UIImage imageNamed:@"personal1.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem * tabBarItem5 = [[UITabBarItem alloc]initWithTitle:@"个人" image:normalImage5 selectedImage:selectImage5];
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

+ (AppDelegate *)defaultDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication]delegate];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
