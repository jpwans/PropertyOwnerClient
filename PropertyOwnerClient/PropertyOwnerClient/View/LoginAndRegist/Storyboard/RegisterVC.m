//
//  RegisterVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/15.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "RegisterVC.h"
#import "SetPwdVC.h"
@interface RegisterVC ()
{
    NSDictionary *dictionary ;
    NSMutableArray *comArray;
    int i ;//换号码计数器
    BOOL isAgree;
    NSMutableArray *arrays;//电话号码
    BOOL isNext ;//验证码标识码
}
- (IBAction)authCodeAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *phoneLab;
@property (weak, nonatomic) IBOutlet UITextField *authCodeField;
@property (weak, nonatomic) IBOutlet UIButton *authCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;
- (IBAction)nextStepAction:(id)sender;


@end

@implementation RegisterVC
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        i=0;
        isAgree = YES;
        arrays = [[NSMutableArray alloc] init];
        isNext = NO;
        
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    _chooseAddress.backgroundColor = BACKGROUND_COLOR;
    _authCodeBtn.backgroundColor = BACKGROUND_COLOR;
    [super viewWillAppear:animated];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    self.navigationItem.backBarButtonItem = backItem;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.view.backgroundColor = BACKGROUND_COLOR;
//    [self.navigationController.navigationBar setBarTintColor:BACKGROUND_COLOR];
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
//    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    if (self.comModel&&self.roomModel) {
        NSString *info = [NSString stringWithFormat:@"房间：%@/%@",   self.comModel.communityName,self.roomModel.roomNo];
        [self.chooseAddress setTitle:info forState:UIControlStateNormal];
    }
    else{
        [self.chooseAddress setTitle:@"点此选择您的住址" forState:UIControlStateNormal];
    }
    
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, _phoneLab.frame.size.height - 1, _phoneLab.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:227.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0].CGColor;
    [_phoneLab.layer addSublayer:bottomBorder];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setComArray];
}
-(void)setComArray{
  comArray = [[NSMutableArray alloc] init];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"0" ,@"pageNo",@"100",@"pageSize" ,nil];
    [manager GET:API_BASE_URL_STRING(URL_GETCOMMUNITY) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        dictionary = responseObject;
    NSLog(@"%@",dictionary);
        if (dictionary[Y_Data]) {
            dictionary =dictionary[Y_Data][@"records"];
            //  加载数据
            //NSMutableArray *comArray = [NSMutableArray array];
            for (NSDictionary *dict in dictionary) {
                // 创建模型对象
                Community *comEntity = [Community communityWithDict:dict];
                // 添加模型对象到数组中
                [comArray addObject:comEntity];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    if (comArray.count) {
        return YES;
    }

    return NO;
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString: @"jumpCommunity"]) {
        CommunityTableVC  *communityTableVC = segue.destinationViewController;
        communityTableVC.communityArray = comArray;
    }

   
}

-(void)passRegValues:(Community *)regCommuntity andRoom:(Room *)regRoom{
    arrays =[[NSMutableArray alloc] init];
    [arrays removeAllObjects];
    NSString *comID = regCommuntity.communityId;
    NSString *RoomID = regRoom.roomId;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:comID ,@"officeId",RoomID,@"roomId",nil];
    [manager POST:API_BASE_URL_STRING(URL_GETPHONE) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = responseObject;
        NSLog(@"返回的数据：%@",dic[Y_Data][@"records"]);
        self.phoneLab.text = NULL_VALUE;
        if (dic[Y_Data][@"records"]) {
            dic = dic[Y_Data][@"records"];
                    for (NSDictionary *dict in dic) {
                    [arrays addObject:dict[@"telephone"]];
                }
            NSLog(@"%lu",(unsigned long)arrays.count);
                self.phoneLab.text = arrays[arrays.count-1];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
}


- (IBAction)changePhoneNum:(id)sender {
    if (arrays.count) {
        
        if (i<arrays.count) {
            i++;
        }
        if (i==arrays.count) {
            i=0;
        }
        self.phoneLab.text = arrays[i];
    }
}
/**
 *  同意条款
 */
- (IBAction)switchForAgreeAction:(id)sender {
    NSString *selectImage = isAgree?@"check_box_normal.png":@"check_box_selected.png";
    [self.agreeBtn setImage:[UIImage imageNamed:selectImage] forState:UIControlStateNormal];
    isAgree = !isAgree;
}

-(void)startTime{
    __block int timeout=30; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [_authCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                _authCodeBtn.userInteractionEnabled = YES;
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                
                [_authCodeBtn setTitle:[NSString stringWithFormat:@"获取验证码(%@)",strTime] forState:UIControlStateNormal];
                _authCodeBtn.userInteractionEnabled = NO;
                
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
    
}

- (IBAction)authCodeAction:(id)sender {
    
    CHECKNETWORK

    NSString * phoneNum =  self.phoneLab.text;
    if (!(11==self.phoneLab.text.length)) {
        [self.view makeToast:@"手机号码格式错误" duration:1.5 position:@"center"];
        return;
    }
               [self startTime];
    [SMS_SDK getVerificationCodeBySMSWithPhone:phoneNum
                                          zone:@"86"
                                        result:^(SMS_SDKError *error)
     {
         if (!error) {
             [self.view makeToast:@"验证码发送成功！" duration:1.5f position:@"center"];
    
         }
         else{
             NSLog(@"%ld,%@",(long)error.errorCode,error.errorDescription);
             [self.view makeToast:@"验证码发送失败！" duration:1.5f position:@"center"];
         }
     }];
}


- (IBAction)nextStepAction:(id)sender {
    NSLog(@"下一步");
    SetPwdVC  *pwdVC =  [self.storyboard instantiateViewControllerWithIdentifier:@"setPwdIde"];

//    [self.navigationController pushViewController:pwdVC animated:YES];
//    return;
    CHECKNETWORK
    NSString *code = [_authCodeField.text trimString];
    NSString *phone = [_phoneLab.text trimString];
    if (phone.length!=11||[code isEmptyString]) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:SMSAPPKEY ,@"appkey",phone,@"phone" ,ZONE,@"zone",code,@"code",nil];
    [manager POST:URL_SMS_AUTH parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic= responseObject;
        int status = [dic[@"status"] intValue];
        if (200==status) {
            NSLog(@"验证成功！");
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                       pwdVC.phoneNum = self.phoneLab.text;
            pwdVC.roomId = self.roomModel.roomId;

            if (11==pwdVC.phoneNum.length&&pwdVC.roomId.length>0) {
                [self.navigationController pushViewController:pwdVC animated:YES];
            }
        }
        else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [MBProgressHUD showError:@"验证失败"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
    }];
}


@end
