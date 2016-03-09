//
//  OperateViewModel.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/7/5.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "OperateViewModel.h"

#import "UserOperator.h"

@interface OperateViewModel ()
@property (nonatomic, strong)UserOperator *userOperator;
@end

@implementation OperateViewModel

// 登录
- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password
{
    if(!self.userOperator){
        self.userOperator = [UserOperator requestOperator];
    }
    
    [self.userOperator loginWithUserName:userName password:password callBack:^(BOOL success, id responseObject, NSError *error) {
        self.startLoading = NO;
        if (success) {
            
            if([responseObject[@"retCode"] isEqualToString:@"000"])
            {
                if (self.finishHandler) self.finishHandler(YES, responseObject[@"userInfo"]);
            }else{
                if (self.finishHandler) self.finishHandler(NO, responseObject[@"retMsg"]);
            }
            
        } else {
            if (self.finishHandler) self.finishHandler(NO, errorMsg);
        }
    }];
    
}

- (void)requestRankingList{
    if(!self.userOperator){
        self.userOperator = [UserOperator requestOperator];
    }
    
    self.startLoading = YES;
    //[self.userOperator requestRankingList:^(BOOL success, id responseObject, NSError *error){
        
        
        
   // }];
}

@end
