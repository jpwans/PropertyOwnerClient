//
//  RegisterVC.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/15.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommunityTableVC.h"
#import "Community.h"
#import "RoomTableVC.h"
#import "Room.h"
@interface RegisterVC : UIViewController<PassRegValueDelegate>
@property (weak, nonatomic) IBOutlet UIButton *chooseAddress;
@property (nonatomic, strong) Community *comModel;
@property (nonatomic, strong) Room *roomModel;



@end
