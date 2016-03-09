//
//  BaseViewController.m
//  DGroupDoctor
//
//  Created by Ddread Li on 6/23/15.
//  Copyright (c) 2015 Dachen Tech. All rights reserved.
//

#import "BaseViewController.h"
//#import "MobClick.h"

@implementation BaseViewController


#pragma mark - 友盟统计
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[MobClick beginLogPageView:NSStringFromClass([self class])];

//    backItem(self.navigationItem.backBarButtonItem);
    [self viewWillLoad];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[MobClick endLogPageView:NSStringFromClass([self class])];
}

-(void)viewWillLoad
{
    
}



@end
