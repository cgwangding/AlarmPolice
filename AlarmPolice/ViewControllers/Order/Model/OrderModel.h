//
//  OrderModel.h
//  AlarmPolice
//
//  Created by AD-iOS on 16/1/8.
//  Copyright © 2016年 Adinnet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OrderData,OrderAddr;
@interface OrderModel : NSObject

@property (nonatomic, copy) NSString *Msg;

@property (nonatomic, copy) NSString *IsSuccess;

@property (nonatomic, copy) NSString *Code;

@property (nonatomic, strong) OrderData *Data;

@end
@interface OrderData : NSObject

@property (nonatomic, strong) NSArray<OrderAddr *> *model;

@end

@interface OrderAddr : NSObject

@property (nonatomic, copy) NSString *policeID;

@property (nonatomic, copy) NSString *police;

@end

