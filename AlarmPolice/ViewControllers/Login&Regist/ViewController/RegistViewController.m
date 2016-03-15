
//
//  RegistViewController.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/15.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "RegistViewController.h"
#import "CommenInfoViewController.h"
#import "IQKeyboardManager.h"

@interface RegistViewController ()
@property (weak, nonatomic) IBOutlet UIButton *registButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTF;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UITextField *againPwdTF;

@property (weak, nonatomic) IBOutlet UIButton *getVerifyButton;
@property (nonatomic, assign) NSInteger reduceTime;


@property (weak, nonatomic) IBOutlet UIButton *protocolButton;

@property (strong, nonatomic) NSTimer *timer;

- (IBAction)protocolButtonClicked:(id)sender;

- (IBAction)registButtonClicked:(id)sender;
- (IBAction)getVerifyCodeButtonClicked:(id)sender;
@end

@implementation RegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"注册";
    [self.timer setFireDate:[NSDate distantFuture]];
    self.reduceTime = 60;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[IQKeyboardManager sharedManager] disableInViewControllerClass:[CommenInfoViewController class]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - HTTP

- (void)getVerifyCode
{
    __weak typeof(self) weakSelf = self;
    [self.view showWithStatus:@"发送中……"];
    [APIManager sendVerifyCodeWithParams:@{@"telephone":self.phoneTF.text} success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:@"已发送"];
        
        DDLog(@"%@",dict);
        strongSelf.getVerifyButton.enabled = NO;
        [strongSelf.timer setFireDate:[NSDate date]];
        
    } dataError:^(NSInteger code, NSString *message) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:message];
    } failure:^(NSError *error) {
        //        __strong typeof(self) strongSelf = weakSelf;
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:@"服务器不给力,请稍后重试~~"];
    }];
}

- (void)registUser
{
    __weak typeof(self) weakSelf = self;
    [self.view showWithStatus:@"注册中……"];
    [APIManager registWithParams:@{@"telephone":self.phoneTF.text,@"regCode":self.verifyCodeTF.text,@"userPassword":self.pwdTF.text} success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:@"注册成功"];
        CommenInfoViewController *commenInfoVC  = MainStoryBoard(@"userInfoViewController");
        commenInfoVC.phone = strongSelf.phoneTF.text;
        commenInfoVC.pwd = strongSelf.pwdTF.text;
        [strongSelf.navigationController pushViewController:commenInfoVC animated:YES];
    } dataError:^(NSInteger code, NSString *message) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:message];
    } failure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:@"服务器不给力,请稍后重试~~"];
    }];
}

#pragma mark - timer method

-(void)changeVerifyButtonTitle
{
    if (!self.getVerifyButton.enabled) {
        NSString *title = [NSString stringWithFormat:@"%lus后重发",(long)_reduceTime];
        [self.getVerifyButton setTitle:title forState:UIControlStateDisabled];
        [self.getVerifyButton setBackgroundColor:[UIColor lightGrayColor]];
        if (_reduceTime == 0) {
            //停止计时器
            [self.timer setFireDate:[NSDate distantFuture]];
            self.reduceTime = 60;
            self.getVerifyButton.enabled = YES;
            [self.getVerifyButton setBackgroundColor:APCreenColor];
        }
        _reduceTime--;
    }
    
}


#pragma mark - button action

- (IBAction)protocolButtonClicked:(id)sender {
    self.protocolButton.selected = !self.protocolButton.selected;
}

- (IBAction)registButtonClicked:(id)sender {
    if (self.phoneTF.text == nil) {
        DLShowToast(@"请输入手机号");
        return;
    }
    if (![self.phoneTF.text isValidateMobile]) {
        DLShowToast(@"请输入有效的手机号");
        return;
    }
    if (self.verifyCodeTF.text == nil) {
        DLShowToast(@"请输入验证码");
        return;
    }
    if (self.pwdTF.text == nil || [self.pwdTF.text isEqualToString:@""]) {
        DLShowToast(@"请输入密码");
        return;
    }
    if (self.againPwdTF.text == nil || [self.againPwdTF.text isEqualToString:@""]) {
        DLShowToast(@"请再次输入密码");
        return;
    }
    if (![self.pwdTF.text isValidatePassword]) {
        DLShowToast(@"请输入合法密码");
        return;
    }
    if ([self.pwdTF.text isEqualToString:self.againPwdTF.text] == NO) {
        DLShowToast(@"两次密码输入不一致");
        return;
    }
    if (self.protocolButton.selected == NO) {
        DLShowToast(@"请阅读云格子警务平台许可协议");
        return;
    }
    [self registUser];
}

- (IBAction)getVerifyCodeButtonClicked:(id)sender {
    if (self.phoneTF.text == nil) {
        DLShowToast(@"请输入手机号");
        return;
    }
    if (![self.phoneTF.text isValidateMobile]) {
        DLShowToast(@"请输入有效的手机号");
        return;
    }
    [self getVerifyCode];
}

#pragma mark - getter

- (NSTimer *)timer
{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeVerifyButtonTitle) userInfo:nil repeats:YES];
    }
    return _timer;
}

@end
