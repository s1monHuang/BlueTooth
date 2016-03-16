//
//  nickNameController.h
//  BlueToothBracelet
//
//  Created by azz on 16/3/16.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^nickNameCallBack)(NSString *nickName);

@interface nickNameController : UIViewController

@property (nonatomic , copy) nickNameCallBack nickName;

- (void)returnNickName: (nickNameCallBack)nickName;

@end
