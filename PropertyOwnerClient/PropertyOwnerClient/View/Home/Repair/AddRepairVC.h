//
//  AddRepairVC.h
//  PropertyOwnerClient
//
//  Created by MoPellet on 15/6/1.
//  Copyright (c) 2015年 neo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceholderTextView.h"
@interface AddRepairVC : UIViewController
{
    NSMutableArray *addedPicArray;
}
@property (weak, nonatomic) IBOutlet UITextField *repairTitle;
@property (weak, nonatomic) IBOutlet UITextField *startTime;
@property (weak, nonatomic) IBOutlet UITextField *endTime;
//@property (weak, nonatomic) IBOutlet UITextField *desc;

@property (weak, nonatomic) IBOutlet UIPlaceholderTextView *desc;

@property (retain, nonatomic) IBOutlet UIScrollView *picScroller;
@property (retain, nonatomic) IBOutlet UIButton *plusButton;
- (IBAction)addPic:(id)sender;
- (IBAction)submit:(id)sender;
@end
