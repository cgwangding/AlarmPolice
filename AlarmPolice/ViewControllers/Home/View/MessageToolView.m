//
//  MessageToolView.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/8.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "MessageToolView.h"
#import "SpeekView.h"
#import "ImageView.h"
#import "IQKeyboardManager.h"

@interface MessageToolView ()<UITextFieldDelegate,UIGestureRecognizerDelegate,ImageViewDelegate>

//键盘选项按钮
@property (strong, nonatomic) UIButton *keyboardButton;
//拍照按钮
@property (strong, nonatomic) UIButton *imageButton;
//语音按钮
@property (strong, nonatomic) UIButton *speekButton;
//隐藏按钮
@property (strong, nonatomic) UIButton *hideButton;

//
@property (strong, nonatomic) UIWindow *showWindow;

@property (strong, nonatomic) UIView *textInputView;
@property (strong, nonatomic) UITextField *textField;

//语音界面
@property (strong, nonatomic) SpeekView *speekView;
//图片选择界面
@property (strong, nonatomic) ImageView *imageView;


//指向左右两个按钮
@property (strong, nonatomic) UIButton *leftButton;
@property (strong, nonatomic) UIButton *rightButton;

@property (assign, nonatomic) BOOL isWillHideKeyBoard;

@end

@implementation MessageToolView

//+ (instancetype)sharedToolView
//{
//    static MessageToolView *toolView  = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        toolView = [[MessageToolView alloc]init];
//    });
//    return toolView;
//}

- (void)show
{
    [self.showWindow makeKeyAndVisible];
    [self.showWindow addSubview:self];
}

- (void)hide
{
    [self endEditing:YES];
    [self.showWindow resignKeyWindow];
    //    [self removeFromSuperview];
    self.showWindow.hidden = YES;
    [[UIApplication sharedApplication].keyWindow makeKeyWindow];
}

- (instancetype)init
{
    if (self = [super init]) {
        self.frame = CGRectMake(0, Screen_Height - 302, Screen_Width, 302);
        self.backgroundColor = [UIColor whiteColor];
        [self setupWidget];
        [self addNotification];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
        tapGesture.delegate = self;
        [self.showWindow addGestureRecognizer:tapGesture];
    }
    return self;
}

#pragma mark - ImageViewDelegate

- (void)shouldPresentImagePicker
{
    if ([self.delegate respondsToSelector:@selector(messageToolViewNeedPresentImagePicker:)]) {
        [self.delegate messageToolViewNeedPresentImagePicker:self];
        [self hide];
    }
}

- (void)shouldPresentCamera
{
    //照相机
    if ([self.delegate respondsToSelector:@selector(messageToolViewNeedPresentCamera:)]) {
        [self.delegate messageToolViewNeedPresentCamera:self];
        [self hide];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    if (touchPoint.y < 0) {
        return YES;
    }
    return NO;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self hide];
    //此处为发送按钮
    if ([self.delegate respondsToSelector:@selector(messageToolView:didNeedSendMessage:)]) {
        [self.delegate messageToolView:self didNeedSendMessage:textField.text];
    }
    
    return YES;
}

#pragma mark - notification

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidShowNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardDidShowNotification:(NSNotification*)notifi
{
    NSDictionary *dict = [notifi userInfo];
    if (self.isWillHideKeyBoard) {
        return;
    }
    if ([notifi.name isEqualToString:UIKeyboardWillHideNotification]) {
        self.isWillHideKeyBoard = YES;
        [UIView animateWithDuration:[dict[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
            CGRect frame = self.frame;
            frame.origin.y += ((Screen_Height - 302) - frame.origin.y);
            self.frame = frame;
        } completion:^(BOOL finished) {
            
        }];
        return;
    }
    //如果有需要再使用
    
    CGRect endRect = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if ((self.textInputView.maxY + self.y)> endRect.origin.y) {
        CGRect frame = self.frame;
        frame.origin.y = endRect.origin.y - self.textInputView.maxY;
        self.frame = frame;
    }else{
        CGRect frame = self.frame;
        frame.origin.y = endRect.origin.y - self.textInputView.maxY;
        self.frame = frame;
    }
}

- (void)keyboardDidHideNotification:(NSNotification*)notifi
{
    self.isWillHideKeyBoard = NO;
    //    NSDictionary *dict = [notifi userInfo];
    
}

#pragma mark - private
- (void)setupWidget
{
    UIView *view =  [self makeToolViewWithLeftButton:self.keyboardButton rightButton:self.imageButton];
    [self addSubview:view];
    
    [self addSubview:self.speekView];
    
    [self.speekView didRecordCompletion:^(NSURL *filePath, NSError *error) {
        [self hide];
        if ([_delegate respondsToSelector:@selector(messageToolView:didNeedSendRecord:withError:)]) {
            [_delegate messageToolView:self didNeedSendRecord:filePath withError:error];
        }
        
    }];
}


- (UIView*)makeToolViewWithLeftButton:(UIButton*)leftButton rightButton:(UIButton*)rightButton
{
    self.leftButton = leftButton;
    self.rightButton = rightButton;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Screen_Width, 46)];
    view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    [leftButton setFrame:CGRectMake(0, 0, 46, 46)];
    [view addSubview:leftButton];
    
    rightButton.frame = CGRectMake(view.width - 46, 0, 46, 46);
    [view addSubview:rightButton];
    
    [view addSubview:self.hideButton];
    self.hideButton.frame = CGRectMake(view.width / 2.0 - 12, 0, 24, view.height);
    [self.hideButton setEnlargeEdgeWithTop:0 right:20 bottom:0 left:20];
    
    return view;
}

- (UIView*)makeInputView
{
    UIView *view  = [self makeToolViewWithLeftButton:self.speekButton rightButton:self.imageButton];
    
    UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(self.speekButton.width, 7, Screen_Width - 46 * 2, view.height - 14)];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    NSDictionary *attr = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:RGBA(3, 3, 3, 0.4)};
    NSAttributedString *placeAttr = [[NSAttributedString alloc]initWithString:@"请告诉警方你在哪里，发生了什么" attributes:attr];
    tf.font = [UIFont systemFontOfSize:14];
    tf.attributedPlaceholder = placeAttr;
    tf.enablesReturnKeyAutomatically = YES;
    tf.returnKeyType = UIReturnKeySend;
    [view addSubview:tf];
    tf.delegate = self;
    self.textField = tf;
    
    return view;
}

#pragma mark - button action

- (void)speekButtonClicked:(UIButton*)button
{
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *view =  [self makeToolViewWithLeftButton:self.keyboardButton rightButton:self.imageButton];
    [self addSubview:view];
    self.speekView = nil;
    [self addSubview:self.speekView];
    [self.imageView removeFromSuperview];
    [self.textInputView removeFromSuperview];
}

- (void)imageButtonClicked:(UIButton*)button
{
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *view =  [self makeToolViewWithLeftButton:self.keyboardButton rightButton:self.speekButton];
    [self addSubview:view];
    self.imageView = nil;
    [self addSubview:self.imageView];
    [self.speekView removeFromSuperview];
    [self.textInputView removeFromSuperview];
}

- (void)keyboardButtonClicked:(UIButton*)button
{
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.textInputView =  [self makeInputView];
    [self addSubview:self.textInputView];
    [self.textField becomeFirstResponder];
    [self.imageView removeFromSuperview];
    [self.speekView removeFromSuperview];
    
}

#pragma mark - getter

- (UIButton *)keyboardButton
{
    if (_keyboardButton == nil) {
        _keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_keyboardButton setImage:[UIImage imageNamed:@"jianban_x2"] forState:UIControlStateNormal];
        [_keyboardButton setImage:[UIImage imageNamed:@"jianban_down_x2"] forState:UIControlStateHighlighted];
        [_keyboardButton addTarget:self action:@selector(keyboardButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _keyboardButton;
}

- (UIButton *)imageButton
{
    if (_imageButton == nil) {
        _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_imageButton setImage:[UIImage imageNamed:@"zhaopian_xiao_x2"] forState:UIControlStateNormal];
        [_imageButton setImage:[UIImage imageNamed:@"zhaopian_xiao_down_x2"] forState:UIControlStateHighlighted];
        [_imageButton addTarget:self action:@selector(imageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _imageButton;
}

- (UIButton *)speekButton
{
    if (_speekButton == nil) {
        _speekButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_speekButton setImage:[UIImage imageNamed:@"yuying_x2"] forState:UIControlStateNormal];
        [_speekButton setImage:[UIImage imageNamed:@"yuying_down_x2"] forState:UIControlStateHighlighted];
        [_speekButton addTarget:self action:@selector(speekButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speekButton;
}

- (UIButton *)hideButton
{
    if (_hideButton == nil) {
        _hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_hideButton setImage:[UIImage imageNamed:@"jiantou_x2"] forState:UIControlStateNormal];
        [_hideButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hideButton;
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

- (SpeekView *)speekView
{
    if (_speekView == nil) {
        _speekView = [[SpeekView alloc]initWithFrame:CGRectMake(0, 46, Screen_Width, 256)];
        _speekView.backgroundColor = [UIColor whiteColor];
    }
    return _speekView;
}

- (ImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[ImageView alloc]initWithFrame:CGRectMake(0, 46, Screen_Width, 256)];
        [_imageView.cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        _imageView.backgroundColor = [UIColor whiteColor];
        _imageView.delegate = self;
    }
    return _imageView;
}

#pragma mark - dealloc

- (void)dealloc
{
    [self removeNotification];
}

@end
