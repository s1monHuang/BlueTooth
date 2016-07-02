//
//  ConfigHeader.h
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/3.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#ifndef BlueToothBracelet_ConfigHeader_h
#define BlueToothBracelet_ConfigHeader_h

//////////////////////////////////////*IP*/////////////////////////////////////

// api服务器地址
#define kAppApiServer                            @"http://112.74.100.227:8080"
#define kAppDomain                               @"https://www.bcdest.com:8080"

/////////////////////////////////*Storyboard*/////////////////////////////////

#define kMainStoryboard                      @"Main"
#define kHomeStoryboard                      @"Home"
#define kPatientStoryboard                   @"Patient"
#define kFriendStoryboard                    @"Friend"
#define kMyStoryboard                        @"My"
#define kLoginStoryboard                     @"Login"

///////////////////////////////////////*Color*//////////////////////////////////////////////

#define kThemeColor                          RGB(56, 134, 150)      // 主题颜色
#define kThemeTintColor                      RGB(242, 108, 154)     // 主题次色
#define kThemeGrayColor                      RGB(235, 239, 243)     // 主题灰色
#define KThemeGreenColor   [UtilityUI stringTOColor:@"#06bd90"]     // 字体绿色

#define UI_Window    [[[UIApplication sharedApplication] delegate] window] //获得window

#define kScreenSize           [[UIScreen mainScreen] bounds].size                 //(e.g. 320,480)
#define kScreenWidth          [[UIScreen mainScreen] bounds].size.width           //(e.g. 320)
#define kScreenHeight         [[UIScreen mainScreen] bounds].size.height          //包含状态bar的高度(e.g. 480)

#define UI_Window    [[[UIApplication sharedApplication] delegate] window] //获得window


#endif









