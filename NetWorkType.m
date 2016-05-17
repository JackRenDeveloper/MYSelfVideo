//
//  NetWorkType.m
//  CSVideo
//
//  Created by qianfeng on 15/10/19.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import "NetWorkType.h"
#import <UIKit/UIKit.h>

@implementation NetWorkType

+ (NETWORK_TYPE)getNetworkTypeFromStatusBar {
    
    UIApplication *app = [UIApplication sharedApplication];
    
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    
    NSNumber *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]])     {
            
            dataNetworkItemView = subview;
            
            break;
            
        }
        
    }
    NETWORK_TYPE nettype = NETWORK_TYPE_NONE;
    
    NSNumber * num = [dataNetworkItemView valueForKey:@"dataNetworkType"];
    
    nettype = [num intValue];
    
    return nettype;
    
}

@end
