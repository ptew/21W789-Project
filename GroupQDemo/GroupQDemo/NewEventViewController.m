//
//  NewEventViewController.m
//  GroupQDemo
//
//  Created by Jono Matthews on 4/6/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "NewEventViewController.h"

@interface NewEventViewController ()
@property (weak, nonatomic) IBOutlet UITextField *eventName;
@property (weak, nonatomic) IBOutlet UITextField *eventPassword;
@property (strong, nonatomic) SpotifyConnection *loginConnection;
@property (strong, nonatomic) SPLoginViewController *spLoginController;
- (IBAction)createEvent:(UIBarButtonItem *)sender;

@end

@implementation NewEventViewController

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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 1) {
        //********************
        // LOG IN TO SPOTIFY
        //********************
        self.loginConnection = [[SpotifyConnection alloc] initWithParent:self];
        [self.loginConnection setDelegate:self];
        [self.loginConnection connect];
        [self performSelector:@selector(showSpotifyLogin) withObject:nil afterDelay:0.0];
    }
}

- (void) showSpotifyLogin {
    self.spLoginController = [self.loginConnection getLoginScreen];
    [self presentViewController:self.spLoginController animated:NO completion:NULL];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.eventName) {
        [self.eventPassword becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return TRUE;
}

- (IBAction)createEvent:(UIBarButtonItem *)sender {
    ActivityViewController *creatingActivity = [[ActivityViewController alloc] initWithActivityText:[NSString stringWithFormat:@"creating %@", self.eventName.text]];
    [self presentViewController:creatingActivity animated:NO completion:NULL];
    [[GroupQEvent sharedEvent] setDelegate: self];
    [[GroupQEvent sharedEvent] createEventWithName:self.eventName.text andPassword:self.eventPassword.text];
}

#pragma mark - Spotify Connection delegate methods

- (void)loggedInToSpotifySuccessfully{
    [self.spotifyConnectedLabel setText:@"Connected"];
    self.spotifyConnectedLabel.textColor = [UIColor blackColor];
    self.connectedLabelCell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.spotifyLoginButton.userInteractionEnabled = false;
    self.spotifyLoginLabel.textColor = [UIColor grayColor];
    [[GroupQEvent sharedEvent] setSpotify:true];
}
- (void)loggedOutOfSpotify{
    [self.spotifyConnectedLabel setText:@"Not Connected"];
    self.spotifyConnectedLabel.textColor = [UIColor grayColor];
    self.connectedLabelCell.accessoryType = UITableViewCellAccessoryNone;
    self.spotifyLoginButton.userInteractionEnabled = true;
    self.spotifyLoginLabel.textColor = [UIColor blackColor];
    [[GroupQEvent sharedEvent] setSpotify:false];
}

- (void)failedToLoginToSpotifyWithError:(NSError*)error{
    NSLog(@"A spotify login error occored");
}

#pragma mark - GroupQEvent delegate methods
- (void) eventCreated {}

- (void) eventNotCreated {
    [self dismissViewControllerAnimated:NO completion:NULL];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Join" message:@"Could not create event." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void) receivedMessage:(NSString *)message withHeader:(NSString *)header from:(GroupQConnection *)connection {}
- (void) receivedObject:(NSData *)object withHeader:(NSString *)header from:(GroupQConnection *)connection{}
- (void) userUpdate{}
- (void) eventEnded{}

- (void) eventsUpdated {}
- (void) didConnectToEvent{
    [self dismissViewControllerAnimated:NO completion:NULL];
    [self performSegueWithIdentifier:@"createEvent" sender:@"self"];
}
- (void) didNotConnectToEvent{
    [self eventNotCreated];
}
- (void) disconnectedFromEvent{}
@end
