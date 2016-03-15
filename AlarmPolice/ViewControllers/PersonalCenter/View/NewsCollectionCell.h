//
//  NewsCollectionCell.h
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/21.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsCollectionCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UIImageView *newsImgView;
@property (weak, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *newsDetailLabel;

@end