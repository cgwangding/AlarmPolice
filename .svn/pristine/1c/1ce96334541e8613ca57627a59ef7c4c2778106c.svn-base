
//
//  PoliceWillArriveView.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/22.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "PoliceWillArriveView.h"

@implementation PoliceWillArriveView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)callPoliceButtonClicked:(id)sender {
    if (self.policePhoneLabel.text != nil) {
        [self phoneCallWithPhone:self.policePhoneLabel.text];
    }else{
        [self showWithMessage:@"未获取到警员的手机号"];
    }
}
@end
