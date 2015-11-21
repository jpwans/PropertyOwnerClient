//
//  VistorDao.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/18.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "VisitorDao.h"

@implementation VisitorDao

static VisitorDao *sharedManager = nil;

+ (VisitorDao*)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[super alloc] init];
    });
    return sharedManager;
}


-(void) visitorCardSourcesWithCompletionHandler: (void (^)(NSDictionary *getDictionary,NSError *error))block{
    
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheader];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"3",@"pageSize",@"0",@"pageNo",nil];
    [manager POST:API_BASE_URL_STRING(URL_GETVISITORLIST) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        if (block) {
            block(dictionary,nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block([NSDictionary dictionary],error);
        }
    }];
    
}
@end
