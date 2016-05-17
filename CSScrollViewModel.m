//
//  CSScrollViewModel.m
//  CSVideo
//
//  Created by qianfeng on 15/10/14.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "CSScrollViewModel.h"

@implementation CSScrollViewDataModel

+(JSONKeyMapper *)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"room.room_id":@"room_id"}];
}

@end

@implementation CSScrollViewModel

@end
