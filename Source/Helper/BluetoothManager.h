//
//  BluetoothManager.h
//  BlueToothBracelet
//
//  Created by snhuang on 16/3/9.
//  Copyright © 2016年 dachen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyBluetooth.h"


#define READ_SPORTDATA_SUCCESS @"READ_SPORTDATA_SUCCESS"                        //获取运动数据
#define READ_HISTORY_SPORTDATA_SUCCESS @"READ_HISTORY_SPORTDATA_SUCCESS"        //获取历史运动数据
#define READ_HEARTRATE_SUCCESS @"READ_HEARTRATE_SUCCESS"                        //获取心率数据
#define READ_HEARTRATE_FINISHED @"READ_HEARTRATE_FINISHED"                      //获取心率结束

#define SET_BASICINFOMATION_SUCCESS @"SET_BASICINFOMATION_SUCCESS"              //设置基本信息成功

#define DISCONNECT_PERIPHERAL @"DISCONNECT_PERIPHERAL"                            //与蓝牙设备断开


#define callAlertOpen  @"openCallAlert"      //来电提醒开关



#define BlueToothIsReadedPripheralAllData @"isReadedPripheralAllData"

@class BasicInfomationModel;



typedef NS_ENUM(NSInteger,BluetoothConnectingType) {
    BluetoothConnectingNormal = 0,
    BluetoothConnectingBinding,
    BluetoothConnectingConfirmBinding,
    BluetoothConnectingSetBasicInfomation,
    BluetoothConnectingReadSportData,
    BluetoothConnectingHistroyReadSportData,
    BluetoothConnectingHeartRate,
    BluetoothConnectingCallAlert,
    BluetoothConnectingSuccess
};

typedef NS_ENUM(NSInteger,BluetoothConnectingSuccessType) {
    BluetoothConnectingNormalSuccess = 0,
    BluetoothConnectingBindingSuccess,
    BluetoothConnectingConfirmBindingSuccess,
    BluetoothConnectingSetBasicInfomationSuccess,
    BluetoothConnectingReadSportDataSuccess,
    BluetoothConnectingHistroyReadSportDataSuccess,
    BluetoothConnectingHeartRateSuccess,
    BluetoothConnectingCallAlertSuccess,
    BluetoothConnectingAllSuccess
};

typedef NS_ENUM(NSInteger,BluetoothQueueType) {
    BluetoothQueueSetBasicInfomation = 0,
    BluetoothQueueReadSportData,
    BluetoothQueueHistroyReadSportData,
    BluetoothQueueHeartRate,
    BluetoothQueueCallAlert,
    BluetoothQueueAll
};



@protocol BluetoothManagerDelegate <NSObject>

- (void)didSearchPeripheral:(CBPeripheral *)peripheral
          advertisementData:(NSDictionary *)advertisementData;

- (void)didBindingPeripheral:(BOOL)success;

@end

@interface BluetoothManager : NSObject {
    BabyBluetooth *_baby;
    NSMutableArray *_bluetoothQueue;
}

@property (strong, nonatomic) BabyBluetooth *baby;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSTimer *heartRateTimer;          //心跳计时器
@property (assign, nonatomic) id<BluetoothManagerDelegate> deleagete;

@property (assign, nonatomic) BOOL isBindingPeripheral;         //是否绑定过蓝牙设备
@property (assign, nonatomic) BOOL isReadedPripheralAllData;    //是否读取过蓝牙设备中所有数据(绑定后需要获取所有数据)
@property (assign, nonatomic) BOOL isConnectSuccess;            //是否连接设备成功
@property (assign, nonatomic) BOOL isOpenCallAlert;             //是否开启来电提醒


@property (nonatomic,strong) PeripheralModel *bindingPeripheral;

@property (nonatomic,strong) CBCharacteristic *characteristics;

@property (assign, nonatomic) BluetoothConnectingType connectionType;
@property (assign, nonatomic) BluetoothConnectingSuccessType successType;

@property (strong, nonatomic) NSString *deviceID;               //服务器返回的设备ID



@property (assign, nonatomic) NSInteger heartRate;              //心率

+ (BluetoothManager *)share;

- (void)start;

- (void)stop;

- (void)connectingBlueTooth:(CBPeripheral *)peripheral;

- (void)startBindingPeripheral;

+ (BOOL)clearBindingPeripheral;





/*!
 *  读取运动数据
 *
 *  @param value
 */
- (void)readSportData;

- (void)setBasicInfomation:(BasicInfomationModel *)model;

- (void)readHistroySportData;

- (void)openCallAlert;   //来电提醒开关


- (void)readHeartRate;

- (void)closeReadHeartRate;


- (BOOL)isExistCharacteristic;

- (void)cancel;

@end
