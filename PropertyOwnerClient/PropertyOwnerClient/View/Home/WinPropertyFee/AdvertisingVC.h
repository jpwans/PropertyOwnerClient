//
//  AdvertisingVC.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/26.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Advertising.h"
#import "MMScrollPresenter.h"
#import "MMScrollPage.h"
#import "WinFee.h"
@interface AdvertisingVC : UIViewController
@property (nonatomic, strong) Advertising *advertising;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@end
