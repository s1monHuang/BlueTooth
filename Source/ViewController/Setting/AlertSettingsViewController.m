//
//  AlertSettingsViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/22.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "AlertSettingsViewController.h"

typedef NS_ENUM(NSInteger, TimePickerSelected) {
    TimePickerSelectedStart = 0,         //选择开始时间
    TimePickerSelectedEnd,
    TimePickerSelectedFrequency
};

#define alertSwitchIsOpen  @"alertSwitchIsOpen"         //提醒设置开关

#define whichDayIsOpen     @"whichDayIsOpen"            //哪天开

@interface AlertSettingsViewController ()<UITableViewDelegate,UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *dataArray;

@property (nonatomic , strong) UIPickerView *miniPickerView;

@property (nonatomic , strong) UIPickerView *timePickerView;

@property (nonatomic , strong) UILabel *startLabel;

@property (nonatomic , strong) UILabel *endLabel;

@property (nonatomic , strong) UILabel *frequencyLabel;

@property (nonatomic , strong) NSArray *miniArray;

@property (nonatomic , strong) NSMutableArray *timeArray;

@property (nonatomic , strong) UIView *coverView;
//
//@property (nonatomic , strong) NSDateFormatter *formatter;
//
//@property (nonatomic , strong) UIDatePicker *TimePicker;

@property (nonatomic , strong) UIToolbar *toolBar;

@property (nonatomic , copy) NSString *timeStr;

@property (nonatomic , copy) NSString *frequencyStr;

@property (nonatomic , assign) TimePickerSelected timePickerSelected;

@property (nonatomic , assign) NSInteger alertDay;

@property (nonatomic , strong) UISwitch *alertSwitch;

@property (nonatomic , strong) NSMutableArray *alertArray;

@property (nonatomic , strong) BasicInfomationModel *changeModel;



@end

@implementation AlertSettingsViewController

- (NSMutableArray *)alertArray
{
    if (!_alertArray) {
        _alertArray = [NSMutableArray array];
    }
    return _alertArray;
}

- (NSMutableArray *)timeArray
{
    if (!_timeArray) {
        _timeArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 24; i++) {
            NSString *time;
            if (i < 10) {
                time = [NSString stringWithFormat:@"0%ld:00",i];
            }else{
                time = [NSString stringWithFormat:@"%ld:00",i];
            }
            [_timeArray addObject:time];
        }
    }
    return _timeArray;
}

- (NSArray *)miniArray
{
    if (!_miniArray) {
        _miniArray = @[@(0),@(15),@(30),@(45),@(60)];
    }
    return _miniArray;
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setBasicInfomationSuccess:)
                                                 name:SET_BASICINFOMATION_SUCCESS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disConnectPeripheral)
                                                 name:DISCONNECT_PERIPHERAL
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"提醒";
    self.navigationItem.leftBarButtonItem.title = @"";
    self.view.backgroundColor = kThemeGrayColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    _tableView.allowsSelection = NO;
    [self.tableView setTableFooterView:[UIView new]];
    
    self.dataArray = @[@"提醒",@"开始时间",@"结束时间",@"提醒间隔",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期天"];
    // 返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setFrame:CGRectMake(0, 0, 30, 44)];
    [backBtn setImage:[UIImage imageNamed:@"common_btn_back_nor.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    backBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    _changeModel = [DBManager selectBasicInfomation];
    if (!_changeModel) {
        _changeModel = [[BasicInfomationModel alloc] init];
    }
    CGRect labelFrame = CGRectMake(kScreenWidth - 80, 0, 60, 44);
    
    _startLabel = [[UILabel alloc] initWithFrame:labelFrame];
    NSString *startStr;
    if (_changeModel.startTime) {
        if (_changeModel.startTime < 10) {
            startStr = [NSString stringWithFormat:@"0%ld:00",_changeModel.startTime];
        }else{
            startStr = [NSString stringWithFormat:@"%ld:00",_changeModel.startTime];
        }
        _startLabel.text = [NSString stringWithFormat:@"%@",startStr];
    }else{
        _startLabel.text = @"00:00";
    }
    
    _endLabel = [[UILabel alloc] initWithFrame:labelFrame];
    NSString *endStr;
    if (_changeModel.endTime) {
        if (_changeModel.endTime < 10) {
            endStr = [NSString stringWithFormat:@"0%ld:00",_changeModel.endTime];
        }else{
            endStr = [NSString stringWithFormat:@"%ld:00",_changeModel.endTime];
        }
        _endLabel.text = [NSString stringWithFormat:@"%@",endStr];
    }else{
        _endLabel.text = @"00:00";
    }

    
    _frequencyLabel = [[UILabel alloc] initWithFrame:labelFrame];
    if (_changeModel.sportInterval) {
        _frequencyLabel.text = [NSString stringWithFormat:@"%ld分钟",_changeModel.sportInterval];
    }else{
        _frequencyStr =  @"15分钟";
        _frequencyLabel.text = _frequencyStr;
    }
    
    UISwitch *clockSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _alertSwitch = clockSwitch;
    BOOL switchOpen = [[NSUserDefaults standardUserDefaults] objectForKey:alertSwitchIsOpen];
    if (switchOpen) {
        [clockSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:alertSwitchIsOpen] boolValue]];
        if (_alertSwitch.isOn) {
            _alertDay = _changeModel.sportSwitch;
        }else{
            _alertDay = [[[NSUserDefaults standardUserDefaults] objectForKey:whichDayIsOpen] integerValue];
        }
    }else{
        [clockSwitch setOn:NO];
    }
    _tableView.allowsSelection = _alertSwitch.isOn;
    [clockSwitch addTarget:self action:@selector(openAlarmSetting:) forControlEvents:UIControlEventValueChanged];
    [self openClockDay];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  50,
                                                                  30)];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(clickButton:)
     forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//  十进制转二进制
- (NSString *)toBinarySystemWithDecimalSystem:(NSInteger )num
{
    
    NSInteger remainder = 0;      //余数
    NSInteger divisor = 0;        //除数
    
    NSString * prepare = @"";
    
    while (true)
    {
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%ld",remainder];
        
        if (divisor == 0)
        {
            break;
        }
    }
    NSString * result = @"";
    for (NSInteger i = prepare.length - 1; i >= 0; i --)
    {
        result = [result stringByAppendingFormat:@"%@",
                  [prepare substringWithRange:NSMakeRange(i , 1)]];
    }
    
    return result;
}

- (void)openClockDay
{
    NSString *clockStr = [self toBinarySystemWithDecimalSystem:_alertDay];
    if (_alertDay > 0) {
        for (NSInteger i = clockStr.length -1; i >= 0; i--) {
            NSString *subStr = [clockStr substringWithRange:NSMakeRange(i, 1)];
            [self.alertArray addObject:subStr];
        }
        
    }else{
        
    }
    NSInteger tempInteger = 8 - self.alertArray.count;
    for (NSInteger i = 0; i < tempInteger; i++) {
        [self.alertArray addObject:@"0"];
    }
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
        cell.accessoryView = _alertSwitch;
    }
    if (indexPath.section == 1) {
        [cell.contentView addSubview:_startLabel];
    }
    if (indexPath.section == 2) {
        [cell.contentView addSubview:_endLabel];
    }
    if (indexPath.section == 3) {
        [cell.contentView addSubview:_frequencyLabel];
    }
    if (indexPath.section == 4) {
        cell.imageView.image = [UIImage imageNamed:@"dot-green"];
        cell.imageView.hidden = ![self.alertArray[indexPath.row] boolValue];
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
            self.timePickerSelected = TimePickerSelectedStart;
            [self setUpTimePickerView];
        }
            break;
        case 2:
        {
            self.timePickerSelected = TimePickerSelectedEnd;
            [self setUpTimePickerView];
        }
            break;
        case 3:
        {
            self.timePickerSelected = TimePickerSelectedFrequency;
            [self setUpMiniPickerView];
        }
            break;
        case 4:
        {
            UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            selectedCell.imageView.hidden = !selectedCell.imageView.hidden;
            BOOL showImage = !selectedCell.imageView.hidden;
            //            DLog(@"%d",showImage);
            NSInteger addCount = 0;
            addCount = pow(2, indexPath.row);
            if (showImage) {
                _alertDay += addCount;
            }else
            {
                _alertDay -= addCount;
            }
            
        }
            break;
        default:
            break;
    }
    
    
}

//提醒设置开关
- (void)openAlarmSetting:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        _tableView.allowsSelection = YES;
    }else {
        _tableView.allowsSelection = NO;
    }
}

//开始/结束时间选择
- (void)setUpTimePickerView
{
//    if (!_coverView) {
        [self setUpCoverView];
//    }
    self.timePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0 , kScreenHeight/2 - 100, kScreenWidth, 200)];
    self.timePickerView.dataSource = self;
    self.timePickerView.delegate = self;
    self.timePickerView.backgroundColor = [UIColor whiteColor];
    
    [_coverView addSubview:_timePickerView];
    [_toolBar removeFromSuperview];
    CGFloat toolBarY = CGRectGetMaxY(self.timePickerView.frame);
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, toolBarY, kScreenWidth, 50)];
    _toolBar = toolBar;
    toolBar.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(removeCoverView)];
    UIBarButtonItem *placeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar.items = @[placeItem, cancelItem];
    [_coverView addSubview:_toolBar];
    
    
}

- (void)removeCoverView
{
    
    switch (self.timePickerSelected) {
            
        case TimePickerSelectedStart:{
            if (!_timeStr) {
                _timeStr = @"00:00";
            }
            _startLabel.text = _timeStr;
        }
            break;
        case TimePickerSelectedEnd:{
            if (!_timeStr) {
                _timeStr = @"00:00";
            }
            _endLabel.text = _timeStr;
        }
            break;
        case TimePickerSelectedFrequency:{
            if (!_frequencyStr) {
                _frequencyStr = @"15分钟";
            }
            _frequencyLabel.text = _frequencyStr;
        }
            break;
        default:
            break;
    }
    [_coverView removeFromSuperview];
    _coverView = nil;
}

- (void)touchRemoveCoverView
{
    [_coverView removeFromSuperview];
}

//- (void)timeChange
//{
//    NSDate *date = _TimePicker.date;
//    if (!_formatter) {
//        _formatter = [[NSDateFormatter alloc] init];
//        [_formatter setDateFormat:@"HH:mm"];
//    }
//    _timeStr = [_formatter stringFromDate:date];
//}

//提醒时长选择
- (void)setUpMiniPickerView
{
    self.miniPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0 , kScreenHeight/2 - 100, kScreenWidth, 200)];
    self.miniPickerView.dataSource = self;
    self.miniPickerView.delegate = self;
    self.miniPickerView.backgroundColor = [UIColor whiteColor];
//    if (!_coverView) {
        [self setUpCoverView];
//    }
    [_coverView addSubview:self.miniPickerView];
    [_toolBar removeFromSuperview];
    CGFloat toolBarY = CGRectGetMaxY(self.miniPickerView.frame);
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, toolBarY, kScreenWidth, 50)];
    _toolBar = toolBar;
    toolBar.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(removeCoverView)];
    UIBarButtonItem *placeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar.items = @[placeItem, cancelItem];
    [_coverView addSubview:_toolBar];
    self.timePickerView.alpha = 0;
}

- (void)setUpCoverView
{
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _coverView = coverView;
    coverView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchRemoveCoverView)];
    [coverView addGestureRecognizer:tap];
    
    [self.view addSubview:_coverView];
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
    return 5;
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
    if (pickerView == _timePickerView) {
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
    if (pickerView == _timePickerView) {
        NSString *time = _timeArray[row];
        _timeStr = time;
    }else{
        NSString *time = [NSString stringWithFormat:@"%@分钟",_miniArray[row]];
        _frequencyStr = time;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickButton:(UIButton *)button {
    if (![[BluetoothManager share] isExistCharacteristic]) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:UI_Window animated:YES];
    if (_startLabel.text && _endLabel.text) {
        _changeModel.startTime = [[_startLabel.text substringWithRange:NSMakeRange(0, 2)] integerValue];
        _changeModel.endTime = [[_endLabel.text substringWithRange:NSMakeRange(0, 2)] integerValue];
        _changeModel.sportInterval = [[_frequencyStr substringWithRange:NSMakeRange(0, 2)] integerValue];;
    }
    if (_alertSwitch.isOn) {
        _changeModel.sportSwitch = _alertDay;
    }else{
        _changeModel.sportSwitch = 0;
        [[NSUserDefaults standardUserDefaults] setObject:@(_alertDay) forKey:alertSwitchIsOpen];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@(_alertSwitch.isOn) forKey:alertSwitchIsOpen];
    [[BluetoothManager share] setBasicInfomation:_changeModel];
}

- (void)setBasicInfomationSuccess:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:UI_Window animated:YES];
    BOOL change = [DBManager insertOrReplaceBasicInfomation:_changeModel];
    if (!change) {
        DLog(@"存储闹钟失败");
    }
}

- (void)disConnectPeripheral {
    [MBProgressHUD hideHUDForView:UI_Window
                         animated:YES];
}

@end
