//
//  PersonalInfoChangeViewController.h
//  AlarmPolice
//
//  Created by AD-iOS on 16/3/5.
//  Copyright © 2016年 Adinnet. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, PersonalInfoType) {
    PersonalInfoTypeName = 1,
    PersonalInfoTypeSex,
    PersonalInfoTypeIDCardNum,
};

@interface PersonalInfoChangeViewController : BaseViewController

@property (assign, nonatomic) PersonalInfoType infoType;

@property (copy, nonatomic) NSString *infoStr;

@end
