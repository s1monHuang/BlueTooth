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

//@property (weak, nonatomic) IBOutlet UIButton *shareWechatButton;
//@property (weak, nonatomic) IBOutlet UIButton *shareWechatFriendButton;
//@property (weak, nonatomic) IBOutlet UIButton *shareWeiboButton;


@property (strong, nonatomic) UIButton *shareWechatButton;
@property (strong, nonatomic) UIButton *shareWechatFriendButton;
@property (strong, nonatomic) UIButton *shareWeiboButton;

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
    
    
    NSString *tempStr = [NSString stringWithFormat:@"%@",@(model.step).stringValue];
    NSRange range = NSMakeRange(0, tempStr.length == 0?1:tempStr.length);
    NSMutableAttributedString *stepStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ ",tempStr,BTLocalizedString(@"步")]];
    [stepStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:28]}
                     range:range];
    
    _stepLabel.attributedText = stepStr;
    
//    _stepLabel.text = [NSString stringWithFormat:@"%@",model?@(model.step).stringValue:@(0).stringValue];
    NSString *stepDetail = [NSString stringWithFormat:@"%@ %.2lf%@",BTLocalizedString(@"步行"),(model?model.step * [CurrentUser.stepLong floatValue]:0)*0.00001,BTLocalizedString(@"公里")];
    _stepDetailLabel.text = stepDetail;
    
    NSString *tempStr1 = [NSString stringWithFormat:@"%.2f",model?[CurrentUser.weight floatValue] * model.distance*0.01 * 1.036 * 0.001:0];
    NSRange range1 = NSMakeRange(0, tempStr1.length == 0?4:tempStr1.length);NSMutableAttributedString *expendStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@ ",tempStr1,BTLocalizedString(@"千卡")]];
    [expendStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:28]}
                     range:range1];
    
    _expendLabel.attributedText = expendStr;
    
//    _expendLabel.text = [NSString stringWithFormat:@"%.2f%@",model?[CurrentUser.weight floatValue] * model.distance*0.01 * 1.036 * 0.001:0,BTLocalizedString(@"千卡")];
    
    
    NSString *expendDetail = [NSString stringWithFormat:@"≈%@%@",@(model.calorie / (147 * 1000)).stringValue,BTLocalizedString(@"雪糕")];
    _expendDetailLabel.text = expendDetail;
    
    _showLabel.text = BTLocalizedString(@"快把你的光辉成绩晒一下吧!");
    
    CGFloat buttonX = ScreenWidth / 6;
    CGFloat buttonY = 25;
    CGFloat buttonW = 40;
    
    _shareWeiboButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX * 5 - 20, buttonY, buttonW, buttonW)];
    [_shareWeiboButton setBackgroundImage:[UIImage imageNamed:@"share_weibo"] forState:UIControlStateNormal];
    [_shareWeiboButton addTarget:self action:@selector(shareToWeibo:) forControlEvents:UIControlEventTouchUpInside];
    
    _shareWechatButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX - 20, buttonY, buttonW, buttonW)];
    [_shareWechatButton setBackgroundImage:[UIImage imageNamed:@"share_wechat"] forState:UIControlStateNormal];
    [_shareWechatButton addTarget:self action:@selector(shareToWechat:) forControlEvents:UIControlEventTouchUpInside];
    
    _shareWechatFriendButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX * 3 - 20, buttonY, buttonW, buttonW)];
    [_shareWechatFriendButton setBackgroundImage:[UIImage imageNamed:@"share_wechat_friend"] forState:UIControlStateNormal];
    [_shareWechatFriendButton addTarget:self action:@selector(shareToWechatFrends:) forControlEvents:UIControlEventTouchUpInside];
    
    [_bottomView addSubview:_shareWechatButton];
    [_bottomView addSubview:_shareWechatFriendButton];
    [_bottomView addSubview:_shareWeiboButton];
}

- (void)rightBarButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)shareToWechat:(id)sender {
    [self sendImageContentWithScene:WXSceneSession];
}

- (void)shareToWechatFrends:(id)sender {
    [self sendImageContentWithScene:WXSceneTimeline];
}

- (void)shareToWeibo:(id)sender {
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
