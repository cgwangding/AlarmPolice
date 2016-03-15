//
//  MessageToolView.h
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/8.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageToolViewDelegate;

@interface MessageToolView : UIView

@property (weak, nonatomic) id<MessageToolViewDelegate>delegate;

- (void)show;
- (void)hide;

@end

@protocol MessageToolViewDelegate <NSObject>

@required
//照相机
- (void)messageToolViewNeedPresentCamera:(MessageToolView*)toolView;
//相册选择
- (void)messageToolViewNeedPresentImagePicker:(MessageToolView*)toolView;
//录音信息
- (void)messageToolView:(MessageToolView*)toolView didNeedSendRecord:(NSURL*)filePath withError:(NSError *)error;

- (void)messageToolView:(MessageToolView*)toolView didNeedSendMessage:(NSString*)message;

@end