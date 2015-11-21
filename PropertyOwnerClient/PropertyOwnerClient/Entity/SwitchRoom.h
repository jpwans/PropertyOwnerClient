//
//  SwitchRoom.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/7/10.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SwitchRoom : NSObject
@property (nonatomic, strong) NSString  *buildingNo;
@property (nonatomic, strong) NSString  *community;
@property (nonatomic, strong) NSString  *communityId;
@property (nonatomic, strong) NSString  *companyId;
@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *ownerId;
@property (nonatomic, strong) NSString  *phone;
@property (nonatomic, strong) NSString  *roleType;
@property (nonatomic, strong) NSString  *roomId;
@property (nonatomic, strong) NSString  *roomNo;
@property (nonatomic, strong) NSString  *sex;
@property (nonatomic, strong) NSString  *type;
@property (nonatomic, strong) NSString  *unitNo;
@property (nonatomic, strong) NSString *photo;
@property (nonatomic, assign,getter=isCheck)  BOOL  check;
@end
