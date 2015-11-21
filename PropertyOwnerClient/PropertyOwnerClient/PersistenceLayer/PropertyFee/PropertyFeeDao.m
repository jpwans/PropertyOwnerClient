//
//  PropertyFeeDao.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/27.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "PropertyFeeDao.h"

@implementation PropertyFeeDao
static PropertyFeeDao *sharedManager = nil;

+ (PropertyFeeDao*)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[super alloc] init];
    });
    return sharedManager;
}
/**
 *  获取业主端物业费信息（业主所属房屋信息、赚取物业费抵扣后余额、未交额）。
 */
-(void) getPropertyFeeWithCompletionHandler: (void (^)(NSDictionary *dictionary,NSError *error))block{
    
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
    [manager POST:API_BASE_URL_STRING(URL_FINDPROPERTYFEE) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict= responseObject;
        if (block) {
            block(dict,nil);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSDictionary dictionary],error);
        }
    }];
    
}

@end
