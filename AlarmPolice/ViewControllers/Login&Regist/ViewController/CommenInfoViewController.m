//
//  CommenInfoViewController.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/15.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "CommenInfoViewController.h"
#import "CustomTabBarController.h"
#import "LoginViewController.h"

#import "IQKeyboardManager.h"
#import "WDAddressPicker.h"

@interface CommenInfoViewController ()<UITextFieldDelegate, UIActionSheetDelegate,WDAddressPickerDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (assign, nonatomic) BOOL isInputName;
@property (weak, nonatomic) IBOutlet UITextField *sexTF;
@property (assign, nonatomic) BOOL isInputSex;

@property (weak, nonatomic) IBOutlet UITextField *userCardNoTF;
@property (assign, nonatomic) BOOL isInputCardNo;

@property (weak, nonatomic) IBOutlet UITextField *provinceTF;
@property (weak, nonatomic) IBOutlet UITextField *addressTF;

@property (weak, nonatomic) IBOutlet UIButton *compeletionButton;

@property (strong, nonatomic) UITextField *preTF;

@property (strong, nonatomic) NSArray *originalData;

@property (strong, nonatomic) NSArray *secondData;

@property (strong, nonatomic) NSArray *thirdData;

@property (strong, nonatomic) NSString *province;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *town;
@property (strong, nonatomic) NSString *areaID;


- (IBAction)completeButtonClicked:(id)sender;
@end

@implementation CommenInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"基本信息";
//    self.compeletionButton.backgroundColor = RGB(157, 166, 186);
//    self.compeletionButton.enabled = NO;
    
    self.userNameTF.tag = 100;
    self.sexTF.tag = 101;
    self.userCardNoTF.tag = 102;
    self.provinceTF.tag = 103;
    self.addressTF.tag = 104;
    
    if ([AreaDataManager sharedManager].fileExist) {
        self.originalData = [[AreaDataManager sharedManager]readAreaData];
        
        self.province = self.originalData[0][@"province"];
        self.secondData = self.originalData[0][@"city"];
        self.city = self.secondData[0][@"city"];
        
        self.thirdData = self.secondData[0][@"area"];
        self.town = self.thirdData[0][@"area"];
        self.areaID = self.thirdData[0][@"areaID"];
    }
    
    [self getAreaInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /*
    if ([textField isEqual:self.userNameTF]) {
        if (self.userNameTF.text.length > 0) {
            self.isInputName = YES;
        }else{
            self.isInputName = NO;
        }
    }
    if ([textField isEqual:self.sexTF] ) {
        if (self.sexTF.text.length > 0) {
            self.isInputSex = YES;
        }else{
            self.isInputSex = NO;
        }
    }
    if ([textField isEqual:self.userCardNoTF]) {
        if (self.userCardNoTF.text.length > 0) {
            self.isInputCardNo = YES;
        }else{
            self.isInputCardNo = NO;
        }
    }
    
    if (self.isInputCardNo && self.isInputSex && self.isInputName) {
        self.compeletionButton.backgroundColor = [UIColor colorWithHex:0x3A4B76];
        self.compeletionButton.enabled = YES;
    }else{
        self.compeletionButton.backgroundColor = RGB(157, 166, 186);
        self.compeletionButton.enabled = NO;
    }
    */
    return YES;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.preTF == nil) {
        self.preTF = textField;
    }else{
        [self.preTF resignFirstResponder];
        self.preTF = textField;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 101) {
        [textField resignFirstResponder];
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
        [sheet showInView:self.view];
    }
    if (textField.tag == 103) {
        [textField resignFirstResponder];
        WDAddressPicker *picer = [[WDAddressPicker alloc]init];
        picer.delegate = self;
        [picer showWithController:self];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        self.sexTF.text = @"男";
    }
    if (buttonIndex == 1) {
        self.sexTF.text = @"女";
    }
//    if (self.sexTF.text.length > 0) {
//        self.isInputSex = YES;
//    }else{
//        self.isInputSex = NO;
//    }
//    if (self.isInputCardNo && self.isInputSex && self.isInputName) {
//        self.compeletionButton.backgroundColor = [UIColor colorWithHex:0x3A4B76];
//        self.compeletionButton.enabled = YES;
//    }else{
//        self.compeletionButton.backgroundColor = RGB(157, 166, 186);
//        self.compeletionButton.enabled = NO;
//    }
}

#pragma mark - WDAddressPickerDelegate

- (void)wdAddressPickerDidCertain:(WDAddressPicker *)picker
{
    
}

#pragma mark - UIPickerViewDataSource,UIPickerViewDelegate

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return [self.originalData count];
    }
    if (component == 1) {
        return [self.secondData count];
    }

    return [self.thirdData count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return self.originalData[row][@"province"];
    }
    if (component == 1) {
        return self.secondData[row][@"city"];
    }
    
    return self.thirdData[row][@"area"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        self.secondData = self.originalData[row][@"city"];
        if (self.secondData == nil || self.secondData.count == 0) {
            self.thirdData = @[];
            self.city = @"";
            self.town = @"";
        }else{
            self.thirdData = self.secondData[0][@"area"];
            
            
            self.city = self.secondData[0][@"city"];
            self.town = self.thirdData[0][@"area"];
            self.areaID = self.thirdData[0][@"areaID"];

        }
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
        self.province = self.originalData[row][@"province"];
    }
    if (component == 1) {
        self.thirdData = self.secondData[row][@"area"];
        [pickerView selectRow:0 inComponent:2 animated:YES];
        [pickerView reloadComponent:2];
        self.city = self.secondData[row][@"city"];
        self.town = self.thirdData[0][@"area"];
        self.areaID = self.thirdData[0][@"areaID"];

    }
    
    if (component == 2) {
        self.town = self.thirdData[row][@"area"];
        self.areaID = self.thirdData[row][@"areaID"];

    }
    self.provinceTF.text = [NSString stringWithFormat:@"%@%@%@",self.province,self.city,self.town];
}

#pragma mark - HTTP

- (void)getAreaInfo
{
    __weak typeof(self) weakSelf = self;
    [APIManager areaInfoWithParams:nil success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.originalData = dict[@"Data"][@"model"];
        [[AreaDataManager sharedManager]saveWithObject:strongSelf.originalData];
        
        strongSelf.province = strongSelf.originalData[0][@"province"];
//        strongSelf.firstData = strongSelf.originalData[0];
        strongSelf.secondData = strongSelf.originalData[0][@"city"];
        strongSelf.city = strongSelf.secondData[0][@"city"];
        
        strongSelf.thirdData = strongSelf.secondData[0][@"area"];
        strongSelf.town = strongSelf.thirdData[0][@"area"];
        strongSelf.areaID = strongSelf.thirdData[0][@"areaID"];

    } dataError:^(NSInteger code, NSString *message) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)completeUserInfo
{
    NSString *sex = @"male";
    NSString *sexText = [self.sexTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([sexText isEqualToString:@"女"]) {
        sex = @"femal";
    }
    NSDictionary *dict = @{
                           @"telephone":self.phone?self.phone:@"",
                           @"userName":self.phone?self.phone:@"",
                           @"realName":self.userNameTF.text,
                           @"userPassword":self.pwd?self.pwd:@"",
                           @"idCard":self.userCardNoTF.text,
                           @"address":[NSString stringWithFormat:@"%@%@",self.provinceTF.text,self.addressTF.text],
                           @"areaID":self.areaID,
                           @"alias":self.phone?self.phone:@"",
                           @"tag":@"tag_people",
                           @"sex":sex,
                           @"tokenID":UUID
                           };
    __weak typeof(self) weakSelf = self;
    APShowLoading;
    [APIManager completeUserInfoWithParams:dict success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        [strongSelf.view showWithMessage:@"恭喜您注册成功，请登录！"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //去登录
            for (UIViewController *vc in strongSelf.navigationController.viewControllers) {
                if ([vc isKindOfClass:[LoginViewController class]]) {
                    [strongSelf.navigationController popToViewController:vc animated:YES];
                }
            }
        });
        default_add_Object(strongSelf.phone, @"curPhone");
        default_synchronize;
        
    } dataError:^(NSInteger code, NSString *message) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        [strongSelf.view showWithMessage:message];
    } failure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        APShowServiceError;
    }];
}

#pragma mark - helper

- (BOOL)canSubmit
{
    if ([[self.userNameTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self.view showWithMessage:@"请输入真实姓名"];
        return NO;
    }
    if ([[self.sexTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self.view showWithMessage:@"请选择性别"];
        return NO;
    }
    
    if ([[self.userCardNoTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self.view showWithMessage:@"请输入身份证号"];
        return NO;
    }
    if ([[self.provinceTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self.view showWithMessage:@"请选择城市"];
        return NO;
    }
    
    if ([[self.addressTF.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self.view showWithMessage:@"请填写地址"];
        return NO;
    }
    return YES;
}

#pragma mark - button action

- (IBAction)completeButtonClicked:(id)sender {
    if ([self canSubmit]) {
        [self completeUserInfo];
    }
    
}
@end