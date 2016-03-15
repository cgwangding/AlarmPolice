//
//  ImageMessageToolView.h
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/10.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^NeedAddImageBlock)();

typedef void(^SendButtonDidClicked)(NSArray<UIImage*>*imageArr, NSString *text);

@interface ImageMessageToolView : UIView

@property (strong, nonatomic) NSArray<UIImage*> *imageArray;

@property (copy, nonatomic) NSString *userInput;

- (void)onClickedAddContinueButtonBlock:(NeedAddImageBlock)blolck;

- (void)onClickedCertainButtonBlock:(SendButtonDidClicked)block;

- (void)show;
- (void)hide;
@end
