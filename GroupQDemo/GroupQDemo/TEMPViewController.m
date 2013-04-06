//
//  TEMPViewController.m
//  GroupQDemo
//
//  Created by Jono Matthews on 4/6/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "TEMPViewController.h"

@interface TEMPViewController ()

@end

@implementation TEMPViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doSearchButtonPressed:(UIButton *)sender {
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
}
@end
