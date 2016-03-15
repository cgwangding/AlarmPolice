//
//  RecordWaveView.h
//  WaveViewDemo
//
//  Created by AD-iOS on 15/12/9.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  RecordWaveViewDelegate;

@interface RecordWaveView : UIView

@property (weak, nonatomic) id<RecordWaveViewDelegate>delegate;

- (void)pauseTiemr;

- (void)restartTimer;

- (void)updateVoice:(CGFloat)voice;

@end

@protocol  RecordWaveViewDelegate<NSObject>

@required

- (void)recordDidTimedOut;

@end