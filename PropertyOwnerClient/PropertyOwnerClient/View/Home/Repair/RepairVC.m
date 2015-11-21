//
//  RepairVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/28.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "RepairVC.h"
#import "RepairInfo.h"
#import "RepairCell.h"
#import "RepairDesc.h"
@interface RepairVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *arrays;
@end

@implementation RepairVC
-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.segRepair.selectedSegmentIndex=0;
    [self chooseSeg:self.segRepair];
    self.repairTableView.rowHeight = 120;
    self.repairTableView.delegate =self;
    self.repairTableView.dataSource =self;
    _arrays = [[NSMutableArray alloc] init];
}

- (IBAction)chooseSeg:(UISegmentedControl *)sender {
    NSInteger index =   sender.selectedSegmentIndex;
    
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:[[Config Instance] getRoomId],@"roomOrCommunityId",[NSString stringWithFormat:@"%ld",(long)index],@"scheduleType",nil];
    [manager POST:API_BASE_URL_STRING(URL_FINREPAIRLISTBYROOMID) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        NSLog(@"%@",dictionary);
        if (_arrays!=nil) {
            [_arrays removeAllObjects];
            if (dictionary) {
                if (dictionary[Y_Data]) {
                    dictionary = dictionary[Y_Data];
                    if (dictionary[@"records"]) {
                        dictionary = dictionary[@"records"];
                        for (NSDictionary *dict in dictionary) {
                            // 创建模型对象
                            RepairInfo *repairInfo = [RepairInfo objectWithKeyValues:dict ];
                            // 添加模型对象到数组中
                            [_arrays addObject:repairInfo];
                        }
                    }
                }
            }
            [self.repairTableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.arrays.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RepairInfo *repairInfo = self.arrays[indexPath.row];
    
    // 1.创建cell
    RepairCell *cell = [RepairCell cellWithTableView:tableView];
    // 2.设置数据
    [cell settingData:repairInfo];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        RepairInfo *repairInfo = _arrays[indexPath.row];
        RepairDesc *repairDesc = [self.storyboard instantiateViewControllerWithIdentifier:@"RepairDesc"];
        repairDesc.repairId=repairInfo.repairId;
        repairDesc.title=@"报修详情";
        [self.navigationController pushViewController:repairDesc animated:YES];
}




@end
