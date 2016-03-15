//
//  myDataController.m
//  BlueToothBracelet
//
//  Created by azz on 16/3/15.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import "myDataController.h"
#import "myDataCell.h"
#import "myDataCell.h"

@interface myDataController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic , strong) UITableView *tableView;

@property (nonatomic , strong) NSArray *keyArray;

@property (nonatomic , strong) NSArray *valueArray;

@property (nonatomic , strong) UIView *bottomView;


@end

@implementation myDataController

static NSString* identifier =@"PersonalCell";

-(NSArray *)keyArray
{
    if (!_keyArray) {
        _keyArray = @[@"昵称",@"性别",@"年龄",@"身高",@"体重",@"步长"];
    }
    return _keyArray;
}

- (NSArray *)valueArray
{
    if (!_valueArray) {
        _valueArray = @[CurrentUser.nickName, CurrentUser.sex, CurrentUser.age, CurrentUser.high, CurrentUser.weight, CurrentUser.stepLong];
    }
    return _valueArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的资料";
    self.view.backgroundColor = kThemeGrayColor;
    self.navigationController.navigationBar.backgroundColor = kThemeColor;
    //tableView
    [self setUpTableView];
    
    //bottomView
    [self setUpBottomView];
}

- (void)setUpTableView
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44 * 6) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName: @"myDataCell" bundle:nil] forCellReuseIdentifier:identifier];
    
    [self.view addSubview:_tableView];
}

- (void)setUpBottomView
{
    CGFloat bottomViewY = CGRectGetMaxY(_tableView.frame);
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, bottomViewY + 20, self.view.width, 60)];
    _bottomView = bottomView;
    bottomView.backgroundColor = kThemeGrayColor;
    
    CGFloat buttonWidth = (self.view.width - 45) *0.5;
    
    UIButton *resetBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, buttonWidth, 40)];
    resetBtn.backgroundColor = kThemeTintColor;
    [resetBtn addTarget:self action:@selector(resetClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:resetBtn];
    
    UIButton *measureBtn = [[UIButton alloc] initWithFrame:CGRectMake(buttonWidth + 30, 10, buttonWidth, 40)];
    measureBtn.backgroundColor = kThemeColor;
    [measureBtn addTarget:self action:@selector(measureClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:measureBtn];
    
    [self.view addSubview:bottomView];
    
}

#pragma mark - buttonClick

- (void)resetClick
{
    
}

- (void)measureClick
{
    
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    myDataCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
//    
//    for (UIView *subview in cell.contentView.subviews)
//    {
//        [subview removeFromSuperview];
//    }
    cell.textLabel.text = self.keyArray[indexPath.row];
    [cell.keyLabel setText:self.keyArray[indexPath.row]];
    [cell.valueLabel setText:self.valueArray[indexPath.row]];
    cell.valueLabel.textAlignment = NSTextAlignmentRight;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
