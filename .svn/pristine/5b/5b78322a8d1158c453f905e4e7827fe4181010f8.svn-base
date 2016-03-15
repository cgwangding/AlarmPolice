//
//  WaitPoliceView.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/22.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "WaitPoliceView.h"

@interface WaitPoliceView()

@property (copy,  nonatomic) CancelAlarmBlock block;

@end

@implementation WaitPoliceView

- (void)awakeFromNib
{
    [self.cancelButton addTarget:self action:@selector(cancelAlarm) forControlEvents:UIControlEventTouchUpInside];
}

- (void)cancelAlarm
{
    if (self.block) {
        self.block();
    }
    
}

-(void)onAlarmCancedBlock:(CancelAlarmBlock)block
{
    self.block = block;
}

@end
