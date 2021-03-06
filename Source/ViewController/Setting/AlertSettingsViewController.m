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

@property (nonatomic , strong) NSMutableArray *miniArray;

@property (nonatomic , strong) NSMutableArray *hourArray;

@property (nonatomic , strong) UIView *coverView;

@property (nonatomic , strong) UIToolbar *toolBar;

@property (nonatomic , copy) NSString *timeStr;

@property (nonatomic , copy) NSString *frequencyStr;

@property (nonatomic , assign) TimePickerSelected timePickerSelected;

@property (nonatomic , assign) NSInteger alertDay;

@property (nonatomic , strong) UISwitch *alertSwitch;

@property (nonatomic , strong) NSMutableArray *alertArray;

@property (nonatomic , strong) BasicInfomationModel *changeModel;

@property (nonatomic , strong) UIView *backgroudView;


@end

@implementation AlertSettingsViewController

- (NSMutableArray *)alertArray
{
    if (!_alertArray) {
        _alertArray = [NSMutableArray array];
    }
    return _alertArray;
}

- (NSMutableArray *)hourArray
{
    if (!_hourArray) {
        _hourArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 24; i++) {
            NSString *time;
            if (i < 10) {
                time = [NSString stringWithFormat:@"0%ld",i];
            }else{
                time = [NSString stringWithFormat:@"%ld",i];
            }
            [_hourArray addObject:time];
        }
    }
    return _hourArray;
}

- (NSMutableArray *)miniArray
{
    if (!_miniArray) {
        _miniArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 60; i++) {
            [_miniArray addObject:@(i)];
        }
    }
    return _miniArray;
}

- (void)viewWillAppear:(BOOL)animated {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(setBasicInfomationSuccess:)
//                                                 name:SET_BASICINFOMATION_SUCCESS
//                                               object:nil];
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
    self.title = BTLocalizedString(@"久坐提醒");
    self.navigationItem.leftBarButtonItem.title = @"";
    self.view.backgroundColor = kThemeGrayColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    _tableView.allowsSelection = NO;
    [self.tableView setTableFooterView:[UIView new]];
    
    self.dataArray = @[BTLocalizedString(@"提醒"),BTLocalizedString(@"开始时间"),BTLocalizedString(@"结束时间"),BTLocalizedString(@"提醒间隔"),BTLocalizedString(@"星期一"),BTLocalizedString(@"星期二"),BTLocalizedString(@"星期三"),BTLocalizedString(@"星期四"),BTLocalizedString(@"星期五"),BTLocalizedString(@"星期六"),BTLocalizedString(@"星期天")];
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
        _startLabel.text = @"07:00";
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
        _endLabel.text = @"09:00";
    }

    
    _frequencyLabel = [[UILabel alloc] initWithFrame:labelFrame];
    if (_changeModel.sportInterval) {
        _frequencyLabel.text = [NSString stringWithFormat:@"%ld%@",_changeModel.sportInterval,BTLocalizedString(@"分钟")];
    }else{
        _frequencyStr =  [NSString stringWithFormat:@"15%@",BTLocalizedString(@"分钟")];;
        _frequencyLabel.text = _frequencyStr;
    }
    
    UISwitch *clockSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _alertSwitch = clockSwitch;
    BOOL switchOpen = [[NSUserDefaults standardUserDefaults] objectForKey:alertSwitchIsOpen]? YES:NO;
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
    
    _backgroudView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, kScreenHeight)];
    _backgroudView.backgroundColor = [UIColor lightGrayColor];
    _backgroudView.alpha = 0.5;
    if (!_alertSwitch.isOn) {
        [_tableView addSubview:_backgroudView];
    }
    _tableView.allowsSelection = _alertSwitch.isOn;
    [clockSwitch addTarget:self action:@selector(openAlarmSetting:) forControlEvents:UIControlEventValueChanged];
    [self openClockDay];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  50,
                                                                  30)];
    [button setTitle:BTLocalizedString(@"确定") forState:UIControlStateNormal];
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
        [_backgroudView removeFromSuperview];
    }else {
        _tableView.allowsSelection = NO;
        [_tableView addSubview:_backgroudView];
    }
}

//开始/结束时间选择
- (void)setUpTimePickerView
{
    [self setUpCoverView];
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
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:BTLocalizedString(@"确定") style:UIBarButtonItemStylePlain target:self action:@selector(removeCoverView)];
    UIBarButtonItem *placeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar.items = @[placeItem, cancelItem];
    [_coverView addSubview:_toolBar];
    
    
}

- (void)removeCoverView
{
    
    switch (self.timePickerSelected) {
            
        case TimePickerSelectedStart:{
            if (!_timeStr) {
                _timeStr = @"07:00";
            }
            _startLabel.text = _timeStr;
        }
            break;
        case TimePickerSelectedEnd:{
            if (!_timeStr) {
                _timeStr = @"09:00";
            }
            _endLabel.text = _timeStr;
        }
            break;
        case TimePickerSelectedFrequency:{
            if (!_frequencyStr) {
                _frequencyStr = [NSString stringWithFormat:@"15%@",BTLocalizedString(@"分钟")];
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
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:BTLocalizedString(@"确定") style:UIBarButtonItemStylePlain target:self action:@selector(removeCoverView)];
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
    if (pickerView == self.miniPickerView) {
        return 1;
    }else{
        return 1;
    }
}

//返回指定列的行数
- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == _timePickerView) {
//        if (component == 0) {
            return self.hourArray.count;
//        }else{
//            return self.miniArray.count;
//        }
    }else{
    return self.miniArray.count;
    }
}

//返回指定列，行的高度，就是自定义行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return  30;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.miniPickerView) {
        return [self.miniArray[row] stringValue];
    }else{
//        if (component == 0) {
            return self.hourArray[row];
//        }else{
//            return [self.miniArray[row] stringValue];
//        }
    }
}

////替换text居中
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//    if (pickerView == _timePickerView) {
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)];
//        
//        label.text = self.timeArray[row];//[m_mutArrSensorList objectAtIndex:row-1];
//        label.textAlignment = NSTextAlignmentCenter;
//        return label;
//    }else{
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)];
//    
//    label.text = [self.miniArray[row] stringValue];//[m_mutArrSensorList objectAtIndex:row-1];
//    label.textAlignment = NSTextAlignmentCenter;
//    return label;
//    }
//}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //获取对应列，对应行的数据
    if (pickerView == _timePickerView) {
        NSString *hour;
//        NSInteger min = 0;
        
        hour = self.hourArray[[self.timePickerView selectedRowInComponent:0]];
//        min = [self.miniArray[[self.timePickerView selectedRowInComponent:1]] integerValue];
        NSString *clockTime ;
//        if (min >= 10) {
            clockTime = [NSString stringWithFormat:@"%@:00",hour];
//        }else{
//            clockTime = [NSString stringWithFormat:@"%@:0%ld",hour,min];
//        }
        
        _timeStr = clockTime;
    }else{
        NSString *time = [NSString stringWithFormat:@"%@%@",_miniArray[row],BTLocalizedString(@"分钟")];
        _frequencyStr = time;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickButton:(UIButton *)button {
//    if (![[BluetoothManager share] isExistCharacteristic]) {
//        return;
//    }
//    [MBProgressHUD showHUDAddedTo:UI_Window animated:YES];
    if (_startLabel.text && _endLabel.text) {
        _changeModel.startTime = [[_startLabel.text substringWithRange:NSMakeRange(0, 2)] integerValue];
        _changeModel.endTime = [[_endLabel.text substringWithRange:NSMakeRange(0, 2)] integerValue];
        NSInteger length = _frequencyLabel.text.length == 3 ? 1 : 2;
        _changeModel.sportInterval = [[_frequencyLabel.text substringWithRange:NSMakeRange(0, length)] integerValue];;
    }
    if (_alertSwitch.isOn) {
        _changeModel.sportSwitch = _alertDay;
    }else{
        _changeModel.sportSwitch = 0;
        [[NSUserDefaults standardUserDefaults] setObject:@(_alertDay) forKey:whichDayIsOpen];
    }
    BOOL change = [DBManager insertOrReplaceBasicInfomation:_changeModel];
    if (!change) {
        DLog(@"存储久坐提醒失败");
    } else {
        [[BluetoothManager share] setTimestamp];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(_alertSwitch.isOn) forKey:alertSwitchIsOpen];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setBasicInfomationSuccess:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:UI_Window animated:YES];
    [MBProgressHUD showHUDByContent:BTLocalizedString(@"保存成功") view:UI_Window afterDelay:1];
    BOOL change = [DBManager insertOrReplaceBasicInfomation:_changeModel];
    if (!change) {
        DLog(@"存储久坐提醒失败");
    }
}

- (void)disConnectPeripheral {
    [MBProgressHUD hideHUDForView:UI_Window
                         animated:YES];
}

@end
