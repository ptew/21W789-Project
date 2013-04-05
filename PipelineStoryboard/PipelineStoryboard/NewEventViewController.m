//
//  NewEventViewController.m
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/1/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "NewEventViewController.h"
#import "UsersViewController.h"
#import "ActivityViewController.h"

@interface NewEventViewController ()
- (IBAction)makeEvent:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
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
    [self.nameField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameField) {
        [textField resignFirstResponder];
        [self.passwordField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return TRUE;
}

- (void) eventCreated {
    [self dismissViewControllerAnimated:NO completion:NULL];
    [[GroupQEvent sharedEvent] broadcastEvent];
    [self performSegueWithIdentifier:@"createEvent" sender:@"self"];
}

- (void) eventNotCreated {
    [self dismissViewControllerAnimated:NO completion:NULL];
}

- (void) userUpdate {
    
}

- (void) newTextAvailable:(NSString *)message from:(GroupQConnection *)connection {
    
}

- (void) eventEnded {
    
}

- (IBAction)makeEvent:(UIBarButtonItem *)sender {
    ActivityViewController *creatingActivity = [[ActivityViewController alloc] initWithActivityText:[NSString stringWithFormat:@"creating %@", self.nameField.text]];
    [self presentViewController:creatingActivity animated:NO completion:NULL];
    [[GroupQEvent sharedEvent] setDelegate: self];
    [[GroupQEvent sharedEvent] createEventWithName:self.nameField.text];
}
@end
