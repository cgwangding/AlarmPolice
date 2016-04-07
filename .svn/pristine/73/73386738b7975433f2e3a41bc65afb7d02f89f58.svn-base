
//
//  WDTextView.m
//  AlarmPolice
//
//  Created by AD-iOS on 16/3/5.
//  Copyright © 2016年 Adinnet. All rights reserved.
//

#import "WDTextView.h"

@interface WDTextView ()

@property (strong, nonatomic) UILabel *placeholderLabel;

@end

@implementation WDTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.placeholderLabel];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textDidChanged) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)textDidChanged
{
    if (self.text != nil && [self.text isEqualToString:@""] == NO) {
        self.placeholderLabel.hidden = YES;
    }else{
        self.placeholderLabel.hidden = NO;
    }
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = [placeholder copy];
    self.placeholderLabel.text = _placeholder;
    CGSize size = [self.placeholderLabel sizeThatFits:CGSizeMake(MAXFLOAT, 21)];
    self.placeholderLabel.frame = CGRectMake(12, 8, size.width, size.height);
}



- (UILabel *)placeholderLabel
{
    if (_placeholderLabel == nil) {
        _placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 8, 0, 0)];
        _placeholderLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _placeholderLabel.font = [UIFont systemFontOfSize:14];
    }
    return _placeholderLabel;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

@end
