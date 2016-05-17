//
//  CSScrollViewModel.h
//  CSVideo
//
//  Created by qianfeng on 15/10/14.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "JSONModel.h"
#import "NewbieModel.h"

@protocol CSScrollViewDataModel
@end
@interface CSScrollViewDataModel : JSONModel

@property (nonatomic, copy)NSString <Optional> *id;

@property (nonatomic, copy)NSString <Optional> *title;

@property (nonatomic, copy)NSString <Optional> *pic_url;

@property (nonatomic, copy)NSString <Optional> *room_id;

@end

@interface CSScrollViewModel : JSONModel

@property (nonatomic, strong) NSArray <CSScrollViewDataModel> *data;

@end
