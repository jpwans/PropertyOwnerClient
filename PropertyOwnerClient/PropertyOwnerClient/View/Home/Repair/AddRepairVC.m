//
//  AddRepairVC.m
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/6/1.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import "AddRepairVC.h"
#define  PIC_WIDTH 80
#define  PIC_HEIGHT 80
#define  INSETS 10
#define timeFormatter @"yyyy-MM-dd HH:mm"
@interface AddRepairVC ()<UIActionSheetDelegate,UIPickerViewDelegate,UINavigationControllerDelegate,UITextViewDelegate>
{
    UIPickerView *pickView;
    NSDate *startDate;
    NSDate *endDate;
     CGPoint _plusButtonPoint;
}
@end

@implementation AddRepairVC
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [ _desc addObserver];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [ _desc removeobserver];
}
- (void)viewDidLoad {
    [super viewDidLoad];
         _plusButtonPoint = [_plusButton center ];
    addedPicArray =[[NSMutableArray alloc]init];
    [self refreshScrollView];
    _desc.placeholder = @"请输入详细描述！";
    

    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, _repairTitle.frame.size.height - 1, SCREEN_WIDTH, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:227.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0].CGColor;
    [_repairTitle.layer addSublayer:bottomBorder];

    
    
    UIDatePicker * startPicker = [[UIDatePicker alloc] init];
    //    startPicker.datePickerMode = UIDatePickerModeDate;
    startPicker.datePickerMode = UIDatePickerModeDateAndTime;
    startPicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    self.startTime.inputView  = startPicker;
    [startPicker addTarget:self action:@selector(startPickerValueChanged:) forControlEvents:UIControlEventValueChanged];

    
    _desc.layer.borderColor =  [UIColor colorWithRed:227.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0].CGColor;
    _desc.layer.borderWidth = 1;
    _desc.layer.cornerRadius = 6;
    _desc.layer.masksToBounds = YES;
    
    UIDatePicker * endPicker = [[UIDatePicker alloc] init];
    endPicker.datePickerMode = UIDatePickerModeTime;
    endPicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    self.endTime.inputView  = endPicker;
    [endPicker addTarget:self action:@selector(endPickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchDownToKeyboard:)];
    [self.view addGestureRecognizer:tap];
 _desc.delegate =self;
}


- (void)touchDownToKeyboard:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [self animateTextView: textView up: YES];
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [self animateTextView: textView up: NO];
    return YES;
}

- (void) animateTextView: (UITextView *) textView up: (BOOL) up
{
    const int movementDistance = 216; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    
    [UIView commitAnimations];
    
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.startTime resignFirstResponder];
    [self.endTime resignFirstResponder];
}

-(void)startPickerValueChanged:(UIDatePicker *)picker{
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init] ;
    [dateformatter setDateFormat:timeFormatter];
    self.startTime.text =  [dateformatter stringFromDate:picker.date];
    startDate =picker.date;
}

-(void)endPickerValueChanged:(UIDatePicker *)picker{
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc]init] ;
    [dateformatter setDateFormat:@"HH:mm"];
    if (_startTime.text.length<=0) {
                 [self.view makeToast:@"请先选择开始时间" duration:1.5f position:@"center"];
        return;
    }
    NSString *today = [_startTime.text substringToIndex:11];
    NSString *date =[dateformatter stringFromDate:picker.date];
    self.endTime.text =  [NSString stringWithFormat:@"%@%@",today,date];
    [dateformatter setDateFormat:timeFormatter];
    endDate = [dateformatter dateFromString:_endTime.text];
}


-(int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:timeFormatter];
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    NSLog(@"date1 : %@, date2 : %@", oneDay, anotherDay);
    if (result == NSOrderedDescending) {
        NSLog(@"开始时间大于结束时间");
        return 1;
    }
    else if (result == NSOrderedAscending){
        NSLog(@"开始时间小于结束时间");
        return -1;
    }
    NSLog(@"两个时间相同");
    return 0;
    
}

- (void)refreshScrollView
{
    CGFloat width=100*(addedPicArray.count)<300?320:100+addedPicArray.count*90;
    
    CGSize contentSize=CGSizeMake(width, 100);
//    [_picScroller setContentSize:contentSize];
//    [_picScroller setContentOffset:CGPointMake(width<320?0:width-320, 0) animated:YES];
//    
}
- (IBAction)addPic:(id)sender {
    if (addedPicArray.count==3) {
        [self.view makeToast:@"最多选择三张照片！" duration:1.5f position:@"center"];
        return;
    }
    // 让用户选择照片来源
    // * 用相机作为暗示按钮可以获取到更多的真实有效的照片
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"选择照片", nil];
    
    [sheet showFromTabBar:self.tabBarController.tabBar];
}


- (IBAction)submit:(id)sender{
    if (0==self.endTime.text.length) {
        [self.view makeToast:@"结束时间不能为空" duration:1.5f position:@"center"];
        return;
    }else if (0==self.repairTitle.text.length){
        [self.view makeToast:@"活动地点不能为空" duration:1.5f position:@"center"];
        return;
    }
    else if (0==self.desc.text.length){
        [self.view makeToast:@"详情描述不能为空" duration:1.5f position:@"center"];
        return;
    }
    
    int  i =     [self compareOneDay:startDate withAnotherDay:endDate];
    if (i!=-1) {
        [self.view makeToast:@"请检查时间是否正确" duration:1.5f position:@"center"];
        return;
    }
    if (0==addedPicArray.count) {
        [self.view makeToast:@"请添加一张照片!" duration:1.5f position:@"center"];
        return;
    }
    AFHTTPRequestOperationManager *manager = [RestClient getAFHTTPRequestOperationManagerPutheaderPost];
    if (addedPicArray.count) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSMutableString *photoKey = [[NSMutableString alloc] init];
        [[PublicClass sharedManager] getTokenWithCompletionHandler:^(NSDictionary *dictionary, NSError *error) {
            if (!error) {
                if (dictionary[Y_Data]) {
                    QNUploadManager *upManager = [[QNUploadManager alloc] init];
                    for (int i = 0; i<addedPicArray.count; i++) {
                        UIImageView *imageView =   addedPicArray[i];
                        NSData *imgData = UIImageJPEGRepresentation(imageView.image, 1.0);
                        NSString *keys = [NSString stringWithFormat:@"%d", (int)[NSDate timeIntervalSinceReferenceDate]+i];
                        [upManager putData:imgData key:keys token:dictionary[Y_Data]
                                  complete: ^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                                      [photoKey appendFormat:@"%@&#",key];
                                      int temp = (int) addedPicArray.count-1;//不然只能添加一张图片
                                      if (i==temp) {
                                          NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                      self.desc.text,@"description",
                                                                      self.startTime.text,@"hopeStart",
                                                                      self.endTime.text,@"hopeEnd",
                                                                      self.repairTitle.text ,@"title",
                                                                      [[Config Instance] getRoomId],@"roomId",
                                                                      photoKey,@"photo",nil];
                                          NSLog(@"part:%@",parameters);
                                          [manager POST:API_BASE_URL_STRING(URL_ADDREPAIR) parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              NSDictionary *dictionary= responseObject;
                                              NSLog(@"添加报修：%@",dictionary);
                                              if (dictionary) {
                                                  NSLog(@"%@",dictionary[Y_Message]);
                                                  int code  =[dictionary[Y_Code] intValue];
                                                  if (1==code) {
                                                      //添加成功跳转
                                         [self.navigationController popViewControllerAnimated:YES];
                                              
                                                      
                                                  }
                                                  [self.view makeToast:dictionary[Y_Message] duration:1.8f position:@"center"];
                                                  [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                              }
                                              
                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              NSLog(@"error:%@",[error localizedDescription]);
                                          }];
                                      }
                                  } option:nil];
                    }
                    
                }
            }
        }];
    }
    
}
#pragma mark - ActionSheet代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 2) {
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    // 1. 设置照片源，提示在模拟上不支持相机！
    if (buttonIndex == 0) {
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else {
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    // 2. 允许编辑
    [picker setAllowsEditing:YES];
    // 3. 设置代理
    [picker setDelegate:self];
    // 4. 显示照片选择控制器
    [self presentViewController:picker animated:YES completion:nil];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"";
    viewController.navigationItem.backBarButtonItem = backItem;
    
}
#pragma mark - 照片选择代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    //添加图片
    UIImageView *aImageView=[[UIImageView alloc]initWithImage: info[UIImagePickerControllerEditedImage]];
    [aImageView setFrame:CGRectMake(INSETS-90, INSETS, PIC_WIDTH, PIC_HEIGHT)];
    [addedPicArray addObject:aImageView];
    [_picScroller addSubview:aImageView];
    
    for (UIImageView *img in addedPicArray) {
        
        CABasicAnimation *positionAnim=[CABasicAnimation animationWithKeyPath:@"position"];
        [positionAnim setFromValue:[NSValue valueWithCGPoint:CGPointMake(img.center.x, img.center.y)]];
        [positionAnim setToValue:[NSValue valueWithCGPoint:CGPointMake(img.center.x+INSETS+PIC_WIDTH, img.center.y)]];
        [positionAnim setDelegate:self];
        [positionAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [positionAnim setDuration:0.25f];
        [img.layer addAnimation:positionAnim forKey:nil];
        
        [img setCenter:CGPointMake(img.center.x+INSETS+PIC_WIDTH, img.center.y)];
    }
    
    [self refreshScrollView];
    //移动添加按钮
        dispatch_async(dispatch_get_main_queue(), ^{
//    CABasicAnimation *positionAnim=[CABasicAnimation animationWithKeyPath:@"position"];
//    [positionAnim setFromValue:[NSValue valueWithCGPoint:CGPointMake(_plusButton.center.x, _plusButton.center.y)]];
//    [positionAnim setToValue:[NSValue valueWithCGPoint:CGPointMake(_plusButton.center.x+INSETS+PIC_WIDTH, _plusButton.center.y)]];
//    [positionAnim setDelegate:self];
//    [positionAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//    [positionAnim setDuration:0.25f];
//    [_plusButton.layer addAnimation:positionAnim forKey:nil];
//    [_plusButton setCenter:CGPointMake(_plusButton.center.x+INSETS+PIC_WIDTH, _plusButton.center.y)];
            _plusButtonPoint.x = _plusButtonPoint.x + INSETS+PIC_WIDTH;
            _plusButton.center =_plusButtonPoint;
        });
    // 3. 关闭照片选择器
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
