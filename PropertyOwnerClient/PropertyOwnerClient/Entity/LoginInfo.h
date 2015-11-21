//
//  LoginInfo.h
//  WuYeO2O
//
//  Created by MoPellet on 15/5/11.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginInfo : NSObject
/**
 *  物管名
 */
@property (nonatomic, strong) NSString *community;
/**
 *  物管ID
 */
@property (nonatomic, strong) NSString *communityId;
/**
 *  公司ID
 */
@property(nonatomic,strong)NSString *companyId;
/**
 *  姓名
 */
@property (nonatomic, strong) NSString *name;
/**
 *  业主ID
 */
@property (nonatomic, strong) NSString *ownerId;
/**
 *  手机号
 */
@property (nonatomic, strong) NSString *phone;
/**
 *  角色类型
 */
@property (nonatomic, strong) NSString *roleType;
/**
 *  房间id
 */
@property (nonatomic, strong) NSString *roomId;
/**
 *  房间号码
 */
@property (nonatomic, strong) NSString *roomNo;
/**
 *  性别
 */
@property (nonatomic, strong) NSString *sex;
/**
 *  登陆类型 1代表业主  2代表物业
 */
@property (nonatomic, strong) NSString *type;
/**
 *  头像
 */
@property (nonatomic, strong) NSString *photo;
@property (nonatomic, strong) NSString *buildingNo;
@property (nonatomic, strong) NSString *unitNo;
@property (nonatomic, strong) NSString *status;
@end
