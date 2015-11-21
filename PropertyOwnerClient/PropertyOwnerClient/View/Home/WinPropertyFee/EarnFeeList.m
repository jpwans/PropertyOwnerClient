//
//  EarnFeeList.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/28.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "EarnFeeList.h"
#import "EarnFeeCell.h"


@implementation EarnFeeList
-(void)awakeFromNib {
    [super awakeFromNib];
    self.dataSource =self;
    self.delegate=self;
    pageNo = 0;
    pageSize = 5;
    
    moreArrays = [[NSMutableArray alloc] init];
      [self addFooter];


    self.rowHeight = 30;

}
-(NSMutableArray *)arrays{
    if (_arrays==nil) {
        _arrays = [[NSMutableArray alloc] init];
        AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:[NSString stringWithFormat:@"%ld", (long)pageNo] forKey:@"pageNo"];
        [parameters setValue:[NSString stringWithFormat:@"%ld", (long)pageSize] forKey:@"pageSize"];
        [parameters setValue:[[Config Instance] getRoomId] forKey:@"roomId"];
        [manager POST:API_BASE_URL_STRING(URL_EARNFEELIST) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary= responseObject;
            if (dictionary) {
                if (dictionary[Y_Data]) {
                    dictionary = dictionary[Y_Data];
                    if (dictionary[@"records"]) {
                        dictionary = dictionary[@"records"];
                        for (NSDictionary *dict in dictionary) {
                            // 创建模型对象
                            WinSumFee *winSumFee = [WinSumFee objectWithKeyValues:dict ];
                            // 添加模型对象到数组中
                            [_arrays addObject:winSumFee];
                        }
                        [self reloadData];
                        pageNo++;
                    }
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error:%@",[error localizedDescription]);
        }];    }
    return  _arrays;
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrays.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"show";
    EarnFeeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EarnFeeCell" owner:nil options:nil] lastObject];
    }

    WinSumFee *winSumFee = _arrays[indexPath.row];
    cell.name.text =winSumFee.name;
    cell.money.text =winSumFee.earCharges;
    cell.time.text = winSumFee.earnTime;
    return cell;
}


#pragma mark - LoadMoreData
- (void)addFooter
{
    __unsafe_unretained typeof(self) vc = self;
    // 添加上拉刷新尾部控件
    [self addFooterWithCallback:^{
        // 进入刷新状态就会回调这个Block
        [vc loadMoreData];
    }];
}

- (void)loadMoreData
{
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSString stringWithFormat:@"%ld", (long)pageNo] forKey:@"pageNo"];
    [parameters setValue:[NSString stringWithFormat:@"%ld", (long)pageSize] forKey:@"pageSize"];
    [parameters setValue:[[Config Instance] getRoomId] forKey:@"roomId"];
    [manager POST:API_BASE_URL_STRING(URL_EARNFEELIST) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        if (dictionary) {
            if (dictionary[Y_Data]) {
                dictionary = dictionary[Y_Data];
                if (dictionary[@"records"]) {
                    dictionary = dictionary[@"records"];
                    for (NSDictionary *dict in dictionary) {
                        // 创建模型对象
                        WinSumFee *winSumFee = [WinSumFee objectWithKeyValues:dict ];
                        // 添加模型对象到数组中
                        [_arrays addObject:winSumFee];
                    }
                    [self resetActivityArrayDataResource:moreArrays];
                    pageNo++;
                }
                else{
                    [self.superview makeToast:Not_History_Data duration:1.0f position:@"bottom"];
                    [self footerEndRefreshing];
                    return;
                }
            }
            else{
                [self.superview makeToast:Not_History_Data duration:1.0f position:@"bottom"];
                [self footerEndRefreshing];
                return;
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
}

- (void)resetActivityArrayDataResource:(NSArray *)moreArray
{
    [self beginUpdates];
    NSMutableArray *dataCells = [NSMutableArray array];
    NSInteger count = _arrays.count;
    for (WinSumFee *object in moreArray) {
        [dataCells addObject:[NSIndexPath indexPathForRow:count++ inSection:0]];
        [_arrays addObject:object];
    }
    [self insertRowsAtIndexPaths:dataCells withRowAnimation:UITableViewRowAnimationFade];
    [self endUpdates];
    [self footerEndRefreshing];
}




@end
