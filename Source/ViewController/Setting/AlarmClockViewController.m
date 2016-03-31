//
//  AlarmClockViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/22.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "AlarmClockViewController.h"

#define switchIsOpen @"switchIsOpen"      //闹钟开关
#define whichDayIsOpen @"whichDayIsOpen"  //哪天开

@interface AlarmClockViewController ()<UITableViewDataSource,UITableViewDelegate , UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataArray;

@property (nonatomic , strong) UILabel *frequencyLabel;

@property (nonatomic , strong) UILabel *timeLabel;

@property (nonatomic , strong) UIView *coverView;

@property (nonatomic , strong) NSDateFormatter *formatter;

@property (nonatomic , strong) UIDatePicker *TimePicker;

@property (nonatomic , strong) UIToolbar *toolBar;

@property (nonatomic , copy) NSString *timeStr;

@property (nonatomic , copy) NSString *frequencyStr;

@property (nonatomic , strong) UIPickerView *miniPickerView;

@property (nonatomic , strong) NSArray *miniArray;

@property (nonatomic , assign) BOOL isTimeSelected;

@property (nonatomic , assign) NSInteger clockDay;

@property (nonatomic , strong) UISwitch *clockSwitch;

@property (nonatomic , strong) NSMutableArray *clockArray;

@property (nonatomic , strong) BasicInfomationModel *changeModel;



@end

@implementation AlarmClockViewController

- (NSMutableArray *)clockArray
{
    if (!_clockArray) {
        _clockArray = [NSMutableArray array];
    }
    return _clockArray;
}

- (NSArray *)miniArray
{
    if (!_miniArray) {
        _miniArray = @[@(15),@(30),@(45),@(60)];
    }
    return _miniArray;
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setBasicInfomationSuccess:)
                                                 name:SET_BASICINFOMATION_SUCCESS
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"闹钟";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    _tableView.allowsSelection = NO;
    [self.tableView setTableFooterView:[UIView new]];
    
    self.dataArray = @[@"闹钟",@"时间",@"提醒间隔",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六",@"星期天"];
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
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 80, 0, 60, 44)];
    NSString *hourStr ;
    NSString *minStr;
    if (_changeModel.clockHour || _changeModel.clockMinute) {
        if (_changeModel.clockHour < 10) {
            hourStr = [NSString stringWithFormat:@"0%ld",_changeModel.clockHour];
        }
        if (_changeModel.clockMinute < 10) {
            minStr = [NSString stringWithFormat:@"0%ld",_changeModel.clockMinute];
        }
      _timeLabel.text = [NSString stringWithFormat:@"%@:%@",hourStr,minStr];
    }else{
        _timeStr =  @"00:00";
      _timeLabel.text = _timeStr;
    }
    
     _frequencyLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 80, 0, 60, 44)];
    if (_changeModel.clockInterval) {
      _frequencyLabel.text = [NSString stringWithFormat:@"%ld分钟",_changeModel.clockInterval];
    }else{
        _frequencyStr =  @"15分钟";
       _frequencyLabel.text = @"15分钟";
    }
    
    
    
    UISwitch *clockSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _clockSwitch = clockSwitch;
    BOOL switchOpen = [[NSUserDefaults standardUserDefaults] objectForKey:switchIsOpen];
    if (switchOpen) {
        [clockSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:switchIsOpen] boolValue]];
        if (_clockSwitch.isOn) {
            _clockDay = _changeModel.clockSwitch;
        }else{
            _clockDay = [[[NSUserDefaults standardUserDefaults] objectForKey:whichDayIsOpen] integerValue];
        }
    }else{
        [clockSwitch setOn:NO];
    }
    
    [clockSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
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
    NSString *clockStr = [self toBinarySystemWithDecimalSystem:_clockDay];
    for (NSInteger i = 0; i < clockStr.length; i++) {
        NSString *subStr = [clockStr substringWithRange:NSMakeRange(i, 1)];
        [self.clockArray addObject:subStr];
    }
    NSInteger tempInteger = 8 - self.clockArray.count;
    for (NSInteger i = 0; i < tempInteger; i++) {
        [self.clockArray addObject:@"0"];
    }
}

- (void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section != 3) return 1;
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
        if (!_clockSwitch) {
        }
        
        cell.accessoryView = _clockSwitch;
    }
    if (indexPath.section == 1) {
        [cell.contentView addSubview:_timeLabel];
    }
    if (indexPath.section == 2) {
        [cell.contentView addSubview:_frequencyLabel];
    }
    if (indexPath.section == 3) {
        cell.imageView.image = [UIImage imageNamed:@"dot-green"];
        cell.imageView.hidden = ![self.clockArray[indexPath.row] boolValue];
        
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
            self.isTimeSelected = YES;
            [self setUpTimePickerView];
        }
            break;
        case 2:
        {
            self.isTimeSelected = NO;
            [self setUpMiniPickerView];
        }
            break;
        case 3:
        {
            UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            selectedCell.imageView.hidden = !selectedCell.imageView.hidden;
            BOOL showImage = !selectedCell.imageView.hidden;
            NSInteger addCount = 0;
            addCount = pow(2, indexPath.row);
            if (showImage) {
                self.clockDay += addCount;
            }else
            {
                self.clockDay -= addCount;
            }
        }
            break;
        default:
            break;
    }
}

- (void)touchRemoveCoverView
{
    [_coverView removeFromSuperview];
}

- (void)timeChange
{
    NSDate *date = _TimePicker.date;
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"HH:mm"];
    }
    _timeStr = [_formatter stringFromDate:date];
}

- (void)setUpTimePickerView
{
    if (!_coverView) {
        [self setUpCoverView];
    }
    
    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, kScreenHeight/2 - 100, kScreenWidth, 200)];
    _TimePicker = picker;
    picker.backgroundColor = [UIColor whiteColor];
    [picker addTarget:self action:@selector(timeChange) forControlEvents:UIControlEventValueChanged];
    picker.datePickerMode = UIDatePickerModeCountDownTimer;
    [_coverView addSubview:picker];
    
    [self.view addSubview:_coverView];
}

//提醒时长选择
- (void)setUpMiniPickerView
{
    self.miniPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0 , kScreenHeight/2 - 100, kScreenWidth, 200)];
    self.miniPickerView.dataSource = self;
    self.miniPickerView.delegate = self;
    self.miniPickerView.backgroundColor = [UIColor whiteColor];
    if (!_coverView) {
        [self setUpCoverView];
    }
    [_coverView addSubview:self.miniPickerView];
    _TimePicker.alpha = 0;
    [self.view addSubview:_coverView];
}

- (void)setUpCoverView
{
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _coverView = coverView;
    coverView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchRemoveCoverView)];
    [coverView addGestureRecognizer:tap];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, kScreenHeight/2 +100, kScreenWidth, 50)];
    _toolBar = toolBar;
    toolBar.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(removeCoverView)];
    UIBarButtonItem *placeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar.items = @[placeItem, cancelItem];
    [_coverView addSubview:_toolBar];
}

-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        _tableView.allowsSelection = YES;
    }else {
        _tableView.allowsSelection = NO;
    }
}

- (void)removeCoverView
{
    if (_isTimeSelected) {
        if (!_timeStr) { 
            _timeStr = @"00:00";
        }
        _timeLabel.text = _timeStr;
    }else{
        if (!_frequencyStr) {
            _frequencyStr = @"15分钟";
        }
        _frequencyLabel.text = _frequencyStr;
    }
    [_coverView removeFromSuperview];
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
    return 4;
}

//返回指定列，行的高度，就是自定义行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return  30;
}

//替换text居中
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)];
    
    label.text = [self.miniArray[row] stringValue];//[m_mutArrSensorList objectAtIndex:row-1];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //获取对应列，对应行的数据
    NSString *time = [NSString stringWithFormat:@"%@分钟",_miniArray[row]];
    _frequencyStr = time;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)clickButton:(UIButton *)button {
    if (![BluetoothManager share].characteristics) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:UI_Window animated:YES];
    if (_timeLabel.text && _frequencyStr) {
        _changeModel.clockHour = [[_timeLabel.text substringWithRange:NSMakeRange(0, 2)] integerValue];
        _changeModel.clockMinute = [[_timeLabel.text substringWithRange:NSMakeRange(3, 2)] integerValue];
        _changeModel.clockInterval = [[_frequencyStr substringWithRange:NSMakeRange(0, 2)] integerValue];;
    }
    if (_clockSwitch.isOn) {
        _changeModel.clockSwitch = _clockDay;
    }else{
        _changeModel.clockSwitch = 0;
        [[NSUserDefaults standardUserDefaults] setObject:@(_clockDay) forKey:whichDayIsOpen];
    }

    [[BluetoothManager share] setBasicInfomation:_changeModel];
    [[NSUserDefaults standardUserDefaults] setObject:@(_clockSwitch.isOn) forKey:switchIsOpen];
}

- (void)setBasicInfomationSuccess:(NSNotification *)notification {
    [MBProgressHUD hideAllHUDsForView:UI_Window animated:YES];
    BOOL change = [DBManager insertOrReplaceBasicInfomation:_changeModel];
    if (!change) {
        DLog(@"存储闹钟失败");
    }
}


@end
