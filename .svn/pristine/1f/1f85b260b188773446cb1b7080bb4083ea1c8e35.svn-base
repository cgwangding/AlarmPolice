
//
//  QestionFeedbackViewController.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/21.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "QestionFeedbackViewController.h"

@interface QestionFeedbackViewController ()

@property (strong, nonatomic) UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UITextView *textVeiw;

@end

@implementation QestionFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"问题反馈";
    self.rightBarButtonItem.title = @"提交";
    self.rightBarButtonItem.image = nil;
    self.rightBarButtonItem.tintColor = [UIColor whiteColor];
    [self.textVeiw addSubview:self.placeholderLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewDidChangedNotification:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)rightAction
{
    if ([self.textVeiw.text isNilString]) {
        [self.view showWithMessage:@"请输入您的建议"];
    }else{
        [self.textVeiw resignFirstResponder];
        [self submitSuggest];
    }
}

- (void)textViewDidChangedNotification:(NSNotification*)notifi
{
    UITextView *textView  = [notifi object];
    if (textView.text.length > 0) {
        self.placeholderLabel.hidden = YES;
    }else{
        self.placeholderLabel.hidden = NO;
    }
    if (textView.text.length > 200) {
        textView.text = [textView.text substringToIndex:200];
    }
}

- (void)submitSuggest
{
    NSDictionary *params = @{@"context":self.textVeiw.text,@"tokenID":UUID};
    [self.view showWithStatus:@"提交中……"];
    __weak typeof(self) weakSelf = self;
    [APIManager suggestWithParams:params success:^(NSDictionary *dict) {
        __strong typeof(self) strongSelf = weakSelf;
        APHide;
        [strongSelf.view showWithMessage:@"提交成功"];
        
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

- (UILabel *)placeholderLabel
{
    if (_placeholderLabel == nil) {
        _placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 200, 19)];
        _placeholderLabel.font = [UIFont systemFontOfSize:14];
        _placeholderLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _placeholderLabel.text  = @"您的反馈将帮助我们更快的成长";
    }
    return _placeholderLabel;
}

@end
