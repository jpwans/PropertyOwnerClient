//
//  RoomTableVC.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/16.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Community.h"
#import "Room.h"
@protocol PassRegValueDelegate<NSObject>
/**
 *给注册页面传值
 */
-(void)passRegValues:(Community*)regCommuntity andRoom:(Room *)regRoom;
@end

@interface RoomTableVC : UITableViewController
@property (nonatomic, strong) NSMutableArray *roomArray;
@property (nonatomic,strong)Community *communityModel;
///1.定义向注册页面传值的委托变量
@property (weak,nonatomic) id <PassRegValueDelegate> delegate;
@end

