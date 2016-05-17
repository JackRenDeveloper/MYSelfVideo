//
//  LiveTableViewCell.h
//  CSVideo
//
//  Created by qianfeng on 15/10/17.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol LiveTableViewCellDegelate <NSObject>

- (void)ViewAction:(NSString *)url;

@end

@interface LiveTableViewCell : UITableViewCell

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, assign) id <LiveTableViewCellDegelate> delegate;

@end
