
//
//  PersonalModifyPwdViewController.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/21.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "PersonalModifyPwdViewController.h"
#import "PersonalCenterViewController.h"

@interface PersonalModifyPwdViewController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPwdTF;
@property (weak, nonatomic) IBOutlet UITextField *nowPwdTF;
@property (weak, nonatomic) IBOutlet UITextField *nowAgainPwdTF;

- (IBAction)certainButtonClicked:(id)sender;
@end

@implementation PersonalModifyPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"修改密码";
    self.leftBarButtonItem.image = [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.leftBarButtonItem.tintColor = [UIColor colorWithHex:0x3A4B76];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - override

- (UIColor *)navigaitonBarBackgroundColor
{
    return [UIColor whiteColor];
}

- (NSDictionary *)navigationBarTitleTextAttribute
{
    return @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x3A4B76],NSFontAttributeName:[UIFont systemFontOfSize:18]};
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

#pragma mark - HTTP

- (void)modifyPwd
{
    NSDictionary *params = @{
                             @"beforePassword":self.oldPwdTF.text,
                             @"password":self.nowPwdTF.text,
                             @"confirmPassword":self.nowAgainPwdTF.text,
                             @"tokenID":UUID
                             };
    [self.view showWithStatus:@"提交中……"];
    __weak typeof(self) weakSelf =  self;
    [APIManager modifyPwdWithParams:params success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:@"修改成功"];
        //修改成功后的操作
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf.navigationController popViewControllerAnimated:NO];
            [[NSNotificationCenter defaultCenter]postNotificationName:ShouldLogoutNotification object:nil];
        });

        
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



#pragma mark - helper

- (BOOL)check
{
    if ([self.oldPwdTF.text isNilString]) {
        [self.view showWithMessage:@"请输入旧密码"];
        return NO;
    }
    if ([self.nowPwdTF.text isNilString]) {
        [self.view showWithMessage:@"请输入新密码"];
        return NO;
    }
    if ([self.nowAgainPwdTF.text isNilString]) {
        [self.view showWithMessage:@"请再次输入新密码"];
        return NO;
    }
    if ([self.nowPwdTF.text isValidatePassword] == NO) {
        [self.view showWithMessage:@"您输入的新密码不合法"];
        return NO;
    }
    if ([self.nowPwdTF.text isEqualToString:self.nowAgainPwdTF.text] == NO) {
        [self.view showWithMessage:@"您输入的密码不一致"];
        return NO;
    }
    
    return YES;
}

#pragma mark - button action

- (IBAction)certainButtonClicked:(id)sender {
    if ([self check]) {
        [self modifyPwd];
    }
}
@end
