//
//  AlarmHistoryImgTextCell.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/21.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "AlarmHistoryImgTextCell.h"

@implementation AlarmHistoryImgTextCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setResloveStatus:(HistoryStatus)status
{
    switch (status) {
        case HistoryStatusComplete:
            self.statusLabel.text = @"已处理";
            self.statusLabel.textColor = [UIColor colorWithHex:0x22C97E];
            break;
        case HistoryStatusResoving:
            self.statusLabel.text = @"处理中";
            self.statusLabel.textColor = [UIColor colorWithHex:0xF7315F];
            break;
        case HistoryStatusUnResolve:
            self.statusLabel.text = @"未处理";
            //FFEB3B
            self.statusLabel.textColor = [UIColor colorWithHex:0xFFEB3B];
            break;
        case HistoryStatusCanceled:
            self.statusLabel.text = @"已取消";
            self.statusLabel.textColor = [UIColor colorWithHex:0xF7315F];
            
        default:
            break;
    }
}
@end
