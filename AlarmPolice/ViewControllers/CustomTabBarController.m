//
//  CustomTabBarController.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/8.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "CustomTabBarController.h"
#import "AlarmViewController.h"
#import "OrderViewController.h"
#import "MessageViewController.h"
#import "HistoryViewController.h"
#import "AppDelegate.h"
#import "PersonalCenterView.h"
#import "PersonalInfoTableViewController.h"
#import "PersonalCenterViewController.h"
#import "LoginViewController.h"

@interface CustomTabBarController ()

@property (strong, nonatomic) UIButton *buttonAlarm;
@property (strong, nonatomic) UIButton *buttonOrder;
@property (strong, nonatomic) UIButton *buttonMessage;

@property (weak, nonatomic) UIViewController *currentVC;

@property (strong, nonatomic) UIButton *rightLightButton;

@end

@implementation CustomTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    [self setupWidget];
    [self controlViewControllers];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(needShowLoginNotification:) name:ShouldShowLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeLampLightNotification:) name:AlarmSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(makeLigthExtinguishNotification:) name:AlarmLightShouldExtinguishNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AlarmSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AlarmLightShouldExtinguishNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - notification

- (void)needShowLoginNotification:(NSNotification*)notifi
{
    //    NSArray *arr = self.navigationController.viewControllers;
    //    for (id vc in arr) {
    //        if ([vc isKindOfClass:[LoginViewController class]]) {
    //            [self.navigationController popToViewController:vc animated:YES];
    //            return;
    //        }
    //    }
    [APService setAlias:[UUID substringToIndex:15] callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:self];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor  clearColor] size:CGSizeMake(Screen_Width, 64)] forBarMetrics:UIBarMetricsDefault];
    [APUserData sharedUserData].online = NO;
    
    //如果没有找到登录界面，
    LoginViewController *loginVC = MainStoryBoard(@"loginIdentifier");
    default_add_Bool(YES, HadPresentedKey);
    default_synchronize;
    if (self.navigationController.presentedViewController) {
        [self.navigationController.presentedViewController presentViewController:loginVC animated:YES completion:nil];
    }else{
        [self.navigationController presentViewController:loginVC animated:YES completion:nil];
    }
}

- (void)makeLampLightNotification:(NSNotification*)notifi
{
    self.rightLightButton.selected = YES;
    //    self.rightLightButton.userInteractionEnabled = YES;
}

- (void)makeLigthExtinguishNotification:(NSNotification*)notifi
{
    self.rightLightButton.selected = NO;
    //    self.rightLightButton.userInteractionEnabled = NO;
}

-(void)tagsAliasCallback:(int)iResCode
                    tags:(NSSet*)tags
                   alias:(NSString*)alias
{
    NSLog(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}


#pragma mark - ovrride

- (UIColor *)navigaitonBarBackgroundColor
{
    return [UIColor whiteColor];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)leftAction
{
    //    PersonalCenterView *centerView = [[PersonalCenterView alloc]initWithFrame:self.view.bounds];
    //    [centerView show];
    PersonalCenterViewController *vc = [PersonalCenterViewController new];
    vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    BaseNavigationController *nav = [[BaseNavigationController alloc]initWithRootViewController:vc];
    nav.navigationBarHidden = YES;
    nav.modalPresentationStyle = UIModalPresentationCustom;
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - private

- (void)controlViewControllers
{
    AlarmViewController *alarmVC = MainStoryBoard(@"alarmIdentifier");
    [self.view addSubview:alarmVC.view];
    [self addChildViewController:alarmVC];
    self.currentVC = alarmVC;
    
    OrderViewController *orderVC = MainStoryBoard(@"orderIdentifier");
    [self addChildViewController:orderVC];
    
    MessageViewController *msgVC = MainStoryBoard(@"messageIdentifier");
    [self addChildViewController:msgVC];
    
}

- (void)setupWidget
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 32, 32)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [button setImage:[UIImage imageNamed:@"gerenzhongxing_x2"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"gerenzhongxing_down_x2"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
    self.leftBarButtonItem.customView = button;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setFrame:CGRectMake(0, 0, 30, 44)];
    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -25)];
    [rightButton setImage:[UIImage imageNamed:@"baojing02_x2"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"baojing01_x2"] forState:UIControlStateSelected];
    rightButton.userInteractionEnabled = NO;
    //    self.rightBarButtonItem.customView = rightButton;
    //    self.rightLightButton = rightButton;
    //width = 180 height = 26
    
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 180, 26)];
    self.navigationItem.titleView = titleView;
    //生成顶部的切换按钮
    UIButton *buttonAlarm = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonAlarm setFrame:CGRectMake(0, 0, 60, 26)];
    [buttonAlarm setTitle:@"报警" forState:UIControlStateNormal];
    buttonAlarm.titleLabel.font = [UIFont systemFontOfSize:14];
    [buttonAlarm setTitleColor:[UIColor colorWithHex:0x3a4b76] forState:UIControlStateSelected];
    [buttonAlarm setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
    buttonAlarm.borderColor = [UIColor colorWithHex:0x3A4B76].CGColor;
    buttonAlarm.cornerRadius = 13;
    buttonAlarm.selected = YES;
    [buttonAlarm addTarget:self action:@selector(buttonAlarmClicked:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:buttonAlarm];
    self.buttonAlarm = buttonAlarm;
    
    UIButton *buttonOrder = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonOrder setFrame:CGRectMake(60, 0, 60, 26)];
    [buttonOrder setTitle:@"预约" forState:UIControlStateNormal];
    buttonOrder.titleLabel.font = [UIFont systemFontOfSize:14];
    [buttonOrder setTitleColor:[UIColor colorWithHex:0x3a4b76] forState:UIControlStateSelected];
    [buttonOrder setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
    buttonOrder.cornerRadius = 13;
    [buttonOrder addTarget:self action:@selector(buttonOrderClicked:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:buttonOrder];
    self.buttonOrder = buttonOrder;
    
    UIButton *buttonMessage = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonMessage setFrame:CGRectMake(120, 0, 60, 26)];
    [buttonMessage setTitle:@"资讯" forState:UIControlStateNormal];
    buttonMessage.titleLabel.font = [UIFont systemFontOfSize:14];
    [buttonMessage setTitleColor:[UIColor colorWithHex:0x3a4b76] forState:UIControlStateSelected];
    [buttonMessage setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
    buttonMessage.cornerRadius = 13;
    [buttonMessage addTarget:self action:@selector(buttonMessageClicked:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:buttonMessage];
    self.buttonMessage = buttonMessage;
    
}




#pragma mark - button action

- (void)buttonAlarmClicked:(UIButton*)button
{
    if (button.selected == NO) {
        [self.currentVC.view endEditing:YES];
        button.selected = YES;
        button.borderColor = [UIColor colorWithHex:0x3A4B76].CGColor;
        self.buttonOrder.borderColor = [UIColor clearColor].CGColor;
        self.buttonOrder.selected = NO;
        self.buttonMessage.borderColor = [UIColor clearColor].CGColor;
        self.buttonMessage.selected = NO;
        AlarmViewController *toVC = (AlarmViewController*)[self findControllerWithClass:[AlarmViewController class]];
        __weak typeof(self) weakSelf = self;
        [self transitionFromViewController:self.currentVC toViewController:toVC duration:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            __strong typeof(self) strongSelf = weakSelf;
            toVC.view.frame = strongSelf.view.bounds;
        } completion:^(BOOL finished) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.currentVC = toVC;
        }];
    }
}
- (void)buttonOrderClicked:(UIButton*)button
{
    if (button.selected == NO) {
        [self.currentVC.view endEditing:YES];
        
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        app.sharedInputStr = nil;
        [app.sharedImageArr removeAllObjects];
        button.selected = YES;
        button.borderColor = [UIColor colorWithHex:0x3A4B76].CGColor;
        self.buttonAlarm.borderColor = [UIColor clearColor].CGColor;
        self.buttonAlarm.selected = NO;
        self.buttonMessage.borderColor = [UIColor clearColor].CGColor;
        self.buttonMessage.selected = NO;
        OrderViewController *toVC = (OrderViewController*)[self findControllerWithClass:[OrderViewController class]];
        __weak typeof(self) weakSelf = self;
        
        [self transitionFromViewController:self.currentVC toViewController:toVC duration:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            __strong typeof(self) strongSelf = weakSelf;
            toVC.view.frame = strongSelf.view.bounds;
        } completion:^(BOOL finished) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.currentVC = toVC;
        }];
    }
}
- (void)buttonMessageClicked:(UIButton*)button
{
    if (button.selected == NO) {
        [self.currentVC.view endEditing:YES];
        
        button.selected = YES;
        AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        app.sharedInputStr = nil;
        [app.sharedImageArr removeAllObjects];
        button.borderColor = [UIColor colorWithHex:0x3A4B76].CGColor;
        self.buttonAlarm.borderColor = [UIColor clearColor].CGColor;
        self.buttonAlarm.selected = NO;
        self.buttonOrder.borderColor = [UIColor clearColor].CGColor;
        self.buttonOrder.selected = NO;
        MessageViewController *toVC = (MessageViewController*)[self findControllerWithClass:[MessageViewController class]];
        
        __weak typeof(self) weakSelf = self;
        [self transitionFromViewController:self.currentVC toViewController:toVC duration:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            __strong typeof(self) strongSelf = weakSelf;
            toVC.view.frame = strongSelf.view.bounds;
        } completion:^(BOOL finished) {
            __strong typeof(self) strongSelf = weakSelf;
            strongSelf.currentVC = toVC;
        }];
    }
}

#pragma mark - helper

- (UIViewController*)findControllerWithClass:(Class)class
{
    for (UIViewController *vc in self.childViewControllers) {
        if ([vc isKindOfClass:class]) {
            return vc;
        }
    }
    return nil;
}

#pragma mark - 


@end
