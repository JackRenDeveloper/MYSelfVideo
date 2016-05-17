//
//  CSGameModel.h
//  CSVideo
//
//  Created by qianfeng on 15/10/14.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "JSONModel.h"

@protocol CSGameDataModel
@end
@interface CSGameDataModel : JSONModel

@property (nonatomic, copy) NSString <Optional> *cate_id;
@property (nonatomic, copy) NSString <Optional> *game_name;
@property (nonatomic, copy) NSString <Optional> *short_name;
@property (nonatomic, copy) NSString <Optional> *game_url;

@property (nonatomic, copy) NSString <Optional> *game_src;
@property (nonatomic, copy) NSString <Optional> *game_icon;
@property (nonatomic, copy) NSString <Optional> *online_room;
@property (nonatomic, copy) NSString <Optional> *online_room_ios;

@end

@interface CSGameModel : JSONModel

@property (nonatomic, strong) NSArray <CSGameDataModel> *data;

@end
