//
//  AgeViewController.h
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/12.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ageIsChangeNotification   @"ageWasChanged"     //年龄改变通知

@interface AgeViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>{}

@property (strong, nonatomic) UIPickerView *pickerView;
@property (nonatomic) BOOL isJump;

@end
