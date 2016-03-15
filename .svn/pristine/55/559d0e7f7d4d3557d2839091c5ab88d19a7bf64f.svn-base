
//
//  OrderSucceessView.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/21.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "OrderSucceessView.h"

@interface OrderSucceessView ()

@property (strong, nonatomic) UIWindow *showWindow;

@end

@implementation OrderSucceessView

+ (instancetype)shardSuccessView
{
    OrderSucceessView *shardedView = nil;
    shardedView = [[[NSBundle mainBundle]loadNibNamed:@"OrderSucceessView" owner:self options:nil] lastObject];
    shardedView.frame = CGRectMake(12, Screen_Height / 2 - 326 / 2.0, Screen_Width - 24, 326);
    return shardedView;
}

- (void)awakeFromNib
{
    UITapGestureRecognizer *hideTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
    [self.showWindow addGestureRecognizer:hideTap];
}

- (void)show
{
    
    [self.showWindow makeKeyAndVisible];
    [self.showWindow addSubview:self];
}

- (void)hide
{
    [self.showWindow resignKeyWindow];
    //    [self removeFromSuperview];
    self.showWindow.hidden = YES;
}

- (UIWindow *)showWindow
{
    if (_showWindow == nil) {
        _showWindow = [[UIWindow alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_Height)];
        [_showWindow setWindowLevel:UIWindowLevelAlert];
        _showWindow.backgroundColor = [[UIColor darkTextColor] colorWithAlphaComponent:.2];
    }
    return _showWindow;
}


@end
