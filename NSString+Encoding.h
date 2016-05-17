//
//  NSString+Encoding.h
//  CS_KillAllFree
//
//  Created by qianfeng on 15/9/24.
//  Copyright © 2015年 陈思. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encoding)

NSString *URLEncodedString(NSString *str);

NSString * MD5Hash(NSString *aString);

@end
