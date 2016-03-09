//
//  BaseViewModel.h
//  DGroupDoctor
//
//  Created by Ddread Li on 6/30/15.
//  Copyright (c) 2015 Dachen Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseViewModel : NSObject

@property (nonatomic, copy) void (^finishHandler)(BOOL finished, id userInfo);
@property (nonatomic, assign) BOOL startLoading;
@property (nonatomic, assign) BOOL startLoadingOnScreen; // 转菊花时不允操作

+ (instancetype)viewModel;
@end
