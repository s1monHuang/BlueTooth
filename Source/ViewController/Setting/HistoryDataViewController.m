//
//  HistoryDataViewController.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/4.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "HistoryDataViewController.h"
#import "OperateViewModel.h"
#import "MJExtension.h"
#import "StepDataModel.h"
#import "SleepDataModel.h"
#import "FSCalendar.h"
#import "PNCircleChart.h"
#import "DBManager.h"

typedef NS_ENUM(NSInteger, HistoryDataType) {
    HistoryDataTypeDay = 0,              //日数据
    HistoryDataTypeWeek,                //周数据
    HistoryDataTypeMonth                //月数据
    
};

@interface HistoryDataViewController () <UIGestureRecognizerDelegate,FSCalendarDataSource,FSCalendarDelegate>

@property (nonatomic,strong) NSMutableArray *sportDataArray;
@property (nonatomic,strong) NSMutableArray *sleepDataArray;

@property (nonatomic , strong) UISegmentedControl *segmentedControl;

@property (nonatomic , strong) UIButton *dayBtn;

@property (nonatomic , strong) UIButton *weekBtn;

@property (nonatomic , strong) UIButton *monthBtn;

@property (nonatomic , strong) OperateViewModel *operateVM;

@property (nonatomic , strong) OperateViewModel *operateVM1;

@property (nonatomic , strong) OperateViewModel *operateVM2;

//步数
@property (nonatomic , assign) NSInteger dayStepCount;
@property (nonatomic , assign) NSInteger weekStepCount;
@property (nonatomic , assign) NSInteger monthStepCount;

//浅睡眠
@property (nonatomic , assign) NSInteger dayQsmCount;
@property (nonatomic , assign) NSInteger weekQsmCount;
@property (nonatomic , assign) NSInteger monthQsmCount;

//深睡眠
@property (nonatomic , assign) NSInteger daySsmCount;
@property (nonatomic , assign) NSInteger weekSsmCount;
@property (nonatomic , assign) NSInteger monthSsmCount;

@property (nonatomic , strong) UIView *centerView;

@property (nonatomic , strong) UILabel *stepLabel;

@property (nonatomic , strong) UILabel *bottomEnergyLabel;
@property (nonatomic , strong) UILabel *bottomStepLabel;
@property (nonatomic , strong) UILabel *bottomDistanceLabel;

@property (nonatomic , strong) FSCalendar *fsCalender;

@property (nonatomic , strong) UIView *coverView;

@property (nonatomic , strong) UIToolbar *toolBar;

@property (nonatomic , strong) NSDate *selectedDate;

@property (nonatomic , strong) UIView *rightView;

@property (nonatomic , strong) UIView *bottomView;

@property (nonatomic , strong) UIView *sleepView;

@property (nonatomic) PNCircleChart * circleChart;

@property (nonatomic) UILabel *sleepTimeValue;      //显示睡眠时长
@property (nonatomic) UILabel *ssleepTimeValue;     //深睡眠时长
@property (nonatomic) UILabel *qsleepTimeValue;     //浅睡眠时长

@property (strong,nonatomic) UIView *chartView;
@property (strong,nonatomic) UIView *circleBgView;

@property (nonatomic , strong) UILabel *selectedDateLabel;

@property (nonatomic , strong) UIView *backgroundView;

@property (nonatomic , assign) HistoryDataType HistoryData;

@end

@implementation HistoryDataViewController

- (NSMutableArray *)sportDataArray
{
    if (!_sportDataArray) {
        _sportDataArray = [NSMutableArray array];
    }
    return _sportDataArray;
}

- (NSMutableArray *)sleepDataArray
{
    if (!_sleepDataArray) {
        _sleepDataArray = [NSMutableArray array];
    }
    return _sleepDataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"数据中心";
    self.view.backgroundColor = kThemeGrayColor;
    self.operateVM = [OperateViewModel viewModel];
    self.operateVM1 = [OperateViewModel viewModel];
    self.operateVM2 = [OperateViewModel viewModel];
    self.dataType = 0;
    self.HistoryData = HistoryDataTypeDay;
    
    _dayStepCount = 0;
    _weekStepCount = 0;
    _monthStepCount = 0;
    
    //浅睡眠
    _dayQsmCount = 0;
    _weekQsmCount = 0;
    _monthQsmCount = 0;
    //深睡眠
    _daySsmCount = 0;
    _weekSsmCount = 0;
    _monthSsmCount = 0;
    
    //
    [self setUpRightBarButtonItem];
    //获取数据
    [self getHistoryData];
    //分页,日周月按钮
    [self setUpBtn];
    //步数
    [self setUpStepView];
    //睡眠时间
    [self setUpSleepView];
}

- (void)setUpRightBarButtonItem
{
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
    _rightView = rightView;
    UILabel *selectedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    _selectedDateLabel = selectedDateLabel;
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    selectedDateLabel.text = dateStr;
    selectedDateLabel.font = [UIFont systemFontOfSize:10];
    selectedDateLabel.textAlignment = NSTextAlignmentRight;
    [selectedDateLabel setTextColor:[UIColor whiteColor]];
    [rightView addSubview:selectedDateLabel];
    UIImageView *rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(60, 0, 20, 20)];
    rightImage.image = [UIImage imageNamed:@"calendar"];
    [rightView addSubview:rightImage];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightItemSelectedDate)];
    [rightView addGestureRecognizer:tap];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:rightView];
    self.navigationItem.rightBarButtonItem = item;
    
}

//右上角日历
- (void)rightItemSelectedDate
{
    if (!_coverView) {
        [self setUpCoverView];
    }
    
}

- (void)setUpCoverView
{
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _coverView = coverView;
    [self.view addSubview:_coverView];
    coverView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchRemoveCoverView)];
//    [coverView addGestureRecognizer:tap];
    
    CGFloat calendarH = kScreenHeight > 480 ? 300 : 200;
    FSCalendar *calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 60, kScreenWidth, calendarH)];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.appearance.caseOptions = FSCalendarCaseOptionsHeaderUsesUpperCase|FSCalendarCaseOptionsWeekdayUsesUpperCase;
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.appearance.weekdayTextColor = KThemeGreenColor;
    calendar.appearance.headerTitleColor = KThemeGreenColor;
    calendar.appearance.selectionColor = KThemeGreenColor;
    calendar.appearance.titleDefaultColor = KThemeGreenColor;
    [self.coverView addSubview:calendar];
    _fsCalender = calendar;
    CGFloat toolBarY = CGRectGetMaxY(_fsCalender.frame);
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, toolBarY, kScreenWidth, 50)];
    _toolBar = toolBar;
    toolBar.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(removeCoverView)];
    cancelItem.tintColor = KThemeGreenColor;
    UIBarButtonItem *placeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar.items = @[placeItem, cancelItem];
    [_coverView addSubview:_toolBar];
}

- (void)removeCoverView
{
    if (_selectedDate) {
        [self getHistoryData:_selectedDate];
        
    }else{
        [self getHistoryData];
        
    }
    [_coverView removeFromSuperview];
    _coverView = nil;
}

- (void)touchRemoveCoverView
{
    [_coverView removeFromSuperview];
}


- (void)setUpBtn
{
    NSArray *arr = [[NSArray alloc]initWithObjects:@"运动历史记录",@"睡眠历史记录", nil];
    UISegmentedControl *segmentedControl = [ [ UISegmentedControl alloc ]
                                            initWithItems:arr];
    _segmentedControl = segmentedControl;
    [segmentedControl setApportionsSegmentWidthsByContent:YES];
    segmentedControl.frame = CGRectMake(10, 10, ScreenWidth - 20 , 40);
    [segmentedControl setTintColor:[UtilityUI stringTOColor:@"#3ed0ab"]]; //设置segments的颜色
    self.dataType = 0;
    segmentedControl.selectedSegmentIndex = 0;//选中第几个segment 一般用于初始化时选中
    [segmentedControl addTarget:self action:@selector(selected:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedControl];
    
    CGFloat btnWidth = (kScreenWidth - 120) / 3;
    //日按钮
    _dayBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 60, btnWidth, 50)];
    [_dayBtn setTitle:@"日" forState:UIControlStateNormal];
    [_dayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_dayBtn addTarget:self action:@selector(dayBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_dayBtn];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(_dayBtn.x + 15, _dayBtn.y, 50, 50)];
    _backgroundView = backgroundView;
    _backgroundView.center = _dayBtn.center;
    backgroundView.clipsToBounds = YES;
    [backgroundView.layer setCornerRadius:CGRectGetWidth([backgroundView bounds])/2];
    backgroundView.layer.masksToBounds = YES;
    backgroundView.backgroundColor = KThemeGreenColor;
    [self.view addSubview:backgroundView];
    
    [self.view bringSubviewToFront:_dayBtn];
    
    //周按钮
    _weekBtn = [[UIButton alloc] initWithFrame:CGRectMake(60 + btnWidth, 60, btnWidth, 50)];
    [_weekBtn setTitle:@"周" forState:UIControlStateNormal];
    [_weekBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_weekBtn addTarget:self action:@selector(weekBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_weekBtn];
    
    //月按钮
    _monthBtn = [[UIButton alloc] initWithFrame:CGRectMake(100 + 2 * btnWidth, 60, btnWidth, 50)];
    [_monthBtn setTitle:@"月" forState:UIControlStateNormal];
    [_monthBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_monthBtn addTarget:self action:@selector(monthBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_monthBtn];
    
    
}

- (void)setUpStepView
{
    CGFloat stepLabelW = 150;
    UIView *centerView = [[UIView alloc] initWithFrame:CGRectMake(self.view.width / 2 - 75, self.view.height / 2 - 100, stepLabelW, stepLabelW)];
    _centerView = centerView;
    centerView.backgroundColor = [UIColor whiteColor];
    [centerView.layer setCornerRadius:CGRectGetWidth(centerView.bounds) / 2];
    [self.view addSubview:centerView];
    
    //label
    UILabel *stepLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, centerView.width / 2 - 10, 100, 30)];
    _stepLabel = stepLabel;
    stepLabel.textAlignment = NSTextAlignmentCenter;
    stepLabel.text = [NSString stringWithFormat:@"%ld步",self.dayStepCount];
    [centerView addSubview:stepLabel];
    
    CGFloat bottomViewW = (kScreenWidth - 20) / 3;
    CGFloat bottomViewH = 60;
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(10, kScreenHeight - 164, kScreenWidth - 20, bottomViewH)];
    _bottomView = bottomView;
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    
    
    UILabel *bottomStepLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, bottomViewW, 30)];
    bottomStepLabel.textAlignment = NSTextAlignmentCenter;
    bottomStepLabel.text = [NSString stringWithFormat:@"%ld",self.dayStepCount];
    
    
    CGFloat distance = (self.dayStepCount * [CurrentUser.stepLong floatValue] ) / 100000;
    CGFloat fireEnergy = [CurrentUser.weight floatValue] * distance * 1.036 * 0.001;
    UILabel *bottomDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + bottomViewW, 5, bottomViewW, 30)];
    bottomDistanceLabel.textAlignment = NSTextAlignmentCenter;
    bottomDistanceLabel.text = [NSString stringWithFormat:@"%.2lf",distance];
    
    UILabel *bottomEnergyLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + 2 * bottomViewW, 5 , bottomViewW, 30)];
    bottomEnergyLabel.textAlignment = NSTextAlignmentCenter;
    bottomEnergyLabel.text = [NSString stringWithFormat:@"%.2lf",(long)(fireEnergy*100)/100.0];
    
    
    [bottomView addSubview:bottomStepLabel];
    _bottomStepLabel = bottomStepLabel;
    [bottomView addSubview:bottomEnergyLabel];
    _bottomEnergyLabel = bottomEnergyLabel;
    
    [bottomView addSubview:bottomDistanceLabel];
    _bottomDistanceLabel = bottomDistanceLabel;
    
    NSArray *tempIconArray = @[@"pic-foot",@"pic-distance",@"pic-fire"];
    NSArray *tempTitleArray = @[@"步数(步)",@"活动距离(km)",@"消耗能量(kCal)"];
    
    for (NSInteger i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5 + i *bottomViewW, 35, 15, 15)];
        imageView.image = [UIImage imageNamed:tempIconArray[i]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25 + i *bottomViewW, 35, bottomViewW - 25, 20)];
        label.font = [UIFont systemFontOfSize:11];
        label.text = tempTitleArray[i];
        label.textAlignment = NSTextAlignmentCenter;
        if (i == 0) {
            label.center = CGPointMake(bottomView.width / 3 / 2 + 7.5 , 45);
        }
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(bottomViewW + i *bottomViewW, 0, 0.5, bottomViewH)];
        lineView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
        [bottomView addSubview:imageView];
        [bottomView addSubview:label];
        [bottomView addSubview:lineView];
    }
    
}

//睡眠时间
- (void)setUpSleepView
{
    _chartView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_dayBtn.frame), ScreenWidth, ScreenHeight - 250)];
    _chartView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_chartView];
    
    _circleBgView = [[UIView alloc] initWithFrame:CGRectMake(50, 50, (_chartView.frame.size.width - 100), (_chartView.frame.size.width - 100))];
    _circleBgView.backgroundColor = [UIColor clearColor];
    [_chartView addSubview:_circleBgView];
    
    self.circleChart = [[PNCircleChart alloc] initWithFrame:CGRectMake(50,50.0, _circleBgView.frame.size.width, _circleBgView.frame.size.height)
                                                      total:@100
                                                    current:@100
                                                  clockwise:YES shadow:YES shadowColor:[UtilityUI stringTOColor:@"#6dabff"]];
    
    self.circleChart.backgroundColor = [UIColor clearColor];
    self.circleChart.lineWidth = @20;
    self.circleChart.lineCap = @"kCALineCapButt";
    [self.circleChart setStrokeColor:[UtilityUI stringTOColor:@"#1b6cff"]];
    //[self.circleChart setStrokeColorGradientStart:[UIColor clearColor]];
    [self.circleChart strokeChart];
    [_chartView addSubview:self.circleChart];
    
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(26, 26, self.circleChart.frame.size.width - 52, self.circleChart.frame.size.width - 52)];
    tempView.contentMode = UIViewContentModeScaleAspectFill;
    tempView.clipsToBounds = YES;
    [tempView.layer setCornerRadius:CGRectGetHeight([tempView bounds])/2];
    tempView.layer.masksToBounds = YES;
    tempView.backgroundColor = [UIColor whiteColor];
    [_circleChart addSubview:tempView];
    
    UILabel *sleepTimeText = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 50 - 22*2)/2,tempView.frame.size.width, 20)];
    sleepTimeText.text = @"睡眠时长";
    sleepTimeText.textAlignment = NSTextAlignmentCenter;
    sleepTimeText.textColor = [UIColor grayColor];
    [tempView addSubview:sleepTimeText];
    
    _sleepTimeValue = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 50 - 22*2)/2+32,tempView.frame.size.width, 20)];
    _sleepTimeValue.textAlignment = NSTextAlignmentCenter;
    _sleepTimeValue.textColor = [UIColor grayColor];
    [tempView addSubview:_sleepTimeValue];
    
    _ssleepTimeValue = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 50 - 22*2)/2+32+30,tempView.frame.size.width, 20)];
    _ssleepTimeValue.font = [UIFont systemFontOfSize:12];
    _ssleepTimeValue.textAlignment = NSTextAlignmentCenter;
    _ssleepTimeValue.textColor = [UIColor grayColor];
    [tempView addSubview:_ssleepTimeValue];
    
    _qsleepTimeValue = [[UILabel alloc] initWithFrame:CGRectMake(0, (tempView.frame.size.height - 50 - 22*2)/2+32+50,tempView.frame.size.width, 20)];
    _qsleepTimeValue.font = [UIFont systemFontOfSize:12];
    _qsleepTimeValue.textAlignment = NSTextAlignmentCenter;
    _qsleepTimeValue.textColor = [UIColor grayColor];
    [tempView addSubview:_qsleepTimeValue];
    _chartView.hidden = YES;
    [self setSleepLabelText];
}

#pragma mark - 日 周 月按钮点击

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date
{
    _selectedDate = [NSDate dateWithTimeInterval:(8 * 60 * 60) sinceDate:date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:_selectedDate];
    _selectedDateLabel.text = dateStr;
    DLog(@"%@",_selectedDate);
}

- (void)dayBtnClick
{
    self.HistoryData = HistoryDataTypeDay;
    [UIView animateWithDuration:0.2 animations:^{
        _backgroundView.frame = CGRectMake(_dayBtn.x+ 15, _dayBtn.y, 50, 50);
        _backgroundView.center = _dayBtn.center;
        [self.view bringSubviewToFront:_dayBtn];
        [self.view setNeedsDisplay];
    }];
    if (_segmentedControl.selectedSegmentIndex == 0) {
        [self setLabelText];
    }else{
        [self setSleepLabelText];
    }
    
}

- (void)weekBtnClick
{
    self.HistoryData = HistoryDataTypeWeek;
    [UIView animateWithDuration:0.2 animations:^{
        _backgroundView.frame = CGRectMake(_weekBtn.x+ 15, _weekBtn.y, 50, 50);
        _backgroundView.center = _weekBtn.center;
        [self.view bringSubviewToFront:_weekBtn];
        [self.view setNeedsDisplay];
    }];
    if (_segmentedControl.selectedSegmentIndex == 0) {
        [self setLabelText];
    }else{
        [self setSleepLabelText];
    }
}

- (void)monthBtnClick
{
    self.HistoryData = HistoryDataTypeMonth;
    [UIView animateWithDuration:0.2 animations:^{
        _backgroundView.frame = CGRectMake(_monthBtn.x + 15, _monthBtn.y, 50, 50);
        _backgroundView.center = _monthBtn.center;
        [self.view bringSubviewToFront:_monthBtn];
        [self.view setNeedsDisplay];
    }];
    if (_segmentedControl.selectedSegmentIndex == 0) {
        [self setLabelText];
        
    }else{
        [self setSleepLabelText];
    }
}

- (void)setLabelText
{
    NSInteger showStepData = 0;
    switch (self.HistoryData) {
        case HistoryDataTypeDay:
            showStepData = self.dayStepCount;
            break;
        case HistoryDataTypeWeek:
            showStepData = self.weekStepCount;
            break;
        case HistoryDataTypeMonth:
            showStepData = self.monthStepCount;
            break;
            
        default:
            break;
    }
    CGFloat distance = (showStepData * [CurrentUser.stepLong floatValue] ) / 100000;
    CGFloat fireEnergy = [CurrentUser.weight floatValue] * distance * 1.036 * 0.001;
    _stepLabel.text = [NSString stringWithFormat:@"%ld步",showStepData];
    _bottomStepLabel.text = [NSString stringWithFormat:@"%ld",showStepData];
    _bottomDistanceLabel.text = [NSString stringWithFormat:@"%.2lf",distance];
    _bottomEnergyLabel.text = [NSString stringWithFormat:@"%.2lf",(long)(fireEnergy*100)/100.0];
    
    
    [self.view setNeedsDisplay];
}

- (void)setSleepLabelText
{
    NSInteger showSsmData = 0;
    NSInteger showQsmData = 0;
    switch (self.HistoryData) {
        case HistoryDataTypeDay:{
            showSsmData = self.daySsmCount;
            showQsmData = self.dayQsmCount;
        }
            break;
        case HistoryDataTypeWeek:{
            showSsmData = self.weekSsmCount;
            showQsmData = self.weekQsmCount;
        }
            break;
        case HistoryDataTypeMonth:{
            showSsmData = self.monthSsmCount;
            showQsmData = self.monthQsmCount;
        }
            break;
            
        default:
            break;
    }
    NSInteger count = 1;
    
    if ((showSsmData + showQsmData) > 10 &&(showSsmData + showQsmData) < 100) {
        count = 2;
    }else if ((showSsmData + showQsmData) > 100 &&(showSsmData + showQsmData) < 1000){
        count = 3;
    }else if ((showSsmData + showQsmData) >= 1000){
        count = 4;
    }
    NSRange sleepHourRange = NSMakeRange(0, count);
    NSRange sleepMinuteRagne = NSMakeRange(sleepHourRange.length + 2, 2);
    NSMutableAttributedString *sleepValueString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@小时00分钟",@((showSsmData + showQsmData)).stringValue]];
    [sleepValueString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:30],NSForegroundColorAttributeName:[UIColor blackColor]}
                              range:sleepHourRange];
    [sleepValueString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:30],NSForegroundColorAttributeName:[UIColor blackColor]}
                              range:sleepMinuteRagne];
    _sleepTimeValue.attributedText = sleepValueString;
    
    NSRange deepSleepRange = NSMakeRange(0, 3);
    NSMutableAttributedString *deepSleepValueString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"★深睡%@小时00分钟",@(showSsmData).stringValue]];
    [deepSleepValueString addAttributes:@{NSForegroundColorAttributeName:[UtilityUI stringTOColor:@"#1b6cff"]}
                                  range:deepSleepRange];
    _ssleepTimeValue.attributedText = deepSleepValueString;
    
    NSRange shallowSleepRange = NSMakeRange(0, 3);
    NSMutableAttributedString *shallowSleepValueString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"☆浅睡%@小时00分钟",@(showQsmData).stringValue]];
    [shallowSleepValueString addAttributes:@{NSForegroundColorAttributeName:[UtilityUI stringTOColor:@"#6dabff"]}
                                     range:shallowSleepRange];
    _qsleepTimeValue.attributedText = shallowSleepValueString;
    
}


-(void)selected:(id)sender{
    UISegmentedControl* control = (UISegmentedControl*)sender;
    switch (control.selectedSegmentIndex) {
        case 0:
        {
            self.dataType = 0;
            if (_selectedDate) {
                [self getHistoryData:_selectedDate];
            }else{
                [self getHistoryData];
            }
            _chartView.hidden = YES;
            _centerView.hidden = NO;
            _bottomView.hidden = NO;
        }
            break;
        case 1:
        {
            self.dataType = 1;
            if (_selectedDate) {
                [self getHistoryData:_selectedDate];
            }else{
            [self getHistoryData];
            }
            _chartView.hidden = NO;
            _centerView.hidden = YES;
            _bottomView.hidden = YES;
        }
            break;
        default:
            break;
    }
}

- (void)getHistoryData
{
    NSDate *startDate = [NSDate date];
    //获取运动睡眠历史数据
    [self getHistoryData:startDate];
}

- (void)getHistoryData:(NSDate *)date
{
    //获取运动睡眠历史数据
    [self getDayData:date];
    [self getWeekData:date];
    [self getMonthData:date];
}

- (NSArray *)getDateFromWeek:(NSDate*)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSWeekdayCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    NSInteger weekday = [dateComponents weekday];
    //第几天(从sunday开始)
    NSInteger firstDiff,lastDiff;
    if (weekday == 1) {
        firstDiff = -6;
        lastDiff = 0;
    }else {
        firstDiff =  - weekday + 2;
        lastDiff = 8 - weekday;
    }
    NSInteger day = [dateComponents day];
    NSDateComponents *firstComponents = [calendar components:NSWeekdayCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    [firstComponents setDay:day+firstDiff];
    NSDate *firstDay = [calendar dateFromComponents:firstComponents];
    NSDateComponents *lastComponents = [calendar components:NSWeekdayCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    [lastComponents setDay:day+lastDiff];
    NSDate *lastDay = [calendar dateFromComponents:lastComponents];
    NSDate *monDate = [firstDay dateByAddingTimeInterval:(8 * 60 * 60)];
    NSDate *sunDate = [lastDay dateByAddingTimeInterval:(8 * 60 * 60)];
    
    return [NSArray arrayWithObjects:monDate,sunDate, nil];
}

- (NSInteger)dayCountFromMonth:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSRange range = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    NSUInteger numberOfDaysInMonth = range.length;
    return numberOfDaysInMonth;
}

#pragma mark - 日月周网络数据

//日数据
- (void)getDayData:(NSDate *)date
{
    __weak HistoryDataViewController *blockSelf = self;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    if (self.dataType == 0) {
        [blockSelf.operateVM getStepDataStartDate:dateStr endDate:dateStr];
        blockSelf.operateVM.finishHandler = ^(BOOL finished, id userInfo) {
            if (finished) {
                blockSelf.dayStepCount = 0;
                blockSelf.sportDataArray = [StepDataModel mj_objectArrayWithKeyValuesArray:userInfo];
                for (StepDataModel *model in blockSelf.sportDataArray) {
                    blockSelf.dayStepCount += [model.stepNum integerValue];
                }
                [blockSelf setLabelText];
            }else{
                
            }
        };
        
    }else{
        [blockSelf.operateVM getSleepDataStartDate:dateStr endDate:dateStr];
        blockSelf.operateVM.finishHandler = ^(BOOL finished, id userInfo) {
            if (finished) {
                blockSelf.daySsmCount = 0;
                blockSelf.dayQsmCount = 0;
                blockSelf.sleepDataArray = [SleepDataModel mj_objectArrayWithKeyValuesArray:userInfo];
                for (SleepDataModel *model in blockSelf.sleepDataArray) {
                    
                    blockSelf.daySsmCount += [model.ssmTime integerValue];
                }
                for (SleepDataModel *model in blockSelf.sleepDataArray) {
                    
                    blockSelf.dayQsmCount += [model.qsmTime integerValue];
                }
                [blockSelf setSleepLabelText];
            }else{
                
            }
        };
    }
    
    
}

//周数据
- (void)getWeekData:(NSDate *)date
{
    __weak HistoryDataViewController *blockSelf = self;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSArray *tempArray = [self getDateFromWeek:date];
    NSString *startDateStr = [formatter stringFromDate:tempArray[0]];
    NSString *endDateStr = [formatter stringFromDate:tempArray[1]];
    if (self.dataType == 0) {
        [blockSelf.operateVM1 getStepDataStartDate:startDateStr endDate:endDateStr];
        blockSelf.operateVM1.finishHandler = ^(BOOL finished, id userInfo) {
            if (finished) {
                blockSelf.weekStepCount = 0;
                blockSelf.sportDataArray = [StepDataModel mj_objectArrayWithKeyValuesArray:userInfo];
                for (StepDataModel *model in blockSelf.sportDataArray) {
                    
                    blockSelf.weekStepCount += [model.stepNum integerValue];
                }
                [blockSelf setLabelText];
                
            }else{
                
            }
        };
        
    }else{
        [blockSelf.operateVM1 getSleepDataStartDate:startDateStr endDate:endDateStr];
        blockSelf.operateVM1.finishHandler = ^(BOOL finished, id userInfo) {
            if (finished) {
                blockSelf.weekSsmCount = 0;
                blockSelf.weekQsmCount = 0;
                blockSelf.sleepDataArray = [SleepDataModel mj_objectArrayWithKeyValuesArray:userInfo];
                for (SleepDataModel *model in blockSelf.sleepDataArray) {
                    
                    blockSelf.weekSsmCount += [model.ssmTime integerValue];
                }
                for (SleepDataModel *model in blockSelf.sleepDataArray) {
                    
                    blockSelf.weekQsmCount += [model.qsmTime integerValue];
                }
                [blockSelf setSleepLabelText];
            }else{
                
            }
        };
    }
    
}


//月数据
- (void)getMonthData:(NSDate *)date
{
    __weak HistoryDataViewController *blockSelf = self;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM"];
    NSString *startStr = [formatter stringFromDate:date];
    NSString *startDateStr = [NSString stringWithFormat:@"%@-01",startStr];
    NSInteger dayCount = [self dayCountFromMonth:date];
    NSString *endDateStr = [NSString stringWithFormat:@"%@-%ld",startStr,dayCount];
    if (self.dataType == 0) {
        [blockSelf.operateVM2 getStepDataStartDate:startDateStr endDate:endDateStr];
        blockSelf.operateVM2.finishHandler = ^(BOOL finished, id userInfo) {
            if (finished) {
                blockSelf.monthStepCount = 0;
                blockSelf.sportDataArray = [StepDataModel mj_objectArrayWithKeyValuesArray:userInfo];
                for (StepDataModel *model in blockSelf.sportDataArray) {
                    
                    blockSelf.monthStepCount += [model.stepNum integerValue];
                }
                [blockSelf setLabelText];
                
            }else{
                
            }
        };
    }else{
        [blockSelf.operateVM2 getSleepDataStartDate:startDateStr endDate:endDateStr];
        blockSelf.operateVM2.finishHandler = ^(BOOL finished, id userInfo) {
            if (finished) {
                blockSelf.monthSsmCount = 0;
                blockSelf.monthQsmCount = 0;
                blockSelf.sleepDataArray = [SleepDataModel mj_objectArrayWithKeyValuesArray:userInfo];
                for (SleepDataModel *model in blockSelf.sleepDataArray) {
                    
                    blockSelf.monthSsmCount += [model.ssmTime integerValue];
                }
                for (SleepDataModel *model in blockSelf.sleepDataArray) {
                    
                    blockSelf.monthQsmCount += [model.qsmTime integerValue];
                }
                [blockSelf setSleepLabelText];
            }else{
                
            }
        };
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
