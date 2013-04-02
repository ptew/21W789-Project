//
//  BrowseEventsViewController.m
//  Pipeline
//
//  Created by Jono Matthews on 4/1/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "BrowseEventsViewController.h"
#import "NewEventViewController.h"

@interface BrowseEventsViewController ()

@end

@implementation BrowseEventsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.events = [[NSMutableArray alloc] initWithObjects:@"Party 1", @"Another party", nil];
    self.title = @"Events Near You";
    
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addEvent)];
    
    self.navigationItem.rightBarButtonItem = self.addButton;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                             style:UIBarButtonItemStyleBordered
                                                            target:nil
                                                                            action:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)addEvent {
    NewEventViewController *newView = [[NewEventViewController alloc] init];
    
    UINavigationController *parent = (UINavigationController*)[self parentViewController];
    [parent pushViewController:newView animated:TRUE];
}
@end
