//
//  AlarmViewController.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/8.
//  Copyright © 2015年 ;;. All rights reserved.
//

#import "AlarmViewController.h"
#import "MessageToolView.h"
#import "ImageMessageToolView.h"
#import "AppDelegate.h"
#import "YBImgPickerViewController.h"
#import "AlarmQuickView.h"
#import "AudioTransfer.h"
#import "WDAudioPlayer.h"
#import "PersonalCenterViewController.h"
#import "WaitPoliceView.h"
#import "PoliceWillArriveView.h"
#import "PoliceRejectView.h"
#import "AlarmStateManager.h"

NSString * const AlarmSuccessNotification = @"AlarmSuccessNotification";
NSString * const AlarmHadChageStateNotification = @"AlarmHadChageStateNotification";
NSString * const AlarmLightShouldExtinguishNotification = @"AlarmLightShouldExtinguishNotification";

NSString * const AlarmIDKey = @"AlarmIDKey";

#define MinUploadDistance 100

@interface AlarmViewController ()<BMKMapViewDelegate, MessageToolViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,YBImgPickerViewControllerDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *alarmButton;

@property (strong, nonatomic) UIButton *alarmBarrierButton;

@property (strong, nonatomic) YBImgPickerViewController *imgController;

@property (weak, nonatomic) IBOutlet AlarmQuickView *alarmQuickView;

@property (strong, nonatomic) BMKLocationService *locService;

@property (strong, nonatomic) BMKGeoCodeSearch *geoSearch;

@property (strong, nonatomic) UIImageView *annImgView;

@property (copy, nonatomic) NSString *longitude;
@property (copy, nonatomic) NSString *latitude;
@property (copy, nonatomic) NSString *address;

@property (assign, nonatomic) BOOL isLocated;


//等待接警的页面
@property (strong, nonatomic) WaitPoliceView *waitView;
/**
 *  警察接警后的页面
 */
@property (strong, nonatomic) PoliceWillArriveView *willArriveView;
//拒绝接警页面
@property (strong, nonatomic) PoliceRejectView *rejectView;

@property (copy, nonatomic) NSString *policeName;

//用于记录比较移动距离，然后上报服务器

@property (assign, nonatomic) CLLocationCoordinate2D startCoor;
@property (assign, nonatomic) CLLocationCoordinate2D currentCoor;

@property (assign, nonatomic) BOOL isUploadingPosition;

//用于隔段时间请求警察的位置
@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) BOOL isNeedRequestAlarmState;

- (IBAction)locationButtonClicked:(id)sender;

@end

@implementation AlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView.mapType = BMKMapTypeStandard;
    //定位
    self.locService = [[BMKLocationService alloc]init];
    self.locService.delegate = self;
    
    self.geoSearch = [[BMKGeoCodeSearch alloc]init];
    
    self.alarmBarrierButton.frame = self.alarmButton.frame;
    [self.view addSubview:self.alarmBarrierButton];
    self.alarmBarrierButton.hidden = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(alarmQuickly:)];
    longPress.minimumPressDuration = 1;
    [self.alarmButton addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *tapClicked = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(alarmButtonTap)];
    [self.alarmButton addGestureRecognizer:tapClicked];
    
    
    //检查推送是否有打开，没有的话提示
    [UIApplication checkPushWithHint:@"请在\"设置\"->\"通知\"->\"云警花溪\"中打开,否则会影响报警功能的使用。"];
    
    //监听是否有警察接警
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(alarmStateHadChangedNotification:) name:AlarmHadChageStateNotification object:nil];
    
    [self login];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapView viewWillAppear];
    //    [self.mapView mapForceRefresh];
    //退出登录后，在进入，看不到地图，我保存了最后一次定位的数据
    NSString *templongitude = [APUserData sharedUserData].longitude;
    NSString *templatitude = [APUserData sharedUserData].latitude;
    if (templongitude != nil&&![templongitude isEqualToString:@""] && templongitude != nil && ![templatitude isEqualToString:@""]) {
        
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([templatitude doubleValue], [templongitude doubleValue])];
        self.mapView.zoomLevel = 18;
    }
    
    
    self.mapView.delegate = self;
    self.locService.delegate = self;
    self.geoSearch.delegate = self;
    [self.locService startUserLocationService];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //检查是否有报警状态
    [self checkAndUpdateAlarmStateView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.mapView viewWillDisappear];
    [APUserData sharedUserData].longitude = self.longitude;
    [APUserData sharedUserData].latitude = self.latitude;
    self.mapView.delegate = nil;
    self.isNeedRequestAlarmState = NO;
    [self.locService stopUserLocationService];
    self.locService.delegate = nil;
    self.geoSearch.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor *)navigaitonBarBackgroundColor
{
    return [UIColor whiteColor];
}


- (void)localizationAlarmRejectState
{
    AlarmStateManager *manager  = [[AlarmStateManager manager] getAlarmState];
    [self.view addSubview:self.rejectView];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.35 animations:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.rejectView.x = 0;
    } completion:nil];
    
    self.rejectView.contentLabel.text = manager.rejectReson;
}

- (void)localizationAlarmHadRecivedState
{
    AlarmStateManager *manager  = [[AlarmStateManager manager] getAlarmState];
    [self.view addSubview:self.willArriveView];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.35 animations:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.willArriveView.x = 0;
    } completion:nil];
    self.willArriveView.policeNameLabel.text = manager.policeName;
    self.willArriveView.policePhoneLabel.text = manager.policePhoneNum;
    self.willArriveView.distanceLabel.text = [NSString stringWithFormat:@"距离您%.4lf公里",[manager.distance doubleValue] / 1000];
    
    //计算时间，预估15km/h
    self.willArriveView.timeLabel.text = [self getArriveTimeStringWithDsitance:[manager.distance doubleValue]];
    
    [self.alarmButton setImage:[UIImage imageNamed:@"resolving"] forState:UIControlStateSelected];
    self.alarmButton.selected = YES;
    self.alarmButton.userInteractionEnabled = NO;
    
    //                [self requestAlarmState];
    self.isNeedRequestAlarmState = YES;
}

- (void)checkAndUpdateAlarmStateView
{
    //关于本地保存报警状态的内容，先暂时不使用，
#warning message -- 暂时注释
    return;
    AlarmStateManager *manager  = [[AlarmStateManager manager] getAlarmState];
    if (manager.hadAlarmed) {
        //只处理已经报警状态
        if (manager.hadRecived) {
            //已经接警
            if (manager.hadReject) {
                //是否已经拒接
                [self localizationAlarmRejectState];
            }else{
                [self localizationAlarmHadRecivedState];
                //因为是本地数据，所以可能状态已经过期，所以不需要查警察位置
            }
        }else{
            //未接警
            [self.view addSubview:self.waitView];
            self.waitView.frame = CGRectMake(0, 0, Screen_Width, 140);
            self.waitView.textLabel.text = [NSString stringWithFormat:@"我在%@",manager.ownAddr];
            self.alarmButton.selected = YES;
            self.alarmButton.userInteractionEnabled = NO;
            self.isUploadingPosition = YES;
            
            //            [self requestAlarmState];
            self.isNeedRequestAlarmState = NO;
        }
    }
}

#pragma mark - MessageToolViewDelegate

- (void)messageToolViewNeedPresentCamera:(MessageToolView *)toolView
{
    [self startCarmera];
}

- (void)messageToolViewNeedPresentImagePicker:(MessageToolView *)toolView
{
    [self startPhotoLibarary];
}

- (void)messageToolView:(MessageToolView *)toolView didNeedSendRecord:(NSURL *)filePath withError:(NSError *)error
{
    if (error) {
        [self.view showWithMessage:error.domain];
    }else{
#warning 此处发送录音
        DDLog(@"发送录音");
        //编码成mp3
        NSData *data = [[NSData alloc]initWithContentsOfURL:filePath];
        AudioTransfer *transfer = [[AudioTransfer alloc]init];
        NSData *resultMp3Data = [transfer transferWavToMp3:data];
        
        [self recordSendWithData:resultMp3Data];
        
        
        //        WDAudioPlayer *audioPlayer = [[WDAudioPlayer alloc]initWithData:resultMp3Data];
        //        [audioPlayer audioPlay];
        
    }
}

- (void)messageToolView:(MessageToolView *)toolView didNeedSendMessage:(NSString *)message
{
#warning 此处进行文字信息的发送
    [self textAlarmWithText:message];
}

#pragma mark - MessageToolViewDelegate method helper
- (void)startCarmera
{
    if (![InCommonUse isDeviceCameraAvailable]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"相机不可用" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
//    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 8) {
        picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)startPhotoLibarary
{
    if (![InCommonUse isPhotoLibraryAvailable]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"相册不可用" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
//    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    if ([[[UIDevice currentDevice] systemVersion] integerValue] >= 8) {
        picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //这个时候需要弹出一个页面
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.sharedImageArr addObject:image];
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([self.imgController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            [self.imgController dismissViewControllerAnimated:NO completion:nil];
        }
        ImageMessageToolView *imgMsgView = [[ImageMessageToolView alloc]init];
        imgMsgView.imageArray = [NSArray arrayWithArray:app.sharedImageArr];
        imgMsgView.userInput = app.sharedInputStr;
        [imgMsgView show];
        
        [imgMsgView onClickedAddContinueButtonBlock:^{
            //            [self startPhotoLibarary];
            //相片图片选择器
            YBImgPickerViewController *controller = [[YBImgPickerViewController alloc]init];
            [controller showInViewContrller:self choosenNum:(4 - app.sharedImageArr.count) delegate:self];
            self.imgController = controller;
        }];
        
        [imgMsgView onClickedCertainButtonBlock:^(NSArray<UIImage *> *imageArr, NSString *text) {
#warning 这里调用发送消息的方法
            [self imageSendWithImages:imageArr text:text];
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - YBImgPickerViewControllerDelegate

- (void)YBImagePickerDidFinishWithImages:(NSArray *)imageArray {
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app.sharedImageArr addObjectsFromArray:imageArray];
    ImageMessageToolView *imgMsgView = [[ImageMessageToolView alloc]init];
    imgMsgView.imageArray = [NSArray arrayWithArray:app.sharedImageArr];
    imgMsgView.userInput = app.sharedInputStr;
    [imgMsgView show];
    
    [imgMsgView onClickedAddContinueButtonBlock:^{
        //            [self startPhotoLibarary];
        //相片图片选择器
        YBImgPickerViewController *controller = [[YBImgPickerViewController alloc]init];
        [controller showInViewContrller:self choosenNum:(4 - app.sharedImageArr.count) delegate:self];
        self.imgController = controller;
    }];
    
    [imgMsgView onClickedCertainButtonBlock:^(NSArray<UIImage *> *imageArr, NSString *text) {
#pragma warning(这里调用发送消息的方法)
        if ((imageArr != nil && imageArr.count > 0) || text != nil) {
            [self imageSendWithImages:imageArr text:text];
        }
    }];
}

#pragma mark - BMKLocationServiceDelegate

- (void)willStartLocatingUser
{
    DDLog(@"开始定位");
}

- (void)didStopLocatingUser
{
    DDLog(@"停止定位");
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    if (userLocation) {
        
        NSArray *arr = [self.mapView.annotations copy];
        [self.mapView removeAnnotations:arr];
        
        CLLocationCoordinate2D coor = userLocation.location.coordinate;
        
        //这个是起始量
        if (self.isUploadingPosition == NO) {
            self.startCoor = coor;
            //不需要停止定位
            //            [self.locService stopUserLocationService];
        }
        self.currentCoor = coor;
        
        //比较距离
        CLLocationDistance distance =  BMKMetersBetweenMapPoints(BMKMapPointForCoordinate(self.startCoor), BMKMapPointForCoordinate(self.currentCoor));
        if (distance > MinUploadDistance && self.isUploadingPosition) {
            //如果距离大于最小上报距离，上报，并更新起始距离以及
            [self uploadPositionWithCoordinate:self.currentCoor];
        }
        
        self.longitude = [NSString stringWithFormat:@"%f",coor.longitude];
        self.latitude = [NSString stringWithFormat:@"%f",coor.latitude];
        
        __weak typeof(self) weakSelf = self;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf.mapView setCenterCoordinate:coor animated:NO];
                strongSelf.mapView.zoomLevel = 17;
            });
        });
        
        BMKMapRect screenRect = [self.mapView convertRect:self.view.frame toMapRectFromView:self.view];
        BMKMapPoint currentPoint = BMKMapPointForCoordinate(coor);
        if (BMKMapRectContainsPoint(screenRect, currentPoint) == NO) {
            [self.mapView setCenterCoordinate:coor animated:YES];
            self.mapView.zoomLevel = 17;
        }
        
        BMKReverseGeoCodeOption *reverseGeo = [[BMKReverseGeoCodeOption alloc]init];
        reverseGeo.reverseGeoPoint = coor;
        BOOL flag = [self.geoSearch reverseGeoCode:reverseGeo];
        if (flag == NO) {
            DDLog(@"地址检索失败");
            [self.view showWithMessage:@"地址检索失败"];
            BMKPointAnnotation *ann = [[BMKPointAnnotation alloc]init];
            ann.coordinate = coor;
            [self.mapView addAnnotation:ann];
            
        }else{
            
        }
        
        
    }
}

- (void)didFailToLocateUserWithError:(NSError *)error
{
    [self.view showWithMessage:@"定位失败"];
    self.isLocated = NO;
    DDLog(@"定位失败");
}

#pragma mark - BMKMapViewDelegate

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView
{
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized
         || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)) {
            [self.locService startUserLocationService];
    }else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"未获得授权使用定位" message:@"请在\"设置\"->\"隐私\"->\"定位服务\"中打开" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
        }
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    BMKAnnotationView *annView = [[BMKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        annView.image = [UIImage imageNamed:@"zhuobiao"];
        //        annView.calloutOffset = CGPointMake(0, 150);
        annView.calloutOffset = CGPointMake(0, -10);
        
        //CGRectMake(0, 80, 0, 30)
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 30)];
        label.backgroundColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.cornerRadius = 4;
        label.borderColor = APCyanColor.CGColor;
        label.textColor = APCyanColor;
        label.font = [UIFont systemFontOfSize:12];
        label.text = [annotation title];
        
        CGSize size = [label sizeThatFits:CGSizeMake(MAXFLOAT, 30)];
        label.width = size.width + 20;
        label.x = 133 - size.width / 2 - 10;
        
        //        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 266, 266)];
        //        imgView.contentMode = UIViewContentModeCenter;
        //        NSMutableArray *imageArr = [NSMutableArray array];
        //        for (int i = 1; i < 5; i++) {
        //            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"image%d",i]];
        //            [imageArr addObject:img];
        //        }
        //        imgView.animationImages = imageArr;
        //        imgView.animationDuration = 0.75;
        //
        //        self.annImgView = imgView;
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, label.width + 20, label.height)];
        view.cornerRadius = 4;
        //        [view addSubview:imgView];
        [view addSubview:label];
        view.backgroundColor = [UIColor redColor];
        
        BMKActionPaopaoView *paopaoView = [[BMKActionPaopaoView alloc]initWithCustomView:label];
        annView.paopaoView = paopaoView;
        
        return annView;
    }
    return nil;
}

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    
    //    if ([overlay isKindOfClass:[BMKGroundOverlay class]]) {
    //        BMKGroundOverlayView *goundView = [[BMKGroundOverlayView alloc]initWithGroundOverlay:(BMKGroundOverlay*)overlay];
    //        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 266, 266)];
    //        imgView.contentMode = UIViewContentModeCenter;
    //        NSMutableArray *imageArr = [NSMutableArray array];
    //        for (int i = 1; i < 5; i++) {
    //            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"image%d",i]];
    //            [imageArr addObject:img];
    //        }
    //        imgView.animationImages = imageArr;
    //        imgView.animationDuration = 1;
    //
    //        [imgView startAnimating];
    //
    //        [goundView addSubview:imgView];
    //        return goundView;
    //    }
    return nil;
}

#pragma mark - BMKGeoCodeSearchDelegate

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        //        DDLog(@"反地址解析成功");
        
        self.isLocated = YES;
        NSString *address = result.address;
        self.address = address;
        CLLocationCoordinate2D coor = result.location;
        
        NSString *title = [NSString stringWithFormat:@"我在%@",address];
        
        if ([self.view.subviews containsObject:self.waitView]) {
            self.waitView.textLabel.text = title;
        }
        
        if (self.isNeedRequestAlarmState) {
            //            [self requestAlarmState];
        }
        
        BMKPointAnnotation *ann = [[BMKPointAnnotation alloc]init];
        ann.coordinate = coor;
        ann.title = title;
        [self.mapView addAnnotation:ann];
        [self.mapView selectAnnotation:ann animated:YES];
        
    }else{
        DDLog(@"反地址解析失败");
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 5050 ) {
        if (buttonIndex == 0) {
            return;
        }
        [self cancelAlarmRequest];
    }
    //重新调用登录接口
    
    
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    if (alertView.tag == 5050) {
        return;
    }
    //退出到登录
    [self delayPostNotification];
}



#pragma mark - HTTP

- (void)recordSendWithData:(NSData*)resultMp3Data
{
    /**
     *  每次报警前都要检查网络状态以及定位状态
     */
    if (self.isNetworkReachable == NO) {
        [self.view phoneCallWithPhone:@"110"];
        return;
    }
    if (self.isLocated == NO) {
        [self.view showWithMessage:@"请先定位"];
        return;
    }
    [self.view showWithStatus:@"发送中……"];
    __weak typeof(self) weakSelf = self;
    
    [APIManager uploadVoiceFileWithBlock:^(id<AFMultipartFormData> formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.mp3",str];
        [formData appendPartWithFileData:resultMp3Data name:@"file" fileName:fileName mimeType:@"audio/mpeg3" ];
        
    } success:^(id responseObj) {
        __strong typeof(self) strongSelf = weakSelf;
        
        NSDictionary *dict = nil;
        if ([responseObj isKindOfClass:[NSData class]]) {
            
            dict = (NSDictionary*)[responseObj objectFromJSONData];
            
        }else{
            dict = (NSDictionary*)responseObj;
        }
        DDLog(@"%@",dict);
        if (dict != nil) {
            if ([dict[@"Code"] integerValue] == 200) {
                [self audioAlarmWithAudioPath:dict[@"Data"][@"filePath"]];
            }else{
                if ([dict[@"Code"] integerValue] == 407 || [dict[@"Code"] integerValue] == 408) {
                    [self performSelector:@selector(delayPostNotification) withObject:nil afterDelay:0.75];
                }else if ([dict[@"Code"] integerValue] == 430) {
                    //弹出登录
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"下线通知" message:@"您的账号在另一地点登录，您已被迫下线" delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"重新登录", nil];
                    [alertView show];
                }
                [strongSelf.view hudHide];
                [strongSelf.view showWithMessage:dict[@"Msg"]];
            }
        }else{
            [strongSelf.view hudHide];
            [strongSelf.view showWithMessage:@"录音发送失败"];
        }
        
    } failure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:@"服务器不给力,请稍后重试~~"];
    }];
    
}

/**
 *  语音报警
 *
 */
- (void)audioAlarmWithAudioPath:(NSString*)path
{
    //    self.longitude = @"106.6723";
    //    self.latitude = @"26.4299";
    NSDictionary *params = @{
                             @"tokenID":[[UIDevice currentDevice]uuid],
                             @"userID":[APUserData sharedUserData].userID,
                             @"messageType":@"voiceAlarm",
                             @"message":path,
                             @"longitude":self.longitude,@"latitude":self.latitude,
                             @"addressName":self.address?self.address:@""};
    __weak typeof(self) weakSelf = self;
    [APIManager audioAlarmWithParams:params success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        
        [strongSelf.view showWithMessage:@"报警成功"];
        default_add_Object(dict[@"Data"][@"alarmID"], AlarmIDKey);
        default_synchronize;
        //报警成功
        [self alarmSuccessMethod];
        
    } dataError:^(NSInteger code, NSString *message) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:message];
        //弹出报警电话
        if (code == 422) {
#warning 这里应该弹出拨打110电话的界面
            [strongSelf.view phoneCallWithPhone:@"110"];
        }
    } failure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:@"服务器不给力，请稍后重试~~"];
    }];
}

/**
 *  一键报警
 */
- (void)alarmQuicklySend
{
    /**
     *  每次报警前都要检查网络状态以及定位状态
     */
    if (self.isNetworkReachable == NO) {
        [self.view phoneCallWithPhone:@"110"];
        return;
    }
    if (self.isLocated == NO) {
        [self.view showWithMessage:@"请先定位"];
        return;
    }
    //    self.longitude = @"106.6723";
    //    self.latitude = @"26.4299";
    NSDictionary *params = @{
                             @"tokenID":[[UIDevice currentDevice]uuid],
                             @"userID":[APUserData sharedUserData].userID,
                             @"messageType":@"oneKeyAlarm",
                             @"longitude":self.longitude,
                             @"latitude":self.latitude,
                             @"addressName":self.address?self.address:@""};
    __weak typeof(self) weakSelf = self;
    [self.view showWithStatus:@"发送中……"];
    [APIManager alarmQuicklyWithParams:params success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        default_add_Object(dict[@"Data"][@"alarmID"], AlarmIDKey);
        default_synchronize;
        //报警成功
        [self alarmSuccessMethod];
        
    } dataError:^(NSInteger code, NSString *message) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        
        [strongSelf.view showWithMessage:message];
        
        //弹出报警电话
        if (code == 422) {
#warning 这里应该弹出拨打110电话的界面
            [strongSelf.view phoneCallWithPhone:@"110"];
        }
        
    } failure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        
        [strongSelf.view showWithMessage:@"服务器不给力，请稍后重试~~"];
    }];
}

/**
 *  上传图片
 *
 *  @param images 图片数组
 */
- (void)imageSendWithImages:(NSArray<UIImage*>*)images text:(NSString*)text
{
    /**
     *  每次报警前都要检查网络状态以及定位状态
     */
    if (self.isNetworkReachable == NO) {
        [self.view phoneCallWithPhone:@"110"];
        return;
    }
    if (self.isLocated == NO) {
        [self.view showWithMessage:@"请先定位"];
        return;
    }
    [self.view showWithStatus:@"发送中……"];
    __weak typeof(self) weakSelf = self;
    [APIManager uploadImageFileWithBlock:^(id<AFMultipartFormData> formData) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        
        for (int i = 0; i < images.count; i++) {
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[str stringByAppendingString:[NSString stringWithFormat:@"%d",i]]];
            [formData appendPartWithFileData:UIImageJPEGRepresentation(images[i], 0.1) name:[NSString stringWithFormat:@"file%d",i] fileName:fileName mimeType:@"image/jpeg" ];
        }
    } success:^(id responseObj) {
        __strong typeof(self) strongSelf = weakSelf;
        
        NSDictionary *dict = [responseObj objectFromJSONData];
        DDLog(@"%@",dict);
        DDLog(@"%@",dict);
        if (dict != nil) {
            if ([dict[@"Code"] integerValue] == 200) {
                NSString *filePath = dict[@"Data"][@"filePath"];
                [self imageAlarmWithImagePath:filePath text:text];
            }else{
                if ([dict[@"Code"] integerValue] == 407 || [dict[@"Code"] integerValue] == 408) {
                    [self performSelector:@selector(delayPostNotification) withObject:nil afterDelay:0.75];
                }
                //如果是430
                if ([dict[@"Code"] integerValue] == 430) {
                    //弹出登录
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"下线通知" message:@"您的账号在另一地点登录，您已被迫下线" delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"重新登录", nil];
                    [alertView show];
                }
                [strongSelf.view hudHide];
                [strongSelf.view showWithMessage:dict[@"Msg"]];
            }
        }else{
            [strongSelf.view hudHide];
            [strongSelf.view showWithMessage:@"图片发送失败"];
        }
    } failure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:@"服务器不给力,请稍后重试~~"];
    }];
}

- (void)imageAlarmWithImagePath:(NSString*)imagePath text:(NSString*)text
{
    
    //    self.longitude = @"106.6723";Ib
    //    self.latitude = @"26.4299";
    NSDictionary *params = @{
                             @"tokenID":[[UIDevice currentDevice]uuid],
                             @"userID":[APUserData sharedUserData].userID,
                             @"message":imagePath,
                             @"messageText":text,
                             @"messageType":@"imgAlarm",
                             @"longitude":self.longitude,
                             @"latitude":self.latitude,
                             @"addressName":self.address?self.address:@""};
    __weak typeof(self) weakSelf = self;
    [APIManager imageAlarmWithParams:params success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.view hudHide];
        
        [strongSelf.view showWithMessage:@"报警成功"];
        
        default_add_Object(dict[@"Data"][@"alarmID"], AlarmIDKey);
        default_synchronize;
        //报警成功
        [self alarmSuccessMethod];
        
    } dataError:^(NSInteger code, NSString *message) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:message];
        
        //弹出报警电话
        if (code == 422) {
#warning 这里应该弹出拨打110电话的界面
            [strongSelf.view phoneCallWithPhone:@"110"];
        }
    } failure:^(NSError *error) {
        DLHideLoadAnimation;
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:@"服务器不给力，请稍后重试~~"];
    }];
}

/**
 *  文字报警
 *
 *  @param text 报警的文字
 */
- (void)textAlarmWithText:(NSString*)text
{
    /**
     *  每次报警前都要检查网络状态以及定位状态
     */
    if (self.isNetworkReachable == NO) {
        [self.view phoneCallWithPhone:@"110"];
        return;
    }
    if (self.isLocated == NO) {
        [self.view showWithMessage:@"请先定位"];
        return;
    }
    //    self.longitude = @"106.6723";
    //    self.latitude = @"26.4299";
    NSDictionary *params = @{
                             @"tokenID":[[UIDevice currentDevice]uuid],
                             @"userID":[APUserData sharedUserData].userID,
                             @"messageText":[text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                             @"messageType":@"textAlarm",
                             @"longitude":self.longitude,
                             @"latitude":self.latitude,
                             @"addressName":self.address?self.address:@""};
    [self.view showWithStatus:@"发送中……"];
    __weak typeof(self) weakSelf = self;
    [APIManager textAlarmWithParams:params success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        
        [strongSelf.view showWithMessage:@"报警成功"];
        
        default_add_Object(dict[@"Data"][@"alarmID"], AlarmIDKey);
        default_synchronize;
        //报警成功
        [self alarmSuccessMethod];
        
    } dataError:^(NSInteger code, NSString *message) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:message];
        
        //弹出报警电话
        if (code == 422) {
#warning 这里应该弹出拨打110电话的界面
            [strongSelf.view phoneCallWithPhone:@"110"];
        }
    } failure:^(NSError *error) {
        DLHideLoadAnimation;
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:@"服务器不给力，请稍后重试~~"];
    }];
    
}

- (void)uploadPositionWithCoordinate:(CLLocationCoordinate2D)coor
{
    NSDictionary *params = @{@"tokenID":UUID,@"longitude":@(coor.longitude),@"latitude":@(coor.latitude)};
    __weak typeof(self) weakSelf = self;
    [APIManager uploadPostionWithParams:params success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.startCoor = coor;
    } dataError:^(NSInteger code, NSString *message) {
        //        __strong typeof(self) strongSelf = weakSelf;
        //失败重复上报
        //        [self uploadPositionWithCoordinate:strongSelf.currentCoor];
    } failure:^(NSError *error) {
        //        __strong typeof(self) strongSelf = weakSelf;
        //失败重复上报
        //        [self uploadPositionWithCoordinate:strongSelf.currentCoor];
    }];
}

- (void)requestPolicePostion
{
    
    [self.view showWithStatus:@"警员正在火速赶来"];
    __weak typeof(self) weakSelf = self;
    [APIManager policePositionWithParams:@{@"userName":[self.policeName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"tokenID":UUID} success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        //获取到信息之后，更新警察信息界面
        if (dict != nil && [dict.allKeys containsObject:@"Data"]) {
            NSDictionary *poData = dict[@"Data"][@"hasmember"];
            strongSelf.willArriveView.policeNameLabel.text = poData[@"realName"];
            strongSelf.willArriveView.policePhoneLabel.text = poData[@"phone"];
            
            [AlarmStateManager manager].policeName = poData[@"realName"];
            [AlarmStateManager manager].policePhoneNum = poData[@"phone"];
            
            NSString *latitude = poData[@"latitude"];
            NSString *longitude = poData[@"longitude"];
            
            if ([self.latitude respondsToSelector:@selector(doubleValue)] && [self.longitude respondsToSelector:@selector(doubleValue)] && [latitude respondsToSelector:@selector(doubleValue)] && [longitude respondsToSelector:@selector(doubleValue)]) {
                
                CLLocationCoordinate2D myLoc = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
                
                CLLocationCoordinate2D policeLoc = CLLocationCoordinate2DMake([poData[@"latitude"] doubleValue], [poData[@"longitude"] doubleValue]);
                CLLocationDistance distance = BMKMetersBetweenMapPoints(BMKMapPointForCoordinate(myLoc), BMKMapPointForCoordinate(policeLoc));
                
                [AlarmStateManager manager].distance = [NSString stringWithFormat:@"%lf",distance];
                
                strongSelf.willArriveView.distanceLabel.text = [NSString stringWithFormat:@"距离您%.4lf公里",distance / 1000];
                
                //计算时间，预估15km/h
                strongSelf.willArriveView.timeLabel.text = [self getArriveTimeStringWithDsitance:distance];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:10]];
            });
        }
    } dataError:^(NSInteger code, NSString *message) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        [strongSelf.view showWithMessage:message];
        if (code == 444) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:10]];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.timer setFireDate:[NSDate distantFuture]];
            });
        }
    } failure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        APShowServiceError;
    }];
}

- (void)requestAlarmState
{
    //#warning message -- 暂时注释
    
    //    return;
    self.isNeedRequestAlarmState = NO;
    __weak typeof(self) weakSelf = self;
    [APIManager alarmStateWithParams:@{@"tokenID":UUID,@"alarmID":default_get_Object(AlarmIDKey) == nil?@"":[default_get_Object(AlarmIDKey) stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]} success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        DDLog(@"%@",dict);
        NSString *status = dict[@"Data"][@"status"];
        NSString *styleNum  = dict[@"Data"][@"styleNum"];
        if ([styleNum integerValue] == 4) {
            [self.waitView removeFromSuperview];
            [self.willArriveView removeFromSuperview];
            //报警按钮状态还原
            [self.alarmButton setImage:[UIImage imageNamed:@"waiting"] forState:UIControlStateSelected];
            self.alarmButton.selected = NO;
            self.alarmButton.userInteractionEnabled = YES;
            //小红灯熄灭
            [[NSNotificationCenter defaultCenter]postNotificationName:AlarmLightShouldExtinguishNotification object:nil];
            //定位停止
            //            [self.locService stopUserLocationService];
            //停止请求警察信息
            [self.timer setFireDate:[NSDate distantFuture]];
            
            //签到后，状态为未报警
            [AlarmStateManager manager].hadAlarmed = NO;
            
        }else if ([styleNum integerValue] == 3) {
            //处理中的状态
            [self.view addSubview:self.willArriveView];
            [UIView animateWithDuration:0.35 animations:^{
                strongSelf.willArriveView.x = 0;
            } completion:nil];
            NSDictionary *info = dict[@"Data"][@"callInfo"];
            strongSelf.willArriveView.policeNameLabel.text = info[@"realName"];
            strongSelf.willArriveView.policePhoneLabel.text = info[@"phone"];
            //计算距离
            CLLocationCoordinate2D myLoc = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
            CLLocationCoordinate2D policeLoc = CLLocationCoordinate2DMake([info[@"latitude"] doubleValue], [info[@"longitude"] doubleValue]);
            CLLocationDistance distance = BMKMetersBetweenMapPoints(BMKMapPointForCoordinate(myLoc), BMKMapPointForCoordinate(policeLoc));            strongSelf.willArriveView.distanceLabel.text = [NSString stringWithFormat:@"距离您%.4lf公里",distance / 1000];
            
            //计算时间，预估15km/h
            strongSelf.willArriveView.timeLabel.text = [self getArriveTimeStringWithDsitance:distance];
            
            [strongSelf.alarmButton setImage:[UIImage imageNamed:@"resolving"] forState:UIControlStateSelected];
            strongSelf.alarmButton.selected = YES;
            strongSelf.alarmButton.userInteractionEnabled = NO;
            //查警察的位置
            [self hadPoliceRecivedWithInfo:dict[@"Data"]];
            
            //            [self.locService startUserLocationService];
        }else{
            
        }
    } dataError:^(NSInteger code, NSString *message) {
        //        __strong typeof(self) strongSelf = weakSelf;
        //        [strongSelf.view showWithMessage:message];
    } failure:^(NSError *error) {
        //        __strong typeof(self) strongSelf = weakSelf;
        //        APShowServiceError;
    }];
}

- (void)cancelAlarmRequest
{
    [self.view showWithStatus:@"取消中……"];
    __weak typeof(self) weakSelf = self;
    [APIManager cancelAlarmWithParams:@{@"tokenID":UUID,@"alarmID":default_get_Object(AlarmIDKey) == nil?@"":[default_get_Object(AlarmIDKey) stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]} success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        [strongSelf.view showWithMessage:@"已取消"];
        [self alarmHadCanceled];
        
    } dataError:^(NSInteger code, NSString *message) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        [strongSelf.view showWithMessage:message];
        if (code == 437) {
            //报警已经受理，不要以取消
            [self performSelector:@selector(requestAlarmState) withObject:nil afterDelay:1.5];
        }
    } failure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        APShowServiceError;
    }];
}

- (void)login
{
    NSDictionary *params = @{
                             @"userName":default_get_Object(@"userName")?default_get_Object(@"userName"):@"",
                             @"userPassword":default_get_Object(@"userPwd")?default_get_Object(@"userPwd"):@"",
                             @"tokenID":UUID,
                             @"alias":[UUID substringToIndex:15],
                             @"tag":@"tag_people"
                             };
    
    [APIManager loginWithParams:params success:^(NSDictionary *dict) {
        
    } dataError:^(NSInteger code, NSString *message) {
        
        
    } failure:^(NSError *error) {
        
    }];
}



#pragma mark - help

- (void)alarmSuccessMethod
{
    //将小红灯变亮，需要通知
    [[NSNotificationCenter defaultCenter]postNotificationName:AlarmSuccessNotification object:nil];
    //按钮变黄色，显示文字等待中
    self.alarmButton.selected = YES;
    
    self.alarmBarrierButton.hidden = NO;
    [self.view bringSubviewToFront:self.alarmBarrierButton];
    
    //    self.alarmButton.userInteractionEnabled = NO;
    //    //显示雷达波纹
    //    [self.annImgView startAnimating];
    //显示文字提示页面
    [self.view addSubview:self.waitView];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.waitView.x = 0;
    }];
    self.waitView.textLabel.text = [[self.mapView.annotations firstObject] title];
    
    //重新开始定位，并且上报位置
    //设置为yes,用于标记不需要更新起始位置
    self.isUploadingPosition = YES;
    [self.locService startUserLocationService];
    
    
    //更新报警状态
    [AlarmStateManager manager].hadAlarmed = YES;
    //记录自己的地址
    [AlarmStateManager manager].ownAddr = self.address;
    [AlarmStateManager manager].shouldLocationContinue = YES;
    
    
}

//已经有人接警
- (void)hadPoliceRecivedWithInfo:(NSDictionary*)dict
{
    NSString *name = dict[@"poliseInfo"][@"userName"];
    if (name == nil || [name isEqualToString:@""]) {
        name = dict[@"callInfo"][@"userName"];
    }
    if (name == nil) {
        name = @"";
    }
    self.policeName = name;
    //开始获取警察位置信息
    [self requestPolicePostion];
    self.alarmBarrierButton.hidden = NO;
    [self.view bringSubviewToFront:self.alarmBarrierButton];
    [AlarmStateManager manager].hadRecived = YES;
}

//警察已到达并且签到成功
- (void)policeHadArrived
{
    //移除接警人信息页面
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.willArriveView.x = -Screen_Width;
    } completion:^(BOOL finished) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.willArriveView removeFromSuperview];
        [strongSelf.waitView removeFromSuperview];
    }];
    //报警按钮状态还原
    [self.alarmButton setImage:[UIImage imageNamed:@"waiting"] forState:UIControlStateSelected];
    self.alarmButton.selected = NO;
    self.alarmButton.userInteractionEnabled = YES;
    
    self.alarmBarrierButton.hidden = YES;
    [self.view sendSubviewToBack:self.alarmBarrierButton];
    //小红灯熄灭
    [[NSNotificationCenter defaultCenter]postNotificationName:AlarmLightShouldExtinguishNotification object:nil];
    //定位停止
    //    [self.locService stopUserLocationService];
    //停止请求警察信息
    [self.timer setFireDate:[NSDate distantFuture]];
    
    //签到后，状态为未报警
    [AlarmStateManager manager].hadAlarmed = NO;
    
}

//拒绝接警
- (void)hadReject
{
    //
    //移除等待接警信息页面
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.waitView.x = -Screen_Width;
        strongSelf.rejectView.x = 0;
        
    } completion:^(BOOL finished) {
        __strong typeof(self) strongSelf = weakSelf;
        
        [strongSelf.waitView removeFromSuperview];
    }];
    self.alarmButton.selected = NO;
    self.alarmButton.userInteractionEnabled = YES;
    
    self.alarmBarrierButton.hidden = YES;
    [self.view sendSubviewToBack:self.alarmBarrierButton];
    
    //小红灯熄灭
    [[NSNotificationCenter defaultCenter]postNotificationName:AlarmLightShouldExtinguishNotification object:nil];
    //定位停止
    //    [self.locService stopUserLocationService];
    
    [AlarmStateManager manager].hadReject = YES;
    
    
}

- (void)cancelAlarm
{
    //取消报警
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"是否确定取消本次报警？" delegate:self cancelButtonTitle:@"不,谢谢！" otherButtonTitles:@"确定", nil];
    alertView.tag = 5050;
    [alertView show];
    
}

- (void)alarmHadCanceled
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.waitView.x = -Screen_Width;
        
    } completion:^(BOOL finished) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.waitView removeFromSuperview];
    }];
    self.alarmButton.selected = NO;
    self.alarmButton.userInteractionEnabled = YES;
    [self.alarmButton setImage:[UIImage imageNamed:@"baojinganniu_down_x2"] forState:UIControlStateHighlighted];
    
    self.alarmBarrierButton.hidden = YES;
    [self.view sendSubviewToBack:self.alarmBarrierButton];
    
    //小红灯熄灭
    [[NSNotificationCenter defaultCenter]postNotificationName:AlarmLightShouldExtinguishNotification object:nil];
}

- (NSString*)getArriveTimeStringWithDsitance:(CLLocationDistance)distance
{
    NSInteger arriveSeconds = distance * 3600 / 15000;
    if (arriveSeconds < 60) {
        return [NSString stringWithFormat:@"约1分钟赶到"];
    }
    if (arriveSeconds > 60) {
        NSInteger minutes = arriveSeconds / 60;
        if (arriveSeconds % 60 != 0) {
            minutes++;
        }
        return [NSString stringWithFormat:@"约%ld分钟赶到",minutes];
    }
    return [NSString stringWithFormat:@"暂时无法估计到达时间"];
}

- (void)showAlarmStateWithDict:(NSDictionary*)dict
{
    
}


#pragma mark - notification

- (void)alarmStateHadChangedNotification:(NSNotification*)notifi
{
    NSString *alarmStateInfo = [notifi object];
    NSDictionary *dict = [alarmStateInfo objectFromJSONString];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if (dict && ![dict isEqualToDictionary:[NSDictionary dictionary]]) {
        
        if ([dict[@"styleNum"] isEqualToString:@"4"]) {
            //4的时候为警察现场签到
            [self policeHadArrived];
            return;
        }
        NSInteger msgCode = [dict[@"msgCode"] integerValue];
        if (msgCode == 600) {
            DDLog(@"有人接警");
            //报警按钮变成受理中
            [self.alarmButton setImage:[UIImage imageNamed:@"resolving"] forState:UIControlStateSelected];
            
            if (self.alarmButton.selected == NO) {
                self.alarmButton.selected = YES;
                self.alarmBarrierButton.hidden = NO;
                [self.view bringSubviewToFront:self.alarmBarrierButton];
            }
            
            //显示接警人的信息
            [self.view addSubview:self.willArriveView];
            
            //计算距离
            CLLocationCoordinate2D myLoc = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
            NSDictionary *poliInfo = dict[@"poliseInfo"];
            CLLocationCoordinate2D policeLoc = CLLocationCoordinate2DMake([poliInfo[@"latitude"] doubleValue], [poliInfo[@"longitude"] doubleValue]);
            CLLocationDistance distance = BMKMetersBetweenMapPoints(BMKMapPointForCoordinate(myLoc), BMKMapPointForCoordinate(policeLoc));
            self.willArriveView.distanceLabel.text = [NSString stringWithFormat:@"距离您%.4lf公里",distance / 1000];
            
            //计算时间，预估15km/h
            self.willArriveView.timeLabel.text = [self getArriveTimeStringWithDsitance:distance];
            
            self.willArriveView.policeNameLabel.text = dict[@"poliseInfo"][@"realName"];
            self.willArriveView.policePhoneLabel.text = dict[@"poliseInfo"][@"phone"];
            
            
            __weak typeof(self) weakSelf = self;
            [UIView animateWithDuration:0.35 animations:^{
                __strong typeof(self) strongSelf = weakSelf;
                strongSelf.waitView.x = -Screen_Width;
                strongSelf.willArriveView.x = 0;
                
            } completion:^(BOOL finished) {
                __strong typeof(self) strongSelf = weakSelf;
                [strongSelf.waitView removeFromSuperview];
            }];
            //有人接警
            [self hadPoliceRecivedWithInfo:dict];
        }
        if (msgCode == 601) {
            //拒绝接警
            [self.view addSubview:self.rejectView];
            self.rejectView.contentLabel.text = dict[@"msg"];
            [AlarmStateManager manager].rejectReson = dict[@"msg"];
            [self hadReject];
            
        }
        if (msgCode == 602) {
            //当前报警被滞留
            [self.view addSubview:self.rejectView];
            self.rejectView.contentLabel.text = dict[@"msg"];
            [AlarmStateManager manager].rejectReson = dict[@"msg"];
            [self hadReject];
        }
        
        
    }
}

#pragma mark - Gesture action

- (void)alarmButtonTap {
    if (self.alarmButton.selected) {
        return;
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"未获得授权使用定位" message:@"请在\"设置\"->\"隐私\"->\"定位服务\"中打开" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    MessageToolView *toolView = [[MessageToolView alloc]init];
    toolView.delegate = self;
    [toolView show];
    
}

- (void)delayPostNotification
{
    [[NSNotificationCenter defaultCenter]postNotificationName:ShouldShowLoginNotification object:nil];
}

//长按一键报警
- (void)alarmQuickly:(UIGestureRecognizer*)gesture
{
    if (self.alarmButton.selected) {
        return;
    }
    DDLog(@"%ld",gesture.state);
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.alarmQuickView.hidden = NO;
            self.alarmButton.hidden = YES;
            CGPoint point = [gesture locationInView:self.view];
            self.alarmQuickView.g_prePoint = point;
            DDLog(@"UIGestureRecognizerStateBegan%@",NSStringFromCGPoint(point));
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture locationInView:self.view];
            DDLog(@"UIGestureRecognizerStateChanged%@",NSStringFromCGPoint(point));
            CGFloat distance = self.alarmQuickView.g_prePoint.y - point.y;
            self.alarmQuickView.g_prePoint = point;
            
            CGRect frame = self.alarmQuickView.alarmImgView.frame;
            frame.origin.y -= distance;
            self.alarmQuickView.alarmImgView.frame = frame;
            
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint point = [gesture locationInView:self.view];
            DDLog(@"UIGestureRecognizerStateEnded%@",NSStringFromCGPoint(point));
            if (CGRectContainsPoint(self.alarmQuickView.alarmQuicklyImgView.frame, self.alarmQuickView.alarmImgView.center)) {
                //执行一键报警功能
                DDLog(@"一键报警>>>>>>>>>>>>>>>");
                self.alarmQuickView.alarmImgView.frame = self.alarmQuickView.orginalRect;
                self.alarmQuickView.hidden = YES;
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                self.alarmButton.hidden = NO;
                [self alarmQuicklySend];
                
            }else if (CGRectContainsPoint(self.alarmQuickView.alarmQuicklyImgView.frame, self.alarmQuickView.alarmImgView.center) == NO) {
                //返回原位
                __weak typeof(self) weakSelf = self;
                
                [UIView animateWithDuration:0.25 animations:^{
                    __strong typeof(self) strongSelf = weakSelf;
                    strongSelf.alarmQuickView.alarmImgView.frame = strongSelf.alarmQuickView.orginalRect;
                }];
            }
            
        }
            break;
        default:
            break;
    }
    __weak typeof(self) weakSelf = self;
    [self.alarmQuickView didAlarmQuicklyBlock:^{
        __strong typeof(self) strongSelf = weakSelf;
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        strongSelf.alarmButton.hidden = NO;
        [strongSelf alarmQuicklySend];
    }];
    
    [self.alarmQuickView didAlarmCanceled:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.alarmButton.hidden = NO;
    }];
}


#pragma mark - button action

- (IBAction)locationButtonClicked:(id)sender {
    if (self.isLocated) {
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue])];
        
    }else{
        [self.locService startUserLocationService];
    }
}

#pragma mark - getter

- (WaitPoliceView *)waitView
{
    if (_waitView == nil) {
        _waitView = [[[NSBundle mainBundle]loadNibNamed:@"WaitPoliceView" owner:self options:nil]lastObject];
        _waitView.frame = CGRectMake(0, 0, Screen_Width, 140);
        _waitView.textLabel.text = @"";
        [_waitView onAlarmCancedBlock:^{
            [self cancelAlarm];
        }];
    }
    return _waitView;
}

- (PoliceWillArriveView *)willArriveView
{
    if (_willArriveView == nil) {
        _willArriveView = [[[NSBundle mainBundle]loadNibNamed:@"PoliceWillArriveView" owner:self options:nil]lastObject];
        _willArriveView.frame = CGRectMake(Screen_Width, 0, Screen_Width, 140);
    }
    return _willArriveView;
}

- (PoliceRejectView *)rejectView
{
    if (_rejectView == nil) {
        _rejectView = [[[NSBundle mainBundle]loadNibNamed:@"PoliceRejectView" owner:self options:nil]lastObject];
        _rejectView.frame = CGRectMake(Screen_Width, 0, Screen_Width, 140);
    }
    return _rejectView;
}

- (NSTimer *)timer
{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(requestPolicePostion) userInfo:nil repeats:YES];
        _timer.fireDate = [NSDate distantFuture];
    }
    return _timer;
}

- (UIButton *)alarmBarrierButton
{
    if (_alarmBarrierButton == nil) {
        _alarmBarrierButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _alarmBarrierButton.backgroundColor = [UIColor clearColor];
    }
    return _alarmBarrierButton;
}

#pragma mark - dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AlarmHadChageStateNotification object:nil];
}

@end
