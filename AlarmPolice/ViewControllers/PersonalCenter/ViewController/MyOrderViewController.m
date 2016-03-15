//
//  MyOrderViewController.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/21.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "MyOrderViewController.h"
#import "OrderSucceessView.h"

@interface MyOrderViewController ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation MyOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的预约";
    [self requestMyOrder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSuccessWithAddress:(NSString*)addr date:(NSString*)date
{
    OrderSucceessView *view = [[[NSBundle mainBundle]loadNibNamed:@"OrderSucceessView" owner:self options:nil] lastObject];
    view.orderAddrLabel.text = addr;
    view.orderDateLabel.text = date;
    view.frame = CGRectMake(12, 13, Screen_Width - 24, 326 + 64);
    [self.view addSubview:view];
}

- (void)requestMyOrder
{
    __weak typeof(self) weakSelf = self;
    [self.view showWithStatus:@"加载中……"];
    [APIManager myOrderWithParams:@{@"tokenID":UUID} success:^(NSDictionary *dict) {
        __weak typeof(self) strongSelf = weakSelf;
        [strongSelf.view hudHide];
        NSDictionary *data = dict[@"Data"];
        if (data != nil && [data isKindOfClass:[NSDictionary class]] && data.count > 0) {//数据为nil，无预约
            data = data[@"model"];
             [self showSuccessWithAddress:data[@"police"] date:data[@"orderTime"]];
        }
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