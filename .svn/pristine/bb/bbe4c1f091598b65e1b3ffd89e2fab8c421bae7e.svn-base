//
//  ImageView.h
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/9.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ImageViewDelegate;

@interface ImageView : UIView

@property (weak, nonatomic) id<ImageViewDelegate>delegate;

/**
 *  must add action for this button.Default action is null.
 */
@property (strong, nonatomic, readonly) UIButton *cancelButton;


@end

@protocol ImageViewDelegate <NSObject>

@required

- (void)shouldPresentCamera;

- (void)shouldPresentImagePicker;

@end