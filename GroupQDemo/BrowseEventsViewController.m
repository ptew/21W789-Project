//
//  BrowseEventsViewController.m
//  GroupQDemo
//
//  Created by Jono Matthews on 4/6/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "BrowseEventsViewController.h"

@interface BrowseEventsViewController ()

// The table displaying the events nearby
@property (strong, nonatomic) IBOutlet UITableView *tableView;

// List of events and the current event to join (while the action sheet is up)
@property (strong, nonatomic) NSArray *events;
@property (strong, nonatomic) NSNetService *eventToJoin;

// Images to display on screen
@property (strong, nonatomic) UIImage *lockedImage;
@property (strong, nonatomic) UIImage *openImage;

- (void) attemptToJoinEventAsDJ: (BOOL) dj;
- (void) joinEvent;
@end

@implementation BrowseEventsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Display an activity indicator
    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:ai];
    [ai startAnimating];
    self.navigationItem.backBarButtonItem.title = @"Cancel";
    
    self.lockedImage = [UIImage imageNamed:@"Lock"];
    self.openImage = [UIImage imageNamed:@"NoLock"];
    
    // Start searching for events
    [[GroupQClient sharedClient] setDelegate:self];
    [[GroupQClient sharedClient] startSearchingForEvents];
}



#pragma mark - Management of Events list

- (void) eventsUpdated
{
    self.events = [[GroupQClient sharedClient] getEvents];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *eventInfo = [[self.events objectAtIndex:indexPath.row] name];
    if ([self getPassword:eventInfo] == nil) {
        cell.imageView.image = self.openImage;
    }
    else {
        cell.imageView.image = self.lockedImage;
    }
    cell.textLabel.text = [self getName:eventInfo];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.eventToJoin = [self.events objectAtIndex:indexPath.row];
    
    UIActionSheet *djOrListenerPrompt;
    if ([self getPassword:[self.eventToJoin name]] == nil) {
        djOrListenerPrompt = [[UIActionSheet alloc] initWithTitle:@"Join As..." delegate:self cancelButtonTitle: @"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"DJ", @"Listener", nil];
    }
    else {
        djOrListenerPrompt = [[UIActionSheet alloc] initWithTitle:@"Join As..." delegate:self cancelButtonTitle: @"Cancel" destructiveButtonTitle:@"DJ" otherButtonTitles:@"Listener", nil];
    }
    
    [djOrListenerPrompt showInView:self.view];
}


#pragma mark - Joining events

- (void) attemptToJoinEventAsDJ:(BOOL)dj {
    if(dj) {
        if ([self getPassword:[self.eventToJoin name]] == nil) {
            // If there's no password, join right away
            [self joinEvent];
        }
        else {
            // Prompt for password
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Password Required" message:@"To DJ this event, you must enter the correct password." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Go!", nil];
            alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
            [alert show];
        }
    }
    else {
        // Listeners can always join
        [self joinEvent];
    }
}

- (void) joinEvent {
    ActivityViewController *activityCont = [[ActivityViewController alloc] initWithActivityText:[NSString stringWithFormat:@"joining %@", [self getName:self.eventToJoin.name]]];
    [self presentViewController:activityCont animated:NO completion:^{}];
    [[GroupQClient sharedClient] stopSearching];
    [[GroupQClient sharedClient] connectToEvent:self.eventToJoin];
}

- (void) didConnectToEvent {}

- (void) didNotConnectToEvent {
    [self dismissViewControllerAnimated:NO completion:NULL];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Join" message:[NSString stringWithFormat:@"Could not join %@.", self.eventToJoin.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [[GroupQClient sharedClient] startSearchingForEvents];
}

- (void) initialInformationReceived {
    [self dismissViewControllerAnimated:NO completion:NULL];
    [self performSegueWithIdentifier:@"joinEvent" sender:self];
}


- (void) receivedObject:(NSData *)object withHeader:(NSString *)header{}
- (void) receivedMessage:(NSString *)message withHeader:(NSString *)header{}
- (void) playbackDetailsReceived{}
- (void) spotifyInfoReceived{}
- (void) disconnectedFromEvent{[self didNotConnectToEvent];}

#pragma mark - Action sheet delegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"DJ"]) {
        [[GroupQClient sharedClient] setDJ:YES];
        [self attemptToJoinEventAsDJ:TRUE];
    }
    else if ([buttonTitle isEqualToString:@"Listener"]) {
        [[GroupQClient sharedClient] setDJ:NO];
        [self attemptToJoinEventAsDJ:FALSE];
    }
}

#pragma mark - Alert box delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Go!"]) {
        NSString *enteredPassword = [[alertView textFieldAtIndex:0] text];
        if ([enteredPassword isEqualToString:[self getPassword:self.eventToJoin.name]]) {
            [self joinEvent];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incorrect Password" message:[NSString stringWithFormat:@"Could not join %@. Incorrect password.", self.eventToJoin.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
}

#pragma mark - Helper methods
- (NSString *) getPassword: (NSString*) eventInfo {
    NSArray* components = [eventInfo componentsSeparatedByString:@"\n"];
    if (![[components objectAtIndex:1] isEqualToString:@""]) {
        return [components objectAtIndex:1];
    }
    return nil;
}

- (NSString *) getName: (NSString *) eventInfo {
    NSString* name = [[eventInfo componentsSeparatedByString:@"\n"] objectAtIndex:0];
    return name;
}
@end
