//
//  InEventViewController.m
//  PipelineStoryboard
//
//  Created by Jono Matthews on 4/3/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "InEventViewController.h"
#import "BrowseEventsViewController.h"
#import <QuartzCore/QuartzCore.h>
@interface InEventViewController ()
@property (weak, nonatomic) IBOutlet UITextView *messagesView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
- (IBAction)leaveEvent:(UIBarButtonItem *)sender;
@end

@implementation InEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [[GroupQClient sharedClient] eventName];
    self.messagesView.layer.borderWidth = 5.0f;
    self.messagesView.layer.borderColor = [[UIColor grayColor] CGColor];
    [self.textField becomeFirstResponder];
}

- (IBAction)leaveEvent:(UIBarButtonItem *)sender {
    NSArray *controllers = ([(UINavigationController *)[self parentViewController] viewControllers] );
    BrowseEventsViewController *dest = (BrowseEventsViewController *)[controllers objectAtIndex:controllers.count-2];
    [(UINavigationController *)[self parentViewController] popViewControllerAnimated:TRUE];
    [[GroupQClient sharedClient] disconnect];
    [[GroupQClient sharedClient] setDelegate:dest];
    [[GroupQClient sharedClient] startSearchingForEvents];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [[GroupQClient sharedClient] sendText:textField.text];
    textField.text = @"";
    return TRUE;
}

- (void) didConnectToEvent {
    
}

- (void) disconnectedFromEvent {
    [self leaveEvent:nil];
}

- (void) didNotConnectToEvent {
}

- (void) eventsUpdated {    
}

- (void) newTextAvailable:(NSString *)newText {
    self.messagesView.text = [NSString stringWithFormat:@"%@%@\n", self.messagesView.text, newText];
    [self.messagesView scrollRangeToVisible:NSMakeRange(self.messagesView.text.length-1, 1)];
}
@end
