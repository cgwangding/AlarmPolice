//
//  AddressCell.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/16.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "AddressCell.h"

@implementation AddressCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setChoose:(BOOL)choose
{
    if (choose) {
        self.addressLabel.textColor = [UIColor colorWithHex:0x3A4B76];
        self.chooseButton.selected = YES;
    }else{
        self.addressLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        self.chooseButton.selected = NO;
    }
}

@end
