
//
//  AlarmQuickView.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/11.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "AlarmQuickView.h"

@interface AlarmQuickView ()

@property (assign, nonatomic) CGPoint prePoint;
@property (assign, nonatomic) CGPoint nextPoint;

@property (copy, nonatomic) DidAlarmQuickly block;
@property (copy, nonatomic) AlarmQuicklyCancel cancelBlock;

@property (assign, nonatomic) BOOL hadAlarm;

@end

@implementation AlarmQuickView

- (void)awakeFromNib
{
    self.alarmImgView = self.subviews[2];
    self.alarmQuicklyImgView = self.subviews[1];
}

- (void)didAlarmQuicklyBlock:(DidAlarmQuickly)alarmQuickly
{
    self.block = alarmQuickly;
}

- (void)didAlarmCanceled:(AlarmQuicklyCancel)alarmCancel
{
    self.cancelBlock = alarmCancel;
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    DDLog(@"touchesBegan");
    UITouch *touch = [touches anyObject];
    CGPoint curPoint = [touch locationInView:self];
    self.hadAlarm = NO;
    self.prePoint = curPoint;
    if (CGRectContainsPoint(self.alarmImgView.frame, curPoint)) {
        //        self.alarmImgView.highlighted = YES;
    }else{
        if (self.cancelBlock) {
            self.cancelBlock();
        }
        self.hidden = YES;
    }
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    DDLog(@"touchesMoved");
    UITouch *touch = [touches anyObject];
    CGPoint curPoint = [touch locationInView:self];
    //移动的距离
    CGFloat distance = self.prePoint.y - curPoint.y;
    self.prePoint = curPoint;
    
    CGRect frame = self.alarmImgView.frame;
    frame.origin.y -= distance;
    self.alarmImgView.frame = frame;
    
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint curPoint = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.alarmQuicklyImgView.frame, self.alarmImgView.center) && self.hadAlarm == NO) {
        self.hadAlarm = YES;
        //执行一键报警功能
        DDLog(@"一键报警>>>>>>>>>>>>>>>");
        self.alarmImgView.frame = self.orginalRect;
        self.hidden = YES;
        if (self.block) {
            self.block();
        }
    }else if (CGRectContainsPoint(self.alarmQuicklyImgView.frame, self.alarmImgView.center) == NO) {
        //返回原位
        [UIView animateWithDuration:0.25 animations:^{
            self.alarmImgView.frame = self.orginalRect;
        }];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.orginalRect = self.alarmImgView.frame;
}

@end
