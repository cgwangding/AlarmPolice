//
//  AlarmQuickView.h
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/11.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidAlarmQuickly)();
typedef void(^AlarmQuicklyCancel)();

@interface AlarmQuickView : UIView

@property (strong, nonatomic) UIImageView *alarmImgView;

@property (strong, nonatomic) UIImageView *alarmQuicklyImgView;

@property (assign, nonatomic) CGRect orginalRect;

@property (assign, nonatomic) CGPoint g_prePoint;
@property (assign, nonatomic) CGPoint g_nextPoint;

- (void)didAlarmQuicklyBlock:(DidAlarmQuickly)alarmQuickly;

- (void)didAlarmCanceled:(AlarmQuicklyCancel)alarmCancel;

@end
