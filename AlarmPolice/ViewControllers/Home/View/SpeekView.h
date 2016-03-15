//
//  SpeekView.h
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/8.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidRecordCompletion)(NSURL *filePath, NSError *error);

@interface SpeekView : UIView

- (void)didRecordCompletion:(DidRecordCompletion)completion;

@end
