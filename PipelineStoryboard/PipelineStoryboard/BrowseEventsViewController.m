//
//  ViewController.m
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/1/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "BrowseEventsViewController.h"

@interface BrowseEventsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *eventsTable;  // We need to update the events table
@property (strong, nonatomic) NSArray *events;                  // The list of events
@property (weak, nonatomic) NSNetService *eventToJoin;          // The event we are about to join
@property (strong, nonatomic) UIView *connectingView;
@end

@implementation BrowseEventsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Start the spinner
    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:ai];
    [ai startAnimating];
    
    // Initialize some values
    self.events = [[NSArray alloc] init];
    
    // Start searching for events.
    [[GroupQClient sharedClient] setDelegate:self];
    [[GroupQClient sharedClient] startSearchingForEvents];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"joinEvent"]) {
        InEventViewController *dest = (InEventViewController *) segue.destinationViewController;
        [[GroupQClient sharedClient] setDelegate: dest];
    }
}

#pragma mark GroupQClient Delegate Methods
- (void) eventsUpdated {
    self.events = [[GroupQClient sharedClient] getEvents];
    
    NSLog(@"Events updated. Number of events: %d", [self.events count]);
    [self.tableView reloadData];
}

- (void) didConnectToEvent {
    [self dismissViewControllerAnimated:NO completion:NULL];
    [self performSegueWithIdentifier:@"joinEvent" sender:self];
}

- (void) didNotConnectToEvent {
    [self dismissViewControllerAnimated:NO completion:NULL];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Join" message:[NSString stringWithFormat:@"Could not join %@.", self.eventToJoin.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [[GroupQClient sharedClient] startSearchingForEvents];
}

- (void) disconnectedFromEvent {
}

- (void) newTextAvailable:(NSString *)newText {
}

#pragma mark UITableView Delegate Methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return self.events.count;
    return 0;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [(NSNetService *)[self.events objectAtIndex:indexPath.row] name];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIActionSheet *djOrListenerPrompt = [[UIActionSheet alloc] initWithTitle:@"Join As..." delegate:self cancelButtonTitle: @"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"DJ", @"Listener", nil];
    [djOrListenerPrompt showInView:self.view];
    self.eventToJoin = (NSNetService*)[self.events objectAtIndex:indexPath.row];
}

#pragma mark UIActionSheet Delegate Methods
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    /*NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"DJ"])
        NSLog(@"Join as DJ.");
    else if ([buttonTitle isEqualToString:@"Listener"])
        NSLog(@"Join as Listener.");*/
    [self joinEvent: self.eventToJoin];
}

#pragma mark Utility Methods
- (void) joinEvent: (NSNetService* )event {
    ActivityViewController *activityCont = [[ActivityViewController alloc] initWithActivityText:[NSString stringWithFormat:@"joining %@", event.name]];
    [self presentViewController:activityCont animated:NO completion:^{}];
    [[GroupQClient sharedClient] stopSearching];
    [[GroupQClient sharedClient] connectToEvent:event];
}

@end
