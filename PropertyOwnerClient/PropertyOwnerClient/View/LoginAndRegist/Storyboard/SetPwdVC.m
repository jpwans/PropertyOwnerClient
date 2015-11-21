//
//  SetPwdVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/16.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "SetPwdVC.h"
#import "LoginDao.h"
@interface SetPwdVC ()<UIAlertViewDelegate>
{
    NSString * versionUrl;
}
@property (weak, nonatomic) IBOutlet UITextField *firstPwdField;
@property (weak, nonatomic) IBOutlet UITextField *secondPwdField;
- (IBAction)setPwdAction:(id)sender;

@end

@implementation SetPwdVC
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarTintColor:BACKGROUND_COLOR];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:NO animated:FALSE];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createSetPwdBtn];
    [self drawUnderBorderWithBtn:_firstPwdField];
    [self drawUnderBorderWithBtn:_secondPwdField];
}
-(void)drawUnderBorderWithBtn:(UITextField *)textField{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, textField.frame.size.height - 1, self.view.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:227.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0].CGColor;
    [textField.layer addSublayer:bottomBorder];
}
/**
 *  创建保存按钮
 */
-(void)createSetPwdBtn{
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@"保存"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(setPwdAction:)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
}


- (void)setPwdAction:(id)sender {
    NSLog(@"设置密码");
    NSString *firstPwd = self.firstPwdField.text;
    NSString *secondPwd = self.secondPwdField.text;
    
    //    [self.navigationController popViewControllerAnimated:YES];
    //    return ;
    if (![firstPwd isEqualToString:secondPwd]) {
        [self.view makeToast:@"请输入的密码不一致!" duration:1.5f position:@"center"];
        return;
    }
    NSString *phoneNum =self.phoneNum;
    NSString *roomId = self.roomId;
    //加密
    firstPwd = [DES3Util encrypt:firstPwd];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:phoneNum,@"telephone",firstPwd,@"password",LoginType,@"type",roomId,@"roomId",nil];
    [manager POST:API_BASE_URL_STRING(URL_REGISTER) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dictionary= responseObject;
        NSLog(@"%@",dictionary);
        if (dictionary) {
            int code =  [dictionary[@"code"] intValue];
            if (1==code ) {
                [self.view makeToast:@"恭喜您，注册成功！" duration:1.5f position:@"top"];
//                [self.navigationController popToRootViewControllerAnimated:YES];
                UIAlertView  *alertView =[[UIAlertView alloc] initWithTitle:@"提示" message:@"恭喜您，注册成功,确认登陆吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                [alertView show];
                return ;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
    
    
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [[LoginDao sharedManager] login:self.phoneNum pwd:self.firstPwdField.text withCompletionHandler:^(NSDictionary *loginDictionary, NSError *error) {
            if (!error) {
                if (0 == [[loginDictionary objectForKey:Y_Data] count]) {
                    return ;
                }
                if  ([[[loginDictionary objectForKey:Y_Data] objectForKey:Y_TYPE] integerValue] == 1) {
                    NSLog(@"%@",loginDictionary);
                    loginDictionary = [loginDictionary objectForKey:Y_Data];
                    NSString * username = self.phoneNum ;
                    LoginInfo *log = [LoginInfo objectWithKeyValues:loginDictionary];
                    [[Config Instance] saveLoginInfo:log andUserName:username andPwd:self.firstPwdField.text  andIsRemember:1 ];
                    [[Config Instance] saveCookie:YES];
                    //检查新版本
                    [[PublicClass sharedManager] getNewVersionWithCompletionHandler:^(NSDictionary *dictionary, NSError *error) {
                        if (!error) {
                            NSLog(@"%@",dictionary);
                            if (dictionary [Y_Data]) {
                                dictionary = dictionary[Y_Data];
                                versionUrl =  dictionary[@"versionUrl"];
                                if ([dictionary[@"forceUpdate"] intValue] == 0) {
                                    if (![Y_APP_VERSION isEqualToString:dictionary[@"version"]]) {
                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"有最新版可以下载" delegate:self cancelButtonTitle:@"不需要" otherButtonTitles:@"尝尝鲜", nil];
                                        [alertView show];
                                    }
                                }
                                else{
                                    //强制更新
                                    [self alertView:nil didDismissWithButtonIndex:1];
                                }
                            }
                        }
                    }];
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_group_t group = dispatch_group_create();
                    dispatch_group_async(group, queue, ^{
                        [System_Notification postNotificationName:Notif_Login object:nil];
                    });
                    dispatch_group_async(group, queue, ^{
                        XMPPManager *manager= [XMPPManager sharedInstance];
                        if(manager.xmppStream == nil){
                            [manager setupStream];
                        }
                        [manager goOnline];
                    });
                }}
        }];
        
    }
}

@end
