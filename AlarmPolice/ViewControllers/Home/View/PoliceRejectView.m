
//
//  PoliceRejectView.m
//  AlarmPolice
//
//  Created by AD-iOS on 16/1/20.
//  Copyright © 2016年 Adinnet. All rights reserved.
//

#import "PoliceRejectView.h"

@implementation PoliceRejectView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)closeButtonClicked:(id)sender {
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.x = -Screen_Width;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}
@end
