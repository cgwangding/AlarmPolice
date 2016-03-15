

//
//  MessageDetailViewController.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/22.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "MessageDetailViewController.h"

@interface MessageDetailViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@property (strong, nonatomic) UIButton *collectButton;

@end

@implementation MessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"新闻详情";
    self.leftBarButtonItem.image = [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.leftBarButtonItem.tintColor = [UIColor colorWithHex:0x3A4B76];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 20, 20);
    [rightButton setImage:[UIImage imageNamed:@"unCollect"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"collect"] forState:UIControlStateSelected];
    [rightButton addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    rightButton.selected = self.isCollected;
    self.rightBarButtonItem.customView = rightButton;
    
    self.collectButton = rightButton;
    self.webView.delegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    
    DDLog(@"%@",self.url);
    [self.view addSubview:self.indicatorView];
    
     [self.indicatorView startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor *)navigaitonBarBackgroundColor
{
    return [UIColor whiteColor];
}

- (NSDictionary*)navigationBarTitleTextAttribute
{
    return @{NSForegroundColorAttributeName:[UIColor colorWithHex:0x3A4B76],NSFontAttributeName:[UIFont systemFontOfSize:18]};
}

- (void)rightAction
{
    if (self.collectButton.selected) {
        //取消
        [self cancelCollWithID:self.newsID];
    }else{
        //收藏
        [self collectionWithID:self.newsID];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
   
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.indicatorView stopAnimating];
}

- (void)collectionWithID:(NSString*)newsID
{
    NSDictionary *params = @{@"tokenID":UUID,@"newsID":newsID};
    __weak typeof(self) weakSelf = self;
    [self.view showWithStatus:@"收藏中……"];
    [APIManager collectionWithParams:params success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        [strongSelf.view showWithMessage:@"已收藏"];
        
        strongSelf.collectButton.selected = YES;
        
    } dataError:^(NSInteger code, NSString *message) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        [strongSelf.view showWithMessage:message];
        
    } failure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        APShowServiceError;
    }];
}

- (void)cancelCollWithID:(NSString*)newsID
{
    NSDictionary *params = @{@"tokenID":UUID,@"newsID":newsID};
    __weak typeof(self) weakSelf = self;
    [self.view showWithStatus:@"取消中……"];
    [APIManager cancelCollWithParams:params success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        [strongSelf.view showWithMessage:@"已取消"];
        strongSelf.collectButton.selected = NO;

        
    } dataError:^(NSInteger code, NSString *message) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        [strongSelf.view showWithMessage:message];
        
    } failure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        APShowServiceError;
    }];
}

#pragma mark - getter 

- (UIActivityIndicatorView *)indicatorView
{
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.color = APCyanColor;
        [_indicatorView setFrame:CGRectMake(Screen_Width / 2 - 20, self.view.height / 2 - 100, 40, 40)];
    }
    return _indicatorView;
}

@end