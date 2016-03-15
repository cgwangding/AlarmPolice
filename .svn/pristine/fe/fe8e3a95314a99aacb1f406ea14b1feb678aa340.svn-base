
//
//  ImageView.m
//  AlarmPolice
//
//  Created by AD-iOS on 15/12/9.
//  Copyright © 2015年 Adinnet. All rights reserved.
//

#import "ImageView.h"

#import <AVFoundation/AVFoundation.h>

#import <AssetsLibrary/AssetsLibrary.h>

@interface ImageView ()

@property (strong, nonatomic) UIButton *imageButton;
@property (strong, nonatomic) UIButton *cameraButton;

@property (strong, nonatomic) UILabel *tipLabel;

@end

@implementation ImageView
@synthesize cancelButton = _cancelButton;

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupWidget];
    }
    return self;
}

- (void)setupWidget
{
    [self addSubview:self.imageButton];
    [self addSubview:self.cameraButton];
    [self addSubview:self.cancelButton];
    [self addSubview:self.tipLabel];
    
}

- (void)cameraButtonClicked:(UIButton*)button
{
    if ([self isAuthorizetionCamera]) {
        if ([self.delegate respondsToSelector:@selector(shouldPresentCamera)]) {
            [self.delegate shouldPresentCamera];
        }
    }
}

- (void)imageButtonClicked:(UIButton*)button
{
    if ([self isAuthorizetionPhotoLibarary]) {
        if ([self.delegate respondsToSelector:@selector(shouldPresentImagePicker)]) {
            [self.delegate shouldPresentImagePicker];
        }
    }
}

#pragma mark - helper

- (BOOL)isAuthorizetionCamera
{
    BOOL isAuth = NO;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"未获得授权使用相机" message:@"请在\"设置\"->\"隐私\"->\"相机\"中打开" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        isAuth = YES;
    }
    
    return isAuth;
}

- (BOOL)isAuthorizetionPhotoLibarary
{
    BOOL isAuth = NO;
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (authStatus == ALAuthorizationStatusDenied || authStatus == ALAuthorizationStatusRestricted) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"未获得授权使用相册" message:@"请在\"设置\"->\"隐私\"->\"照片\"中打开" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        isAuth = YES;
    }
    
    return isAuth;
}

#pragma mark - getter and setter

- (UIButton *)imageButton
{
    if (_imageButton == nil) {
        _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_imageButton setFrame:CGRectMake(self.cameraButton.x - 50 - 28, 102, 50, 50)];
        [_imageButton setImage:[UIImage imageNamed:@"zhaopian_x2"] forState:UIControlStateNormal];
        [_imageButton setImage:[UIImage imageNamed:@"zhaopian_down_x2"] forState:UIControlStateHighlighted];
        [_imageButton addTarget:self action:@selector(imageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _imageButton;
}

- (void)setCancelButton:(UIButton *)cancelButton
{
    _cameraButton = cancelButton;
}

- (UIButton *)cancelButton
{
    if (_cancelButton == nil) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setFrame:CGRectMake(self.cameraButton.maxX + 28, 102, 50, 50)];
        [_cancelButton setImage:[UIImage imageNamed:@"quxiao_x2"] forState:UIControlStateNormal];
        [_cancelButton setImage:[UIImage imageNamed:@"quxiao_down_x2"] forState:UIControlStateHighlighted];
    }
    return _cancelButton;
}

- (UIButton *)cameraButton
{
    if (_cameraButton == nil) {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraButton setFrame:CGRectMake(Screen_Width / 2.0 - 48, 79, 96, 96)];
        [_cameraButton setImage:[UIImage imageNamed:@"paizhao_x2"] forState:UIControlStateNormal];
        [_cameraButton setImage:[UIImage imageNamed:@"paizhao_down_x2"] forState:UIControlStateHighlighted];
        [_cameraButton addTarget:self action:@selector(cameraButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.cameraButton.maxY + 36, Screen_Width, 18)];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = [UIColor colorWithHex:0xFD3290];
        _tipLabel.text = @"请告诉警方你在哪，发生了什么";
    }
    return _tipLabel;
}

@end
