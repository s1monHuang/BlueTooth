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

@interface HistoryDataViewController () <UIGestureRecognizerDelegate,FSCalendarDataSource,FSCalendarDelegate>
@property (nonatomic,strong) NSMutableArray *sportDataArray;
@property (nonatomic,strong) NSMutableArray *sleepDataArray;

@property (nonatomic , strong) UISegmentedControl *segmentedControl;

@property (nonatomic , strong) UIButton *dayBtn;

@property (nonatomic , strong) UIButton *weekBtn;

@property (nonatomic , strong) UIButton *monthBtn;

@property (nonatomic , strong) OperateViewModel *operateVM;

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
    self.operateVM = [OperateViewModel defaultInstance];
    self.dataType = 0;
    
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
        [self getDayData:_selectedDate];
        [self getWeekData:_selectedDate];
        [self getMonthData:_selectedDate];
        
    }else{
        [self getDayData:[NSDate date]];
        [self getWeekData:[NSDate date]];
        [self getMonthData:[NSDate date]];
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
    
    
    CGFloat distance = (self.dayStepCount * [CurrentUser.stepLong floatValue] ) / 10;
    CGFloat fireEnergy = [CurrentUser.weight floatValue] * distance * 1.036;
    UILabel *bottomDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + bottomViewW, 5, bottomViewW, 30)];
    bottomDistanceLabel.textAlignment = NSTextAlignmentCenter;
    bottomDistanceLabel.text = [NSString stringWithFormat:@"%.1lf",distance];
    
    UILabel *bottomEnergyLabel = [[UILabel alloc] initWithFrame:CGRectMake(5 + 2 * bottomViewW, 5 , bottomViewW, 30)];
    bottomEnergyLabel.textAlignment = NSTextAlignmentCenter;
    bottomEnergyLabel.text = [NSString stringWithFormat:@"%.0lf",fireEnergy];
    
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
    [self setSleepLabelTextWithQsmCount:_dayQsmCount ssmCount:_daySsmCount];
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
    [UIView animateWithDuration:0.2 animations:^{
        _backgroundView.frame = CGRectMake(_dayBtn.x+ 15, _dayBtn.y, 50, 50);
        _backgroundView.center = _dayBtn.center;
        [self.view bringSubviewToFront:_dayBtn];
        [self.view setNeedsDisplay];
    }];
    if (_segmentedControl.selectedSegmentIndex == 0) {
        [self setLabelText:self.dayStepCount];
    }else{
        [self setSleepLabelTextWithQsmCount:_dayQsmCount ssmCount:_daySsmCount];
    }
    
}

- (void)weekBtnClick
{
    [UIView animateWithDuration:0.2 animations:^{
        _backgroundView.frame = CGRectMake(_weekBtn.x+ 15, _weekBtn.y, 50, 50);
        _backgroundView.center = _weekBtn.center;
        [self.view bringSubviewToFront:_weekBtn];
        [self.view setNeedsDisplay];
    }];
    if (_segmentedControl.selectedSegmentIndex == 0) {
        [self setLabelText:self.weekStepCount];
    }else{
        [self setSleepLabelTextWithQsmCount:_weekQsmCount ssmCount:_weekSsmCount];
    }
}

- (void)monthBtnClick
{
    [UIView animateWithDuration:0.2 animations:^{
        _backgroundView.frame = CGRectMake(_monthBtn.x + 15, _monthBtn.y, 50, 50);
        _backgroundView.center = _monthBtn.center;
        [self.view bringSubviewToFront:_monthBtn];
        [self.view setNeedsDisplay];
    }];
    if (_segmentedControl.selectedSegmentIndex == 0) {
        [self setLabelText:self.monthStepCount];
        
    }else{
        [self setSleepLabelTextWithQsmCount:_monthQsmCount ssmCount:_monthSsmCount];
    }
}

- (void)setLabelText:(NSInteger)stepNum
{
    CGFloat distance = (stepNum * [CurrentUser.stepLong floatValue] ) / 100000;
    CGFloat fireEnergy = [CurrentUser.weight floatValue] * distance * 1.036;
    
    _stepLabel.text = [NSString stringWithFormat:@"%ld步",stepNum];
    _bottomStepLabel.text = [NSString stringWithFormat:@"%ld",stepNum];
    _bottomDistanceLabel.text = [NSString stringWithFormat:@"%.1lf",distance];
    _bottomEnergyLabel.text = [NSString stringWithFormat:@"%.0lf",fireEnergy];
    
    [self.view setNeedsDisplay];
}

- (void)setSleepLabelTextWithQsmCount:(NSInteger)qsmCount ssmCount:(NSInteger)ssmCount
{
    NSInteger count = 1;
    
    if (qsmCount + ssmCount > 10) {
        count = 2;
    }else if (qsmCount + ssmCount > 100){
        count = 3;
    }
    NSRange sleepHourRange = NSMakeRange(0, count);
    NSRange sleepMinuteRagne = NSMakeRange(sleepHourRange.length + 2, 2);
    NSMutableAttributedString *sleepValueString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@小时00分钟",@((qsmCount + ssmCount)).stringValue]];
    [sleepValueString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:30],NSForegroundColorAttributeName:[UIColor blackColor]}
                              range:sleepHourRange];
    [sleepValueString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:30],NSForegroundColorAttributeName:[UIColor blackColor]}
                              range:sleepMinuteRagne];
    _sleepTimeValue.attributedText = sleepValueString;
    
    NSRange deepSleepRange = NSMakeRange(0, 3);
    NSMutableAttributedString *deepSleepValueString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"★深睡%@小时00分钟",@(ssmCount).stringValue]];
    [deepSleepValueString addAttributes:@{NSForegroundColorAttributeName:[UtilityUI stringTOColor:@"#1b6cff"]}
                                  range:deepSleepRange];
    _ssleepTimeValue.attributedText = deepSleepValueString;
    
    NSRange shallowSleepRange = NSMakeRange(0, 3);
    NSMutableAttributedString *shallowSleepValueString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"☆浅睡%@小时00分钟",@(qsmCount).stringValue]];
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
                [self getDayData:_selectedDate];
                [self getWeekData:_selectedDate];
                [self getMonthData:_selectedDate];
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
                [self getDayData:_selectedDate];
                [self getWeekData:_selectedDate];
                [self getMonthData:_selectedDate];
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
    [self getDayData:startDate];
    [self getWeekData:startDate];
    [self getMonthData:startDate];
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
    NSDate *today = [NSDate date];
    __weak HistoryDataViewController *blockSelf = self;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    NSString *todayStr = [formatter stringFromDate:today];
    if (self.dataType == 0) {
        if ([dateStr isEqualToString:todayStr]) {
            //今日的记步数据
            self.dayStepCount = [DBManager selectTodayStepNumber];
        }else{
        [blockSelf.operateVM getStepDataStartDate:dateStr endDate:dateStr];
        blockSelf.operateVM.finishHandler = ^(BOOL finished, id userInfo) {
            if (finished) {
                blockSelf.sportDataArray = [StepDataModel mj_objectArrayWithKeyValuesArray:userInfo];
                for (StepDataModel *model in blockSelf.sportDataArray) {
                    blockSelf.dayStepCount += [model.stepNum integerValue];
                }
                
            }else{
                
            }
        };
        }
    }else{
        if ([dateStr isEqualToString:todayStr]) {
            //今日的睡眠数据
            self.daySsmCount = [DBManager selectTodayssmNumber];
            self.dayQsmCount = [DBManager selectTodayqsmNumber];
        }else{
        [blockSelf.operateVM getSleepDataStartDate:dateStr endDate:dateStr];
        blockSelf.operateVM.finishHandler = ^(BOOL finished, id userInfo) {
            if (finished) {
                blockSelf.sleepDataArray = [SleepDataModel mj_objectArrayWithKeyValuesArray:userInfo];
                for (SleepDataModel *model in blockSelf.sleepDataArray) {
                    blockSelf.daySsmCount += [model.ssmTime integerValue];
                }
                for (SleepDataModel *model in blockSelf.sleepDataArray) {
                    blockSelf.dayQsmCount += [model.qsmTime integerValue];
                }
            }else{
                
            }
        };
        }
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
        [blockSelf.operateVM getStepDataStartDate:startDateStr endDate:endDateStr];
        blockSelf.operateVM.finishHandler = ^(BOOL finished, id userInfo) {
            if (finished) {
                blockSelf.sportDataArray = [StepDataModel mj_objectArrayWithKeyValuesArray:userInfo];
                for (StepDataModel *model in blockSelf.sportDataArray) {
                    blockSelf.weekStepCount += [model.stepNum integerValue];
                }
                
            }else{
                
            }
        };
    }else{
        [blockSelf.operateVM getSleepDataStartDate:startDateStr endDate:endDateStr];
        blockSelf.operateVM.finishHandler = ^(BOOL finished, id userInfo) {
            if (finished) {
                blockSelf.sleepDataArray = [SleepDataModel mj_objectArrayWithKeyValuesArray:userInfo];
                for (SleepDataModel *model in blockSelf.sleepDataArray) {
                    blockSelf.weekSsmCount += [model.ssmTime integerValue];
                }
                for (SleepDataModel *model in blockSelf.sleepDataArray) {
                    blockSelf.weekQsmCount += [model.qsmTime integerValue];
                }
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
        [blockSelf.operateVM getStepDataStartDate:startDateStr endDate:endDateStr];
        blockSelf.operateVM.finishHandler = ^(BOOL finished, id userInfo) {
            if (finished) {
                blockSelf.sportDataArray = [StepDataModel mj_objectArrayWithKeyValuesArray:userInfo];
                for (StepDataModel *model in blockSelf.sportDataArray) {
                    blockSelf.monthStepCount += [model.stepNum integerValue];
                }
                
            }else{
                
            }
        };
    }else{
        [blockSelf.operateVM getSleepDataStartDate:startDateStr endDate:endDateStr];
        blockSelf.operateVM.finishHandler = ^(BOOL finished, id userInfo) {
            if (finished) {
                blockSelf.sleepDataArray = [SleepDataModel mj_objectArrayWithKeyValuesArray:userInfo];
                for (SleepDataModel *model in blockSelf.sleepDataArray) {
                    blockSelf.monthSsmCount += [model.ssmTime integerValue];
                }
                for (SleepDataModel *model in blockSelf.sleepDataArray) {
                    blockSelf.monthQsmCount += [model.qsmTime integerValue];
                }
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
