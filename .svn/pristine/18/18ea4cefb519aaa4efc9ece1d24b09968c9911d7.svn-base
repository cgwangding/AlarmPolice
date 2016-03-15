//
//  WDAddressPicker.h
//  AlarmPolice
//
//  Created by AD-iOS on 16/1/5.
//  Copyright © 2016年 Adinnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WDAddressPickerDelegate;

@interface WDAddressPicker : UIView

@property (weak, nonatomic) id<WDAddressPickerDelegate>delegate;

- (void)showWithController:(UIViewController*)controller;

@end

@protocol WDAddressPickerDelegate <NSObject>

@optional

- (void)wdAddressPickerDidCertain:(WDAddressPicker*)picker;

@end