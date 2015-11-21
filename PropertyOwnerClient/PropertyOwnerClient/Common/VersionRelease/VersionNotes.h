//
//  VersionNotes.h
//  UnisouthParents
//
//  Created by neo on 14-6-27.
//  Copyright (c) 2014年 unisouth. All rights reserved.
//

/*
 {
 resultCount = 1;
 results =     (
 {
 artistId = 开发者 ID;
 artistName = 开发者名称;
 price = 0;
 isGameCenterEnabled = 0;
 kind = software;
 languageCodesISO2A =             (
 EN
 );
 trackCensoredName = 审查名称;
 trackContentRating = 评级;
 trackId = 应用程序 ID;
 trackName = 应用程序名称";
 trackViewUrl = 应用程序介绍网址;
 userRatingCount = 用户评级;
 userRatingCountForCurrentVersion = 1;
 version = 版本号;
 wrapperType = software;
 }
 );
 }
 */
#import <Foundation/Foundation.h>

//releaseNoteText       版本更新日志
//releaseVersionText    版本号
//resultDic             所有请求到的数据

typedef void (^CompletionBlock)(NSString *releaseNoteText,NSString *releaseVersionText,NSDictionary *resultDic);
typedef void (^isOrNotCompletionBlock)(BOOL isLatestVersion,NSString *releaseNoteText,NSString *releaseVersionText,NSDictionary *resultDic);
typedef void (^CompletionBlockError)(NSError *error);


@interface VersionNotes : NSOperation


//检测是否是第一次启动
+ (BOOL)isAppOnFirstLaunch;

//检测是否有系统自动更新  有返回信息，没有检测最新版本,如果不是最新版，返回最新版信息
+ (void)isAppVersionUpdatedWithAppIdentifier:(NSString *)appIdentifier updatedInformation:(CompletionBlock)updatedInformation latestVersionInformation:(CompletionBlock)latestVersionInformation completionBlockError:(CompletionBlockError)completionBlockError;

//判断是否有最新版，并返回版本信息
+(void)isOrNotTheLatestVersionInformationWithAppIdentifier:(NSString *)appIdentifier isOrNotTheLatestVersionCompletionBlock:(isOrNotCompletionBlock)completionBlock completionBlockError:(CompletionBlockError)completionBlockError;

//获取最新版本信息
+(void)getTheLatestVersionInformationWithAppIdentifier:(NSString *)appIdentifier completionBlock:(CompletionBlock)completionBlock completionBlockError:(CompletionBlockError)completionBlockError;



@end
