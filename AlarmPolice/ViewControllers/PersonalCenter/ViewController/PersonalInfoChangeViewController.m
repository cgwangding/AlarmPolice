
//
//  PersonalInfoChangeViewController.m
//  AlarmPolice
//
//  Created by AD-iOS on 16/3/5.
//  Copyright © 2016年 Adinnet. All rights reserved.
//

#import "PersonalInfoChangeViewController.h"

@interface PersonalInfoChangeViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation PersonalInfoChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.leftBarButtonItem.image = [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.leftBarButtonItem.tintColor = [UIColor colorWithHex:0x3A4B76];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 60, 30)];
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -40);
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:@"保存" forState:UIControlStateNormal];
    [button setTitleColor:APCyanColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    self.rightBarButtonItem.customView = button;
    
    switch (self.infoType) {
        case PersonalInfoTypeName:
            self.title = @"姓名";
            break;
        case PersonalInfoTypeSex:
            self.title = @"性别";
            break;
        case PersonalInfoTypeIDCardNum:
            self.title = @"身份证";
            break;
            
        default:
            break;
    }
    
    self.textField.text = self.infoStr;
    
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightAction{
    if ([self.textField.text rangeOfString:@"*"].location == NSNotFound) {
        if (self.infoType == PersonalInfoTypeSex) {
            if (([self.textField.text isEqualToString:@"男"] || [self.textField.text isEqualToString:@"女"])) {
                [self changePersonalInfo];
            }else{
                 [self.view showWithMessage:@"请输入合法性别"];
            }
        }
        
    }else{
        NSString *message = nil;
        switch (self.infoType) {
            case PersonalInfoTypeName:
                message = @"请输入合适的姓名";
                break;
            case PersonalInfoTypeSex:
                message = @"请输入性别";
                break;
            case PersonalInfoTypeIDCardNum:
                message = @"请输入完整的身份证号码";
                break;
                
            default:
                break;
        }
        [self.view showWithMessage:message];
    }
    
}

- (void)changePersonalInfo{
    NSDictionary *params = nil;
    switch (self.infoType) {
        case PersonalInfoTypeName:
            params = @{@"realName":[self.textField.text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],@"tokenID":UUID};
            break;
        case PersonalInfoTypeSex:
            params = @{@"sex":self.textField.text,@"tokenID":UUID};
            break;
        case PersonalInfoTypeIDCardNum:
            params = @{@"IDCard":self.textField.text,@"tokenID":UUID};
            break;
            
        default:
            break;
    }
    __weak typeof(self) weakSelf = self;
    [self.view showWithStatus:@"加载中……"];
    [APIManager modifyPersonalInfoWithParams:params success:^(NSDictionary *dict) {
        __weak typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@YES afterDelay:0.75];
        
    } dataError:^(NSInteger code, NSString *message) {
        __weak typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        [strongSelf.view showWithMessage:message];
    } failure:^(NSError *error) {
        __weak typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        APShowServiceError;
    }];
    
}


@end
