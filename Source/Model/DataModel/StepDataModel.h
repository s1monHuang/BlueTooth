//
//  StepDataModel.h
//  BlueToothBracelet
//
//  Created by azz on 16/3/28.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StepDataModel : NSObject

@property (nonatomic,strong) NSString *userId;       //用户id

@property (nonatomic,strong) NSString *recordDate;   //记录日期

@property (nonatomic,strong) NSString *stepNum;      //步数

@end
