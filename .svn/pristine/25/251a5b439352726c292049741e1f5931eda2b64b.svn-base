//
//  BaseItem.m
//  CustomCalandar
//
//  Created by AD-iOS on 15/12/17.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "BaseItem.h"

@implementation BaseItem

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    self.model = nil;
}

- (void)setModel:(DateModel *)model
{
    _model = model;
    if (model == nil) {
        return;
    }
    NSString *title = nil;
    if (model.day < 10) {
        title = [NSString stringWithFormat:@"0%lu",model.day];
    }else{
        title = [NSString stringWithFormat:@"%lu",model.day];
    }
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateSelected];
    
    [self setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:.6] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self setImage:[UIImage imageNamed:@""] forState:UIControlStateSelected];
    if (model.isCurrentMonth == NO) {
        self.itemType = BaseItemTypeNotCurrentMonth;
    }else{
        if (model.isBetweenValidDate) {
            self.itemType = BaseItemTypeNone;
        }else{
            self.itemType = BaseItemTypeInvalid;
        }
    }
    
}

- (void)setItemType:(BaseItemType)itemType
{
    _itemType = itemType;
    switch (itemType) {
        case BaseItemTypeNone:
            self.backgroundColor = [UIColor whiteColor];
            self.titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
            self.userInteractionEnabled = YES;
            NSLog(@"%@",self.model);
            break;
        case BaseItemTypeSelect:
            self.titleLabel.textColor = [UIColor whiteColor];
            self.backgroundColor = [UIColor colorWithRed:58/255.0 green:75/255.0 blue:118/255.0 alpha:1.0];
            self.userInteractionEnabled = YES;
            [self setNeedsLayout];
            break;
        case BaseItemTypeInvalid:
            self.userInteractionEnabled = NO;
            self.titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
            self.backgroundColor = [UIColor colorWithRed:58/255.0 green:75/255.0 blue:118/255.0 alpha:.1];
            break;
        case BaseItemTypeNotCurrentMonth:
            self.userInteractionEnabled = NO;
            self.titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
            self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.03];
            break;
        default:
            break;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(5, 0, CGRectGetWidth(self.frame), 14);
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    if (self.itemType == BaseItemTypeSelect) {
        self.titleLabel.textColor = [UIColor whiteColor];
    }else{
        self.titleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    }
    
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor colorWithRed:226/255.0 green:226/255.0 blue:226/255.0 alpha:1.0].CGColor;
}

@end
