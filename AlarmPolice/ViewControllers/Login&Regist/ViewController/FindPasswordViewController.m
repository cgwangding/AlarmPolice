

//
//  FindPasswordViewController.m
//  AlarmPolice
//
//  Created by AD-iOS on 16/1/4.
//  Copyright © 2016年 Adinnet. All rights reserved.
//

#import "FindPasswordViewController.h"

@interface FindPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTF;
@property (weak, nonatomic) IBOutlet UIButton *getVerifyCodeButton;
@property (weak, nonatomic) IBOutlet UITextField *pwdTF;
@property (weak, nonatomic) IBOutlet UITextField *againPwdTF;

@property (weak, nonatomic) IBOutlet UIButton *certainButton;
@property (nonatomic, assign) NSInteger reduceTime;


@property (strong, nonatomic) NSTimer *timer;


- (IBAction)certainButtonClicked:(id)sender;
- (IBAction)getVerifyCodeButtonClicked:(id)sender;

@end

@implementation FindPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"忘记密码";
    [self.timer setFireDate:[NSDate distantFuture]];
    self.reduceTime = 60;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - HTTP

- (void)requestVerifyCode
{
    __weak typeof(self) weakSelf = self;
    [self.view showWithStatus:@"发送中……"];
    [APIManager sendVerifyCodeWithParams:@{@"telephone":self.phoneTF.text,@"findPwd":@"findPwd"} success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:@"已发送"];
        
        DDLog(@"%@",dict);
        strongSelf.getVerifyCodeButton.enabled = NO;
        [strongSelf.timer setFireDate:[NSDate date]];
        
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

- (void)modifyPwd
{
    NSDictionary *params = @{
                             @"telephone":self.phoneTF.text,
                             @"regCode":self.verifyCodeTF.text,
                             @"newPassword":self.pwdTF.text,
                             @"continuePassword":self.againPwdTF.text,
                             @"tokenID":[[UIDevice currentDevice] uuid],
                             @"alias":[[UIDevice currentDevice] uuid],
                             @"tag":@"people"
                             };
    [self.view showWithStatus:@"加载中……"];
    __weak typeof(self) weakSelf = self;
    [APIManager findPwdWithParams:params success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:@"修改成功"];
        default_add_Object(strongSelf.phoneTF.text, @"curPhone");
        default_synchronize;
        [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@YES afterDelay:0.5];
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

#pragma makr - helper

- (BOOL)check
{
    if (self.phoneTF.text == nil) {
        DLShowToast(@"请输入手机号");
        return NO;
    }
    if (![self.phoneTF.text isValidateMobile]) {
        DLShowToast(@"请输入有效的手机号");
        return NO;
    }
    if (self.verifyCodeTF.text == nil) {
        DLShowToast(@"请输入验证码");
        return NO;
    }
    if (self.pwdTF.text == nil) {
        DLShowToast(@"请输入密码");
        return NO;
    }
    if (![self.pwdTF.text isValidatePassword]) {
        DLShowToast(@"请输入合法密码");
        return NO;
    }
    
    if (![self.pwdTF.text isEqualToString:self.againPwdTF.text]) {
        DLShowToast(@"两次密码不一致");
        return NO;
    }
    return YES;
}

#pragma mark - private

#pragma mark - timer method

-(void)changeVerifyButtonTitle
{
    if (!self.getVerifyCodeButton.enabled) {
        NSString *title = [NSString stringWithFormat:@"%lus后重发",(long)_reduceTime];
        [self.getVerifyCodeButton setTitle:title forState:UIControlStateDisabled];
        self.getVerifyCodeButton.enabled = NO;
        if (_reduceTime == 0) {
            //停止计时器
            [self.timer setFireDate:[NSDate distantFuture]];
            self.reduceTime = 60;
            self.getVerifyCodeButton.enabled = YES;
        }
        _reduceTime--;
    }
    
}

#pragma mark - button action

- (IBAction)certainButtonClicked:(id)sender {
    if ([self check]) {
        [self modifyPwd];
    }
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
    [self requestVerifyCode];
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
