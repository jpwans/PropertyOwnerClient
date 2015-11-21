//
//  PayRecordsCell.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/6/9.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayRecordsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *money;
@property (weak, nonatomic) IBOutlet UILabel *time;

@end
