//
//  ViewController.m
//  Spotify Proof of Concept
//
//  Created by T. S. Cobb on 4/3/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Track:(UITextField *)sender forEvent:(UIEvent *)event {
}

- (IBAction)Accept:(UIButton *)sender {
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return TRUE;
}
@end
