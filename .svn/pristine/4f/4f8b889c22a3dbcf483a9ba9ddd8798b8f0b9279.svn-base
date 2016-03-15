
//
//  PersonalAddrModifyViewController.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/21.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "PersonalAddrModifyViewController.h"
#import "IQKeyboardManager.h"
#import "WDAddressPicker.h"

@interface PersonalAddrModifyViewController ()<UITextFieldDelegate,WDAddressPickerDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *cityTF;
@property (weak, nonatomic) IBOutlet UITextField *detailAddrTF;
@property (weak, nonatomic) IBOutlet UIButton *certainButton;

@property (strong, nonatomic) NSArray *originalData;

@property (strong, nonatomic) NSArray *secondData;

@property (strong, nonatomic) NSArray *thirdData;


@property (copy, nonatomic) NSString *province;
@property (copy, nonatomic) NSString *provinceID;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *cityID;
@property (copy, nonatomic) NSString *town;
@property (copy, nonatomic) NSString *areaID;

- (IBAction)certainButtonClicked:(id)sender;

@end

@implementation PersonalAddrModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"地址修改";
    self.leftBarButtonItem.image = [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.leftBarButtonItem.tintColor = [UIColor colorWithHex:0x3A4B76];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    
    if ([AreaDataManager sharedManager].fileExist) {
        self.originalData = [[AreaDataManager sharedManager]readAreaData];
        
        self.province = self.originalData[0][@"province"];
        self.provinceID = self.originalData[0][@"provinceID"];
        self.secondData = self.originalData[0][@"city"];
        self.city = self.secondData[0][@"city"];
        self.cityID = self.secondData[0][@"cityID"];
        
        self.thirdData = self.secondData[0][@"area"];
        self.town = self.thirdData[0][@"area"];
        self.areaID = self.thirdData[0][@"areaID"];
    }
    [self getAreaInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.cityTF]) {
        WDAddressPicker *picer = [[WDAddressPicker alloc]init];
        picer.delegate = self;
        [picer showWithController:self];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
            
            self.provinceID = self.originalData[0][@"provinceID"];
            self.cityID = self.secondData[0][@"cityID"];
        }
        [pickerView selectRow:0 inComponent:1 animated:NO];
        [pickerView selectRow:0 inComponent:2 animated:NO];
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
        self.province = self.originalData[row][@"province"];
    }
    if (component == 1) {
        self.thirdData = self.secondData[row][@"area"];
        [pickerView selectRow:0 inComponent:2 animated:NO];
        [pickerView reloadComponent:2];
        self.city = self.secondData[row][@"city"];
        self.town = self.thirdData[0][@"area"];
        self.areaID = self.thirdData[0][@"areaID"];
        self.cityID = self.secondData[0][@"cityID"];
        
    }
    
    if (component == 2) {
        self.town = self.thirdData[row][@"area"];
        self.areaID = self.thirdData[row][@"areaID"];
        
    }
    self.cityTF.text = [NSString stringWithFormat:@"%@%@%@",self.province,self.city,self.town];
}

#pragma mark - HTTP

- (void)getAreaInfo
{
    __weak typeof(self) weakSelf = self;
    [APIManager areaInfoWithParams:nil success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.originalData = dict[@"Data"][@"model"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AreaDataManager sharedManager]saveWithObject:strongSelf.originalData];
        });
        
        strongSelf.province = strongSelf.originalData[0][@"province"];
        //        strongSelf.firstData = strongSelf.originalData[0];
        strongSelf.secondData = strongSelf.originalData[0][@"city"];
        strongSelf.city = strongSelf.secondData[0][@"city"];
        
        strongSelf.thirdData = strongSelf.secondData[0][@"area"];
        strongSelf.town = strongSelf.thirdData[0][@"area"];
        strongSelf.areaID = strongSelf.thirdData[0][@"areaID"];
        
        strongSelf.provinceID = strongSelf.originalData[0][@"provinceID"];
        strongSelf.cityID = strongSelf.secondData[0][@"cityID"];
        
    } dataError:^(NSInteger code, NSString *message) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)modifyAddress
{
    NSDictionary *params = @{@"address":self.detailAddrTF.text,@"cityID":self.cityID,@"city":self.city,@"areaID":self.areaID,@"area":self.town,@"provinceID":self.provinceID,@"province":self.province,@"tokenID":UUID};
    __weak typeof(self) weakSelf = self;
    [self.view showWithStatus:@"提交中……"];
    [APIManager modifyAddressWithParams:params success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        [strongSelf.view showWithMessage:@"修改成功"];
        [strongSelf.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@YES afterDelay:0.75];
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

#pragma mark - button action 

- (IBAction)certainButtonClicked:(id)sender {
    if ([self check]) {
        [self modifyAddress];
    }
    
}

- (BOOL)check
{
    if ([self.cityTF.text isNilString]) {
        [self.view showWithMessage:@"请选择城市"];
        return NO;
    }
    if ([self.detailAddrTF.text isNilString]) {
        [self.view showWithMessage:@"请填写详细地址"];
        return NO;
    }
    return YES;
}
@end
