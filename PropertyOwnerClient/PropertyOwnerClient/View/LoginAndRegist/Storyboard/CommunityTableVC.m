//
//  CommunityTableVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/15.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "CommunityTableVC.h"
#import "Community.h"
#import "Room.h"
#import "RoomTableVC.h"
@interface CommunityTableVC ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *Arrays ;
}
@end

@implementation CommunityTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.communityArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"show";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    Community *community = self.communityArray[indexPath.row];
    // 设置cell的数据
    cell.textLabel.text =community.communityName;
    cell.detailTextLabel.text = community.communityId;
    cell.detailTextLabel.hidden = YES;
    // 设置cell右边指示器的类型
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     RoomTableVC * roomTableVC = [[RoomTableVC alloc] init];
    Community *community = _communityArray[indexPath.row];
      roomTableVC.communityModel = community;
      [self.navigationController pushViewController:roomTableVC animated:YES];
}



@end
