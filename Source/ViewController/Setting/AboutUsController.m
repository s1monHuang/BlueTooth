//
//  AboutUsController.m
//  BlueToothBracelet
//
//  Created by azz on 16/7/1.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "AboutUsController.h"

@implementation AboutUsController

- (void)viewDidLoad
{
    self.title = BTLocalizedString(@"关于我们");
    self.view.backgroundColor = kThemeGrayColor;
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight*0.5 - 60, kScreenWidth, 40)];
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoPlist objectForKey:@"CFBundleVersion"];
    versionLabel.text = [NSString stringWithFormat:@"%@:%@",BTLocalizedString(@"当前版本"),version];
    versionLabel.font = [UIFont systemFontOfSize:18];
    versionLabel.textColor = [UIColor lightGrayColor];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:versionLabel];
    
}


@end
