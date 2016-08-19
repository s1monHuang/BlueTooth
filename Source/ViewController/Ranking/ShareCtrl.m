//
//  ShareCtrl.m
//  BlueToothBracelet
//
//  Created by huang dengpin on 15/8/9.
//  Copyright (c) 2015年 dachen. All rights reserved.
//

#import "ShareCtrl.h"
#import "SportDataModel.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "WeiboSDK.h"

@interface ShareCtrl ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UITextField *nickNameView;
@property (weak, nonatomic) IBOutlet UITextField *dateView;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *expendLabel;
@property (weak, nonatomic) IBOutlet UILabel *expendDetailLabel;

@property (weak, nonatomic) IBOutlet UIButton *shareWechatButton;
@property (weak, nonatomic) IBOutlet UIButton *shareWechatFriendButton;
@property (weak, nonatomic) IBOutlet UIButton *shareWeiboButton;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *showLabel;

@end

@implementation ShareCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SportDataModel *model = nil;
    if ([BluetoothManager getBindingPeripheralUUID]) {
        model = [DBManager selectSportData];
    }
    
    
    self.view.backgroundColor = kThemeGrayColor;
    UIButton *btnClosed = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 21 - 15, 20+10, 21, 21)];
    [btnClosed addTarget:self action:@selector(rightBarButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnClosed setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.view addSubview:btnClosed];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    if ([CurrentUser.sex isEqualToString:@"女"]) {
        _headImageView.image = [UIImage imageNamed:@"woman"];
    } else {
        _headImageView.image = [UIImage imageNamed:@"man"];
    }
    _nickNameView.text = CurrentUser.nickName;
    _dateView.text = dateString;
    _stepLabel.text = [NSString stringWithFormat:@"%@",model?@(model.step).stringValue:@(0).stringValue];
    NSString *stepDetail = [NSString stringWithFormat:@"%@%.2lf%@",NSLocalizedString(@"步行", nil),(model?model.step * [CurrentUser.stepLong floatValue]:0)*0.00001,NSLocalizedString(@"公里", nil)];
    _stepDetailLabel.text = stepDetail;
    _expendLabel.text = [NSString stringWithFormat:@"%.2f%@",model?[CurrentUser.weight floatValue] * model.distance*0.01 * 1.036 * 0.001:0,NSLocalizedString(@"千卡", nil)];
    NSString *expendDetail = [NSString stringWithFormat:@"≈%@%@",@(model.calorie / (147 * 1000)).stringValue,NSLocalizedString(@"雪糕", nil)];
    _expendDetailLabel.text = expendDetail;
    
    _showLabel.text = NSLocalizedString(@"快把你的光辉成绩晒一下吧!", nil);
}

- (void)rightBarButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareToWechat:(id)sender {
    [self sendImageContentWithScene:WXSceneSession];
}

- (IBAction)shareToWechatFrends:(id)sender {
    [self sendImageContentWithScene:WXSceneTimeline];
}

- (IBAction)shareToWeibo:(id)sender {
    [self sendWeiboImageContent];
}

//scene : WXSceneSession 消息 WXSceneTimeline 朋友圈
- (void)sendImageContentWithScene:(int)scene
{
    WXMediaMessage *message = [WXMediaMessage message];
    UIImage *image = [self screenView:self.view];
    [message setThumbImage:image];
    
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = UIImagePNGRepresentation(image);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

- (void)sendWeiboImageContent {
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare]];
    [WeiboSDK sendRequest:request];
}

- (WBMessageObject *)messageToShare
{
    WBMessageObject *message = [WBMessageObject message];
    
    WBImageObject *imageObject = [WBImageObject object];
    UIImage *image = [self screenView:self.view];
    imageObject.imageData = UIImagePNGRepresentation(image);
    message.imageObject = imageObject;

    return message;
}



- (UIImage*)screenView:(UIView *)view{
    _bottomView.hidden = YES;
    CGRect rect = view.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _bottomView.hidden = NO;
    return img;
}



@end
