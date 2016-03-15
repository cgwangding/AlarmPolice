//
//  BaseCalandarView.h
//  CustomCalandar
//
//  Created by AD-iOS on 15/12/17.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateModel.h"

@interface BaseCalandarView : UIView

@property (strong, nonatomic, readonly) NSMutableArray<DateModel*>*dateArr;

@property (strong, nonatomic) NSDateComponents *currentComponents;

- (void)validDateFormDateComponents:(NSDateComponents*)startDateComp toDateComponents:(NSDateComponents*)endDateComp;

- (void)nextMonth;
- (void)previewMonth;

@end
