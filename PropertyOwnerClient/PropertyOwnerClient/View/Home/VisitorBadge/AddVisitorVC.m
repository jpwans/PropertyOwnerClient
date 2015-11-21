//
//  AddVisitorVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/5/18.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "AddVisitorVC.h"
#import "QrcodeInfoVC.h"
#import "VisitorTableVC.h"
@interface AddVisitorVC ()<UITextFieldDelegate>
{
    int sexIndex;
    int  isNotDriving;
    VisitorQrcode * visitorQrcode;
}
@end

@implementation AddVisitorVC
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    sexIndex =  1 ;//1 为男  2 为女
    isNotDriving = 2 ;// 0为没驾车  1 为驾车

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.communityName.text = [[Config Instance] getCommunityName];
    self.switchSex.selectedSegmentIndex = 0;
  
//    [self.nameField becomeFirstResponder];
    self.nameField.delegate =self;
    self.phoneField.delegate =self;
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchDownToKeyboard:)];
    [self.view addGestureRecognizer:tap];
}
- (void)touchDownToKeyboard:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}
- (IBAction)isDrivingAction:(id)sender {
    isNotDriving = self.isDriving.on?1:2;
    NSLog(@"%d",isNotDriving);
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField==_nameField) {
        [_phoneField becomeFirstResponder];
    }
    else  if (textField==_phoneField){
        [_phoneField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{

        [self animateTextField: textField up: NO];
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];

    
}

- (void)keyboardWillChangeFrame:(NSNotification *)note
{
    // 设置窗口的颜色
    self.view.window.backgroundColor = self.view.backgroundColor;
    
    // 0.取出键盘动画的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 1.取得键盘最后的frame
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 2.计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - self.view.frame.size.height;
    
    // 3.执行动画
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, transformY);
    }];
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    [_nameField resignFirstResponder];
    [_phoneField resignFirstResponder];
    //NSString * communityName = [Config Instance]
    NSString *name = [self.nameField.text trimString];
    //    sexIndex
    NSString *phone = [self.phoneField.text trimString];
    //    isNotDriving
    NSString *  visitTime=[[PublicClass sharedManager] getNowTimeWithFormat:@"yyyyMMDDHHmm"];
    if (([name isEmptyString])) {
          [self.view makeToast:@"请正确输入您的姓名" duration:1.2f position:@"center"];
        return NO;
    }
    NSString *qrcode =  [NSString stringWithFormat:@"name:%@&#sex:%d&#phone:%@&#isDrive:%d&#visitTime:%@&#communityName:%@",name,sexIndex,phone,isNotDriving,visitTime,[[Config Instance] getCommunityName]];
    qrcode = [DES3Util encrypt:qrcode];
    visitorQrcode = [[VisitorQrcode alloc] init];
    visitorQrcode.qrcodeStr = qrcode;
    visitorQrcode.name = name;
    visitorQrcode.phone = phone;
    visitorQrcode.isDrive =isNotDriving;
    visitorQrcode.communityName = [[Config Instance] getCommunityName];
    visitorQrcode.sex = sexIndex;

    return YES;
}
- (IBAction)jumpAction:(id)sender {
    
//    QrcodeInfoVC *qrcodeInfoVC=   [self.storyboard instantiateViewControllerWithIdentifier:@"QrcodeInfoVC"];
    NSString *name = [self.nameField.text trimString];
    //    sexIndex
    NSString *phone = [self.phoneField.text trimString];
    //    isNotDriving
    NSString *  visitTime=[[PublicClass sharedManager] getNowTimeWithFormat:@"yyyyMMDDHHmm"];
    if (([name isEmptyString])) {
            [self.view makeToast:@"请正确输入您的姓名" duration:1.2f position:@"center"];
        return ;
    }
//    NSString *qrcode =  [NSString stringWithFormat:@"name:%@&#sex:%d&#phone:%@&#isDrive:%d&#visitTime:%@&#communityName:%@",name,sexIndex,phone,isNotDriving,visitTime,[[Config Instance] getCommunityName]];
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
        NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                  
                                    phone,@"phone",
                                    [NSString stringWithFormat:@"%d",isNotDriving],@"isDrive",
                                    name,@"name",
                                    [NSString stringWithFormat:@"%d",sexIndex],@"sex",
                   nil];
    
        [manager POST:API_BASE_URL_STRING(URL_ADDVISITORCARD) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dictionary= responseObject;
            if (dictionary) {
                if (Y_Code_Success== [dictionary[Y_Code] intValue]) {
                    NSLog(@"创建成功");
                    NSArray *viewControllers=[self.navigationController viewControllers];
                    VisitorTableVC *controller=[viewControllers objectAtIndex:1];
                    controller.isBack = YES;
                    [self.navigationController popToViewController:controller animated:YES];
//                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            NSLog(@"%@",dictionary[Y_Message]);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",[error localizedDescription]);
            [MBProgressHUD showError:@"添加失败"];
        }];

    
//    [self.navigationController pushViewController:qrcodeInfoVC animated:YES];

}

-(void)addVisitorCardWithQrcode:(NSString *)qrcode{
//    NSLog(@"name:%@", self.visitorQrcode.name);
//    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:qrcode,@"qrcode",self.visitorQrcode.phone,@"phone",[NSString stringWithFormat:@"%d",self.visitorQrcode.isDrive],@"isDrive",self.visitorQrcode.name,@"name",[NSString stringWithFormat:@"%d",self.visitorQrcode.sex],@"sex",nil];
    
//    [manager POST:API_BASE_URL_STRING(URL_ADDVISITORCARD) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *dictionary= responseObject;
//        if (dictionary) {
//            int  code = [dictionary[Y_Code] intValue];
//            if (1==code) {
//                NSLog(@"创建成功");
//            }
//        }
//        NSLog(@"%@",dictionary[Y_Message]);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@",[error localizedDescription]);
//        [MBProgressHUD showError:@"添加失败"];
//    }];
}

//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    QrcodeInfoVC *qrcodeInfoVC= segue.destinationViewController;
    qrcodeInfoVC.visitorQrcode =visitorQrcode;
}
- (IBAction)switchSexAction:(UISegmentedControl *)sender {
    sexIndex = self.switchSex.selectedSegmentIndex==0?1:2;
    NSLog(@"%d",sexIndex);
}
@end
