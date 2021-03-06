//
//  NewsModel.h
//  AlarmPolice
//
//  Created by AD-iOS on 16/1/6.
//  Copyright © 2016年 Adinnet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

@class Data,NoFocusandnotice,NoFocusandnews,Yesfocusandnews,Yesfocusandnotice;
@interface NewsModel : NSObject


@property (nonatomic, copy) NSString *Msg;

@property (nonatomic, copy) NSString *IsSuccess;

@property (nonatomic, copy) NSString *Code;

@property (nonatomic, strong) Data *Data;


@end
@interface Data : NSObject

@property (nonatomic, strong) NSArray<NoFocusandnotice *> *noFocusAndNotice;

@property (nonatomic, strong) NSArray<NoFocusandnews *> *nofocusAndNews;

@property (nonatomic, strong) NSArray<Yesfocusandnews *> *yesFocusAndNews;

@property (nonatomic, strong) NSArray<Yesfocusandnotice *> *yesFocusAndNotice;

@end

@interface NoFocusandnotice : NSObject

@property (nonatomic, copy) NSString *state;

@property (nonatomic, copy) NSString *pushNum;

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSString *newsID;

@property (nonatomic, copy) NSString *realName;

@property (nonatomic, copy) NSString *collectState;

@property (nonatomic, copy) NSString *context;

@property (nonatomic, copy) NSString *pushStatus;

@property (nonatomic, copy) NSString *files;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *summary;

@property (nonatomic, copy) NSString *createTime;

@property (nonatomic, copy) NSString *publishTime;

@property (nonatomic, copy) NSString *publishState;

@property (nonatomic, copy) NSString *focusStatus;

@property (nonatomic, copy) NSString *infoType;

@property (nonatomic, copy) NSString *updateTime;

@property (copy, nonatomic) NSString *url;

@property (copy, nonatomic) NSString *savepath;

@end

@interface NoFocusandnews : NSObject

@property (nonatomic, copy) NSString *state;

@property (nonatomic, copy) NSString *pushNum;

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSString *newsID;

@property (nonatomic, copy) NSString *realName;

@property (nonatomic, copy) NSString *collectState;

@property (nonatomic, copy) NSString *context;

@property (nonatomic, copy) NSString *pushStatus;

@property (nonatomic, copy) NSString *files;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *summary;

@property (nonatomic, copy) NSString *createTime;

@property (nonatomic, copy) NSString *publishTime;

@property (nonatomic, copy) NSString *publishState;

@property (nonatomic, copy) NSString *focusStatus;

@property (nonatomic, copy) NSString *infoType;

@property (nonatomic, copy) NSString *updateTime;

@property (copy, nonatomic) NSString *url;

@property (copy, nonatomic) NSString *savepath;

@end

@interface Yesfocusandnews : NSObject

@property (nonatomic, copy) NSString *state;

@property (nonatomic, copy) NSString *pushNum;

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSString *newsID;

@property (nonatomic, copy) NSString *realName;

@property (nonatomic, copy) NSString *collectState;

@property (nonatomic, copy) NSString *context;

@property (nonatomic, copy) NSString *pushStatus;

@property (nonatomic, copy) NSString *files;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *summary;

@property (nonatomic, copy) NSString *createTime;

@property (nonatomic, copy) NSString *publishTime;

@property (nonatomic, copy) NSString *publishState;

@property (nonatomic, copy) NSString *focusStatus;

@property (nonatomic, copy) NSString *infoType;

@property (nonatomic, copy) NSString *updateTime;

@property (copy, nonatomic) NSString *url;

@property (copy, nonatomic) NSString *savepath;


@end

@interface Yesfocusandnotice : NSObject

@property (nonatomic, copy) NSString *state;

@property (nonatomic, copy) NSString *pushNum;

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSString *newsID;

@property (nonatomic, copy) NSString *realName;

@property (nonatomic, copy) NSString *collectState;

@property (nonatomic, copy) NSString *context;

@property (nonatomic, copy) NSString *pushStatus;

@property (nonatomic, copy) NSString *files;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *summary;

@property (nonatomic, copy) NSString *createTime;

@property (nonatomic, copy) NSString *publishTime;

@property (nonatomic, copy) NSString *publishState;

@property (nonatomic, copy) NSString *focusStatus;

@property (nonatomic, copy) NSString *infoType;

@property (nonatomic, copy) NSString *updateTime;

@property (copy, nonatomic) NSString *url;

@property (copy, nonatomic) NSString *savepath;


@end

