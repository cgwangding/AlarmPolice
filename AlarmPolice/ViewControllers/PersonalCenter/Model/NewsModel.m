//
//  NewsModel.m
//  AlarmPolice
//
//  Created by AD-iOS on 16/1/6.
//  Copyright © 2016年 Adinnet. All rights reserved.
//

#import "NewsModel.h"


@implementation NewsModel

MJExtensionCodingImplementation

@end
@implementation Data

+ (NSDictionary *)objectClassInArray{
    return @{@"noFocusAndNotice" : [NoFocusandnotice class], @"nofocusAndNews" : [NoFocusandnews class], @"yesFocusAndNews" : [Yesfocusandnews class], @"yesFocusAndNotice" : [Yesfocusandnotice class]};
//    return @{@"noFocus":[NoFocus class],@"yesFocus":[YesFocus class]};
}

MJExtensionCodingImplementation

@end


@implementation NoFocusandnotice
MJExtensionCodingImplementation
@end


@implementation NoFocusandnews
MJExtensionCodingImplementation
@end


@implementation Yesfocusandnews
MJExtensionCodingImplementation
@end


@implementation Yesfocusandnotice
MJExtensionCodingImplementation
@end


