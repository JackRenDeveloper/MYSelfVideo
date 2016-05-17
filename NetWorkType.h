//
//  NetWorkType.h
//  CSVideo
//
//  Created by qianfeng on 15/10/19.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NETWORK_TYPE_NONE = 0,
    NETWORK_TYPE_2G = 1,
    NETWORK_TYPE_3G = 2,
    NETWORK_TYPE_4G = 3,
    NETWORK_TYPE_5G= 4,//  5G目前为猜测结果
    NETWORK_TYPE_WIFI = 5
}NETWORK_TYPE;

@interface NetWorkType : NSObject

+ (NETWORK_TYPE)getNetworkTypeFromStatusBar;

@end
