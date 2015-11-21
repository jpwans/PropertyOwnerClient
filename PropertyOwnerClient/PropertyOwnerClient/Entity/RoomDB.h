//
//  RoomDB.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/7/9.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RoomDB : NSManagedObject

@property (nonatomic, retain) NSString * roleType;
@property (nonatomic, retain) NSString * community;
@property (nonatomic, retain) NSString * communityId;
@property (nonatomic, retain) NSString * companyId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * roomId;
@property (nonatomic, retain) NSString * roomNo;
@property (nonatomic, retain) NSString * sex;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSString * buildingNo;
@property (nonatomic, retain) NSString * unitNo;

@end
