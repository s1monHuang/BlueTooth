//
//  LanguageViewController.m
//  BlueToothBracelet
//
//  Created by snhuang on 16/8/24.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "LanguageViewController.h"

@interface LanguageViewController () {
    NSInteger _selectedIndex;
    UIImageView *_imageView;
}

@end

@implementation LanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.view.height)
                                              style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_tableView];
    
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"language_check"]];
    [_imageView setFrame:CGRectMake(kScreenWidth - 40,
                                   10,
                                   21.5,
                                   24.5)];
    
    _selectedIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:KEY_SELECTED_LANGUAGE] integerValue];
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 80, 80)];
    [rightBtn setTitle:BTLocalizedString(@"完成") forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(saveLanguage) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [rightView addSubview:rightBtn];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItem = item;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"identifier"];
    }
    
    if (_selectedIndex == indexPath.row) {
        [cell.contentView addSubview:_imageView];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"跟随语言";
            break;
        case 1:
            cell.textLabel.text = @"中文";
            break;
        default:
            cell.textLabel.text = @"English";
            break;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [_imageView removeFromSuperview];
    [cell.contentView addSubview:_imageView];
    _selectedIndex = indexPath.row;
}

- (void)saveLanguage {
    [[NSUserDefaults standardUserDefaults] setObject:@(_selectedIndex)
                                              forKey:KEY_SELECTED_LANGUAGE];
    [self.navigationController popViewControllerAnimated:YES];
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setLanguageIndex:_selectedIndex];
    NSLog(@"%@",BTLocalizedString(@"防丢提醒"));
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_CHANGE_LANGUAGE object:nil];
}

@end
