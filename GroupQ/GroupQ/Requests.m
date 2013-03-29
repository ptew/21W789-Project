//
//  SecondViewController.m
//  GroupQ
//
//  Created by Parker Allen Tew on 3/28/13.
//  Copyright (c) 2013 Parker Allen Tew. All rights reserved.
//

#import "Requests.h"

@interface Requests ()

@end

@implementation Requests

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Requests", @"Requests");
        self.tabBarItem.image = [UIImage imageNamed:@"request-icon.gif"];
    }
    return self;
}
							
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

@end
