//
//  PropertyFeeDao.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/27.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropertyFeeDao : NSObject
+ (PropertyFeeDao *)sharedManager;
/**
 *  获取业主端物业费信息（业主所属房屋信息、赚取物业费抵扣后余额、未交额）。
 */
-(void) getPropertyFeeWithCompletionHandler: (void (^)(NSDictionary *dictionary,NSError *error))block;
@end
