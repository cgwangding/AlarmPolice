


//
//  GuideViewController.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/23.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "GuideViewController.h"
#import "LoginViewController.h"

@interface GuideViewController ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    for (int i = 1; i < 4; i++) {
        NSString *name = [NSString stringWithFormat:@"guide%d",i];
        UIImage *image= [UIImage imageNamed:name];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
        imageView.frame = CGRectMake(Screen_Width * (i - 1), 0, Screen_Width, Screen_Height);
        imageView.userInteractionEnabled = YES;
        [self.scrollView addSubview:imageView];
        if (i == 3) {
            //添加滑动或者是点击
//            UITapGestureRecognizer *swipe = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoLogin)];
//            [imageView addGestureRecognizer:swipe];
        }
    }
    [self.view addSubview:self.scrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gotoLogin
{
    LoginViewController *loginVC = MainStoryBoard(@"loginIdentifier");
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollView.contentOffset.x > (Screen_Width * 2)) {
        [self gotoLogin];
    }
}

#pragma mark - getter

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        _scrollView.contentSize = CGSizeMake(Screen_Width * 3, Screen_Height);
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

@end
