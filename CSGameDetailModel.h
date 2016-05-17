//
//  CSGameDetailModel.h
//  CSVideo
//
//  Created by qianfeng on 15/10/14.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "JSONModel.h"

@protocol CSGameDetailDataModel
@end
@interface CSGameDetailDataModel : JSONModel

@property (nonatomic, copy) NSString<Optional> *room_id;
@property (nonatomic, copy) NSString<Optional> *room_src;
@property (nonatomic, copy) NSString<Optional> *cate_id;
@property (nonatomic, copy) NSString<Optional> *room_name;

@property (nonatomic, copy) NSString<Optional> *show_status;
@property (nonatomic, copy) NSString<Optional> *subject;
@property (nonatomic, copy) NSString<Optional> *show_time;
@property (nonatomic, copy) NSString<Optional> *owner_uid;

@property (nonatomic, copy) NSString<Optional> *specific_catalog;
@property (nonatomic, copy) NSString<Optional> *specific_status;
@property (nonatomic, copy) NSString<Optional> *vod_quality;
@property (nonatomic, copy) NSString<Optional> *nickname;

@property (nonatomic, copy) NSString<Optional> *online;
@property (nonatomic, copy) NSString<Optional> *url;
@property (nonatomic, copy) NSString<Optional> *game_url;
@property (nonatomic, copy) NSString<Optional> *game_name;

@property (nonatomic, copy)NSString <Optional> *fans;

@property (nonatomic, copy)NSString <Optional> *hls_url;

@property (nonatomic, copy)NSString <Optional> *show_details;

@property (nonatomic, copy)NSString <Optional> *owner_avatar;

@property (nonatomic, copy)NSString <Optional> *owner_weight;

@end

@interface CSGameDetailModel : JSONModel

@property (nonatomic, strong) CSGameDetailDataModel *data;

@end
