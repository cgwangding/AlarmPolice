//
//  WaitPoliceView.h
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/22.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CancelAlarmBlock)();

@interface WaitPoliceView : UIView
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

- (void)onAlarmCancedBlock:(CancelAlarmBlock)block;

@end
