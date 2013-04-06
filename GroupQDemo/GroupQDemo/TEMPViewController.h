//
//  TEMPViewController.h
//  GroupQDemo
//
//  Created by Jono Matthews on 4/6/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TEMPViewController : UIViewController <UITextFieldDelegate>
- (IBAction)doSearchButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
