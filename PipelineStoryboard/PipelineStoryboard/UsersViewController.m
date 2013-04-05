//
//  UsersViewController.m
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/1/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "UsersViewController.h"

@interface UsersViewController ()


- (IBAction)endEvent:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UITableView *userTable;
@property (strong, nonatomic) NSMutableArray *lines;
@end

@implementation UsersViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.lines = [[NSMutableArray alloc] init];
    [[GroupQEvent sharedEvent] setDelegate:self];
    self.navigationItem.title = [[GroupQEvent sharedEvent] eventName];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return self.lines.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [self.lines objectAtIndex:indexPath.row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Received Messages";
    }
    return @"";
}

- (void) eventCreated {
    
}

- (void) eventNotCreated {
    
}

- (void) eventEnded {
    [((UINavigationController *)self.parentViewController) popViewControllerAnimated:YES];
}

- (void) userUpdate {
    
}

- (void) receivedMessage:(NSString *)message withHeader:(NSString *)header from:(GroupQConnection *)connection {
    [[GroupQEvent sharedEvent] broadcastMessage:message withHeader:header];
    [self.lines addObject:message];
    [self.tableView reloadData];
}


- (void) receivedObject:(NSData *)object withHeader:(NSString *)header from:(GroupQConnection *)connection {
}

- (IBAction)endEvent:(UIBarButtonItem *)sender {
    [((UINavigationController *)self.parentViewController) popViewControllerAnimated:YES];
    [[GroupQEvent sharedEvent] endEvent];
}
@end
