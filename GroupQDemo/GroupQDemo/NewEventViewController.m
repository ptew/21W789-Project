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
        SpotifyConnection *connection = [[SpotifyConnection alloc] initWithParent:self];
        [connection connect];
        SPLoginViewController *loginController = [connection getLoginScreen];
        [self presentViewController:loginController animated:NO completion:NULL];
        //need to fire some event to show that spotify has logged in.
        //use the loginviewcontrollerdelegate to do this future brad. I hope last night was fun.
        //If she was ugly just own up to it in chapter, no shame.
        
    }
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

#pragma mark - GroupQEvent delegate methods
- (void) eventCreated {
    [self dismissViewControllerAnimated:NO completion:NULL];
    [[GroupQEvent sharedEvent] broadcastEvent];
    [self performSegueWithIdentifier:@"createEvent" sender:@"self"];
}

- (void) eventNotCreated {
    [self dismissViewControllerAnimated:NO completion:NULL];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Join" message:@"Could not create event." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void) receivedMessage:(NSString *)message withHeader:(NSString *)header from:(GroupQConnection *)connection {}
- (void) receivedObject:(NSData *)object withHeader:(NSString *)header from:(GroupQConnection *)connection{}
- (void) userUpdate{}
- (void) eventEnded{}

@end
