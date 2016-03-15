//
//  AlarmHistoryImgTextCell.h
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/21.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "MGSwipeTableCell.h"
#import "AlarmHistoryTextCell.h"

@interface AlarmHistoryImgTextCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *eventImgView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

- (void)setResloveStatus:(HistoryStatus)status;

@end