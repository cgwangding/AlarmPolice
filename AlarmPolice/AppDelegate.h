//
//  AppDelegate.h
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/1.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSMutableArray<UIImage*> *sharedImageArr;

@property (copy, nonatomic) NSString *sharedInputStr;

@end
