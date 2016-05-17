//
//  CSChannelModel.h
//  CSVideo
//
//  Created by qianfeng on 15/10/14.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "JSONModel.h"
#import "NewbieModel.h"

@protocol CSChanneDataModel
@end
@interface CSChanneDataModel : JSONModel

@property (nonatomic, copy) NSString <Optional> *title;

@property (nonatomic, copy) NSString <Optional> *cate_id;

@property (nonatomic, strong) NSArray <CSDateModel> *roomlist;

@end

@interface CSChannelModel : JSONModel

@property (nonatomic, strong) NSArray <CSChanneDataModel> *data;

@end
