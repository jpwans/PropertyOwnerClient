//
//  VistorDao.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/18.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VisitorDao : NSObject

+ (VisitorDao*)sharedManager;
-(void) visitorCardSourcesWithCompletionHandler: (void (^)(NSDictionary *getDictionary,NSError *error))block;
@end
