//
//  AlertSettingsViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/22.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "AlertSettingsViewController.h"

@interface AlertSettingsViewController ()<UITableViewDelegate,UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *dataArray;

@property (nonatomic , strong) UIPickerView *timePickerView;

@property (nonatomic , strong) UIPickerView *miniPickerView;

@property (nonatomic , strong) UILabel *startLabel;

@property (nonatomic , strong) UILabel *endLabel;

@property (nonatomic , strong) UILabel *frequencyLabel;

@property (nonatomic , strong) NSMutableArray *timeArray;

@property (nonatomic , strong) NSArray *miniArray;


@end

@implementation AlertSettingsViewController

- (NSMutableArray *)timeArray
{
    if (!_timeArray) {
        _timeArray = [NSMutableArray array];
        for (int i = 0; i < 24; i++) {
            NSString *time = [NSString stringWithFormat:@"%d:00",i];
            [_timeArray addObject:time];
        }
    }
    return _timeArray;
}

- (NSArray *)miniArray
{
    if (!_miniArray) {
        _miniArray = @[@(15),@(30),@(45),@(60)];
    }
    return _miniArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"提醒";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setTableFooterView:[UIView new]];
    
    self.dataArray = @[@"提醒",@"开始时间",@"结束时间",@"提醒间隔",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期天"];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)return 0.1;
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section != 4) return 1;
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    NSInteger count = indexPath.row + indexPath.section;
    cell.textLabel.text = self.dataArray[count];
    
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [mySwitch setOn:NO];
        [mySwitch addTarget:self action:@selector(openAlarmSetting) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = mySwitch;
    }
    if (indexPath.section == 1) {
        _startLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 80, 0, 60, 44)];
        _startLabel.text = @"7:00";
        [cell.contentView addSubview:_startLabel];
    }
    if (indexPath.section == 2) {
        _endLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 80, 0, 60, 44)];
        _endLabel.text = @"18:00";
        [cell.contentView addSubview:_endLabel];
    }
    if (indexPath.section == 3) {
        _frequencyLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 80, 0, 60, 44)];
        _frequencyLabel.text = @"15分钟";
        [cell.contentView addSubview:_frequencyLabel];
    }
    if (indexPath.section == 4) {
        cell.imageView.image = [UIImage imageNamed:@"dot-green"];
        cell.imageView.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            
        }
            break;
        case 1:
        {
            [self setUpTimePickerView];
        }
            break;
        case 2:
        {
            [self setUpTimePickerView];
        }
            break;
        case 3:
        {
            [self setUpMiniPickerView];
        }
            break;
        case 4:
        {
            UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            selectedCell.imageView.hidden = !selectedCell.imageView.hidden;
            
        }
            break;
        default:
            break;
    }
    
    
}

//提醒设置开关
- (void)openAlarmSetting
{
    
}

//开始/结束时间选择
- (void)setUpTimePickerView
{
    self.timePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(kScreenWidth - 80 , 64 + 0.2 + 44 , 50, 132)];
    self.timePickerView.dataSource = self;
    self.timePickerView.delegate = self;
    self.timePickerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.timePickerView];
}

//提醒时长选择
- (void)setUpMiniPickerView
{
    self.miniPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(kScreenWidth - 80 , 64 + 0.2 + 44 , 50, 132)];
    self.miniPickerView.dataSource = self;
    self.miniPickerView.delegate = self;
    self.miniPickerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.miniPickerView];
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource
//返回有几列
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//返回指定列的行数
- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == _timePickerView) {
        return self.timeArray.count;
    }else{
        return 4;
    }
    
}

//返回指定列，行的高度，就是自定义行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return  30;
}

//替换text居中
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    if (pickerView == self.timePickerView) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)];
        
        label.text = self.timeArray[row];//[m_mutArrSensorList objectAtIndex:row-1];
        label.textAlignment = NSTextAlignmentCenter;
        return label;
    }else{
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)];
        
        label.text = [self.miniArray[row] stringValue];//[m_mutArrSensorList objectAtIndex:row-1];
        label.textAlignment = NSTextAlignmentCenter;
        return label;
    }
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //获取对应列，对应行的数据
    if (pickerView == self.timePickerView) {
        NSString *time= self.timeArray[row];
        self.startLabel.text = time;
        [self.timePickerView removeFromSuperview];
    }
    if (pickerView == self.miniPickerView) {
        NSString *time = [NSString stringWithFormat:@"%@分钟",_miniArray[row]];
        _frequencyLabel.text = time;
        [self.miniPickerView removeFromSuperview];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
