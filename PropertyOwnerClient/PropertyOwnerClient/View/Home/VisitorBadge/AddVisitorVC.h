//
//  AddVisitorVC.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/18.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VisitorQrcode.h"
#import "QrcodeInfoVC.h"
@interface AddVisitorVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *communityName;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;

@property (weak, nonatomic) IBOutlet UISwitch *isDriving;
- (IBAction)isDrivingAction:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *switchSex;
- (IBAction)switchSexAction:(UISegmentedControl *)sender;

- (IBAction)jumpAction:(id)sender;

@end
