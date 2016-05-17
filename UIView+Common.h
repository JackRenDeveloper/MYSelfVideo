//
//  UIView+Common.h
//  killAllFree
//
//  Created by qianfeng on 15/9/23.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import <UIKit/UIKit.h>


//获取试图位置信息的类别

@interface UIView (Postion)

CGFloat screenWidth();

CGFloat screenHeight();

CGFloat width(CGRect rect);

CGFloat height(CGRect rect);

- (CGFloat)width;

- (CGFloat)height;

/**
 *  获取视图坐标信息
 *
 *  @param view 视图
 *
 *  @return 坐标
 */
CGFloat maxX(UIView *view);

CGFloat maxY(UIView *view);

CGFloat minX(UIView *view);

CGFloat minY(UIView *view);

CGFloat midX(UIView *view);

CGFloat midY(UIView *view);


@end

@interface UIView (Common)

@end
