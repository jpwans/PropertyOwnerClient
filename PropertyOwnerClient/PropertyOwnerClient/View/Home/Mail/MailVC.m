//
//  MailVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/28.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "MailVC.h"
#import "CoreDateManager.h"
#import "MessageDB.h"
#import "MessageCell.h"
#import "MsgInfoTableView.h"
#import "MessageDB.h"
#import "RepairTableVC.h"
#import "SwitchRoom.h"
@interface MailVC ()<UITableViewDataSource,UITableViewDelegate>
{
    CoreDateManager *coreManager;
}

@property (nonatomic, strong) NSMutableArray *arrays;
@property (nonatomic, strong) SwitchRoom *switchRoom ;
@end

@implementation MailVC


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIView animateWithDuration:0.3 animations:^{
        //        self.navigationController.navigationBar.alpha = 1;
        self.navigationController.navigationBar.translucent = NO;
    }];
    self.navigationController.view.backgroundColor = BACKGROUND_COLOR;
    [self getArrays];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    coreManager = [[CoreDateManager alloc] init];
    NSLog(@"%lu",(unsigned long)_arrays.count);
    self.tableView.rowHeight = 60;
    self.view.backgroundColor = ALLBACKCOLOR;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newMsgCome:) name:Notif_XMPP_NewMsg object:nil];
}

-(void)newMsgCome:(NSNotification *)notifacation
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        _arrays = [[NSMutableArray alloc] init];
        _arrays=[coreManager msgGroupByType];
        dispatch_async(dispatch_get_main_queue(),^{
            [self.tableView reloadData];
        });
    });
}



-(void)getArrays{
    _arrays = [[NSMutableArray alloc] init];
    //      _arrays= [coreManager selectData:0 andOffset:0];
    
    _arrays=[coreManager msgGroupByType];
    //    dispatch_async(dispatch_get_main_queue(), ^{
    [self.tableView reloadData];
    //    });
    
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
    MessageDB *messageDB = self.arrays[indexPath.row];
    // 1.创建cell
    MessageCell *cell = [MessageCell cellWithTableView:tableView];
    // 2.设置数据
    [cell settingData:messageDB];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageCell *cell =  (MessageCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.isReadImage.image=nil;
    
    MessageDB *messageDB =self.arrays[indexPath.row];
    [coreManager updateMessageByAdviceId:messageDB.adviceId];
    MsgInfoTableView *msgInfoTableView = [self.storyboard instantiateViewControllerWithIdentifier:@"MsgInfoTableView"];
    msgInfoTableView.adviceType = messageDB.type;
    int type= [messageDB.type intValue];
    NSString *typeTitle = @"小区提醒";
    RepairTableVC *repairTableVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RepairTableVC"];
    switch (type) {
        case 0:
            
            typeTitle = @"小区通知";
            msgInfoTableView.title =typeTitle;
            [self.navigationController pushViewController:msgInfoTableView animated:YES];
            break;
        case 1:
            
            typeTitle = @"紧急通知";
            msgInfoTableView.title =typeTitle;
            [self.navigationController pushViewController:msgInfoTableView animated:YES];
            break;
        case 2:
            typeTitle = @"报修通知";
            if (![[SYSTEM_USERDEFAULTS objectForKey:Y_RepairMsgRoomId] isEqualToString:[SYSTEM_USERDEFAULTS objectForKey:Y_ROOMID]]) {
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
                [manager POST:API_BASE_URL_STRING(URL_FINDROOMLIST) parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSDictionary *dictionary= responseObject;
                    if (dictionary) {
                        NSLog(@"%@",dictionary);
                        if (dictionary[Y_Data]) {
                            dictionary = dictionary[Y_Data];
                            if (dictionary[@"records"]) {
                                dictionary = dictionary[@"records"];
                                for (NSDictionary *dict in dictionary) {
                                    // 创建模型对象
                                    if ([dict[Y_ROOMID] isEqualToString:[SYSTEM_USERDEFAULTS objectForKey:Y_RepairMsgRoomId] ]) {
                                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                                        _switchRoom = [SwitchRoom objectWithKeyValues:dict ];
                                        _switchRoom .check = NO;
                                        [SYSTEM_USERDEFAULTS setObject:_switchRoom.buildingNo forKey:Y_buildingNo];
                                        [SYSTEM_USERDEFAULTS setObject:_switchRoom.community forKey:Y_COMMUNITY];
                                        [SYSTEM_USERDEFAULTS setObject:_switchRoom.communityId forKey:Y_COMMUNITYID];
                                        [SYSTEM_USERDEFAULTS setObject:_switchRoom.companyId forKey:Y_COMPANYID];
                                        [SYSTEM_USERDEFAULTS setObject:_switchRoom.ownerId forKey:Y_OWNERID];
                                        [SYSTEM_USERDEFAULTS setObject:_switchRoom.name forKey:Y_NAME];
                                        [SYSTEM_USERDEFAULTS setObject:_switchRoom.phone forKey:Y_PHONE];
                                        [SYSTEM_USERDEFAULTS setObject:_switchRoom.roleType forKey:Y_ROLE_TYPE];
                                        [SYSTEM_USERDEFAULTS setObject:_switchRoom.roomId forKey:Y_ROOMID];
                                        [SYSTEM_USERDEFAULTS setObject: _switchRoom.roomNo forKey:Y_ROOMNO];
                                        [SYSTEM_USERDEFAULTS setObject:_switchRoom.sex forKey:Y_SEX];
                                        [SYSTEM_USERDEFAULTS setObject:_switchRoom.type forKey:Y_TYPE];
                                        [SYSTEM_USERDEFAULTS setObject:_switchRoom.unitNo forKey:Y_unitNo];
                                        [SYSTEM_USERDEFAULTS setObject:_switchRoom.photo forKey:Y_PHOTO];
                                        [SYSTEM_USERDEFAULTS synchronize];
                                        AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
                                        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:_switchRoom.roomId,@"roomId",nil];
                                        [manager POST:API_BASE_URL_STRING(URL_switchRoom) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                            NSDictionary *dictionary= responseObject;
                                            NSLog(@"%@",dictionary);
                                            NSLog(@"%@",dictionary[Y_Message]);
                                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                            NSLog(@"%@",[error localizedDescription]);
                                        }];
                                        [self.navigationController pushViewController:repairTableVC animated:YES];
                                    }
                                }
                            }
                        }
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"%@",[error localizedDescription]);
                }];
                
            }
            else {
                [self.navigationController pushViewController:repairTableVC animated:YES];
            }
            
            
            break;
        case 3:
            typeTitle = @"物业费通知";
            break;
        default:
            
            typeTitle = @"小区提醒";
            break;
    }
    
    
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"点击了删除");
        MessageDB *messageDB = _arrays[indexPath.row];
        [coreManager deleteByType:messageDB.type];
        [self.arrays removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
- ( CGFloat )tableView:( UITableView *)tableView heightForHeaderInSection:( NSInteger )section
{
    return 8.0 ;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Notif_XMPP_NewMsg object:nil];
}

@end
