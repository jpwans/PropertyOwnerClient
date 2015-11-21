//
//  QrcodeInfoVC.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/19.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisitorQrcode.h"
@interface QrcodeInfoVC : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UIImageView *carImageView;

@property (weak, nonatomic) IBOutlet UILabel *community;
@property (weak, nonatomic) IBOutlet UILabel *phone;
@property (nonatomic, strong)   VisitorQrcode*visitorQrcode ;
@end
