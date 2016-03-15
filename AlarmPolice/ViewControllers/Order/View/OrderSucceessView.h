//
//  OrderSucceessView.h
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/21.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderSucceessView : UIView
@property (weak, nonatomic) IBOutlet UILabel *orderAddrLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderDateLabel;


+ (instancetype)shardSuccessView;

- (void)show;
- (void)hide;
@end
