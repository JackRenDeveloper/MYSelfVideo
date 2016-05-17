//
//  CSChannelTableViewCell.h
//  CSVideo
//
//  Created by qianfeng on 15/10/15.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSChannelModel.h"

@protocol CSChannelDelegate <NSObject>

- (void)ViewAction:(NSString *)url;

- (void)ButtonAction:(NSString *)cate_id;

@end

@interface CSChannelTableViewCell : UITableViewCell

@property (nonatomic, strong) CSChanneDataModel *model;

@property (nonatomic, assign) id <CSChannelDelegate> delegate;

@end
