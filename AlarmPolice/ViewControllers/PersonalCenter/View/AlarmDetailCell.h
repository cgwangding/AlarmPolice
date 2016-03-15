//
//  AlarmDetailCell.h
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/22.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contextLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftleadingConstraint;

@end
