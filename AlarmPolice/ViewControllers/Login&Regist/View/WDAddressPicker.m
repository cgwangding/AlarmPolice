//
//  WDAddressPicker.m
//  AlarmPolice
//
//  Created by AD-iOS on 16/1/5.
//  Copyright © 2016年 Adinnet. All rights reserved.
//

#import "WDAddressPicker.h"

@interface WDAddressPicker ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *backgroundView;

@property (strong, nonatomic) UIPickerView *pickerView;


@end

@implementation WDAddressPicker

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
        [self setupWidget];
    }
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
        [self setupWidget];
    }
    return self;
}

- (void)showWithController:(UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>*)controller
{
    self.pickerView.delegate = controller;
    self.pickerView.dataSource = controller;
    self.frame = CGRectMake(0, 0, Screen_Width, controller.view.height);
    self.backgroundView.frame = CGRectMake(0, self.height - 46 - 193, self.width, 46 + 193);
    [controller.view addSubview:self];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    if (CGRectContainsPoint(self.backgroundView.frame, touchPoint)) {
        return NO;
    }
    return YES;
}

- (void)setupWidget
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, self.height - 46 - 193, self.width, 46 + 193)];
    view.backgroundColor = [UIColor whiteColor];
    [self addSubview:view];
    self.backgroundView = view;
    
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, view.width, 46)];
    titleView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    [view addSubview:titleView];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelButton setTitleColor:[UIColor colorWithHex:0x4D5D83] forState:UIControlStateNormal];
    [cancelButton setFrame:CGRectMake(0, 0, 48, titleView.height)];
    [cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:cancelButton];
    
    UIButton *certainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [certainButton setTitle:@"完成" forState:UIControlStateNormal];
    certainButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [certainButton setTitleColor:[UIColor colorWithHex:0x4D5D83] forState:UIControlStateNormal];
    [certainButton setFrame:CGRectMake(titleView.width - 48,0 ,48, titleView.height)];
    [certainButton addTarget:self action:@selector(certainButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:certainButton];
    
    //线
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, titleView.maxY, titleView.width, 1)];
    lineView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    [view addSubview:lineView];
    
    [view addSubview:self.pickerView];
    
    UITapGestureRecognizer *hideTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
    hideTap.delegate = self;
    [self addGestureRecognizer:hideTap];
}

- (void)hide
{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.backgroundView.y = Screen_Height; 
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)certainButtonClicked:(UIButton*)button
{
    if ([self.delegate respondsToSelector:@selector(wdAddressPickerDidCertain:)]) {
        [self.delegate wdAddressPickerDidCertain:self];
    }
    [self hide];
}

- (UIPickerView *)pickerView
{
    if (_pickerView == nil) {
        _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 47, self.width, 192)];
    }
    return _pickerView;
}

@end