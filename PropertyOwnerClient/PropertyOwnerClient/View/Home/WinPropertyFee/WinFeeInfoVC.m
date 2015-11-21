//
//  WinFeeInfoVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/28.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "WinFeeInfoVC.h"
#import "WinSumFee.h"
#import "PropertyFeeDao.h"
@interface WinFeeInfoVC ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *arrays;
@end

@implementation WinFeeInfoVC
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [[PropertyFeeDao sharedManager] getPropertyFeeWithCompletionHandler:^(NSDictionary *dictionary, NSError *error) {
        if (dictionary) {
            dictionary = dictionary[Y_Data];
            self.sumEarnFee.text =dictionary[@"sumEarnFee"]?dictionary[@"sumEarnFee"]:@"0.00";
            self.earnFee.text = dictionary[@"earnFee"]?dictionary[@"earnFee"]:@"0.00";
        }
        else{
            NSLog(@"error:%@",[error localizedDescription]);
        }
    }];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.sumFee.delegate =self;
    self.sumFee.dataSource =self;
    self.sumFee.rowHeight=30;
//    UIView *view =[ [UIView alloc]init];
//    view.backgroundColor = [UIColor clearColor];
//    [ self.sumFee setTableFooterView:view];
//    [ self.sumFee setTableHeaderView:view];
//    view = nil;
//    
}

-(NSMutableArray *)arrays{
    if (_arrays==nil) {
        _arrays = [[NSMutableArray alloc] init];
        AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:[[Config Instance] getRoomId] forKey:@"roomId"];
        [manager POST:API_BASE_URL_STRING(URL_FINDEARNINFO) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                       [self.sumFee reloadData];
                    }
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error:%@",[error localizedDescription]);
        }];
    }
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    WinSumFee *winSumFee = _arrays[indexPath.row];

    
    cell.detailTextLabel.font = SystemFont(15);
    cell.detailTextLabel.textColor =RGBCOLOR(111, 113, 121);
    cell.textLabel.font = SystemFont(15);
    cell.textLabel.textColor =RGBCOLOR(111, 113, 121);
    
    cell.textLabel.text =winSumFee.name;
    cell.detailTextLabel.text =winSumFee.earCharges;
    UIView *V = [[UIView alloc] init];
    V.frame = CGRectMake(0, 29, SCREEN_WIDTH, 1);
    V.backgroundColor = RGBCOLOR(227, 228, 228);
    [cell addSubview:V];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


@end
