//
//  MessageDetailViewController.h
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/22.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "BaseViewController.h"

@interface MessageDetailViewController : BaseViewController

@property (copy, nonatomic) NSString *url;

@property (assign, nonatomic) BOOL isCollected;

@property (copy, nonatomic) NSString *newsID;



@end