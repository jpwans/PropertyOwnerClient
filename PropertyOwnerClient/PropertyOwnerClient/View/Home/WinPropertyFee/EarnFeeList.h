//
//  EarnFeeList.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/28.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WinSumFee.h"
@interface EarnFeeList : UITableView<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger pageNo;
    NSInteger pageSize;
    NSMutableArray *moreArrays;
}
@property (nonatomic, strong) NSMutableArray *arrays;
@end
