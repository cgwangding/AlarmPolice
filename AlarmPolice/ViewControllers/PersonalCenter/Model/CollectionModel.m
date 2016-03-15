
//
//  CollectionModel.m
//  AlarmPolice
//
//  Created by AD-iOS on 16/1/7.
//  Copyright © 2016年 Adinnet. All rights reserved.
//

#import "CollectionModel.h"

@implementation CollectionModel
+ (NSDictionary *)objectClassInArray{
    return @{@"Data" : [CollectData class]};
}
@end
@implementation CollectData

+ (NSDictionary *)objectClassInArray{
    return @{@"model" : [Model class]};
}

@end


@implementation Model

@end


