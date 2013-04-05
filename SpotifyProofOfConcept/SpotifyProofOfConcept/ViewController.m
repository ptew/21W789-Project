//
//  ViewController.m
//  SpotifyProofOfConcept
//
//  Created by T. S. Cobb on 4/4/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import "ViewController.h"
#import "SpotifyConnection.h"

@interface ViewController ()
@property (strong, nonatomic) SpotifyConnection* spotifyConnection;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.spotifyConnection = [[SpotifyConnection alloc] initWithParent:self];
    [self.spotifyConnection connect];
	[self performSelector:@selector(showLogin) withObject:nil afterDelay:0.0];
    
    self.spotifyPlayer = [[SpotifyPlayer alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)showLogin {
    NSLog(@"Stuff: %@", [((UIWindow*)[[[UIApplication sharedApplication] windows] objectAtIndex:0]) rootViewController]);
    SPLoginViewController *loginController = [self.spotifyConnection getLoginScreen];
    [self presentViewController:loginController animated:NO completion:NULL];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return true;
}

- (IBAction)submitButton:(UIButton *)sender {
    NSLog(self.inputText1.text);
    NSLog(self.inputText2.text);
}

- (IBAction)playButton:(UIButton *)sender {
    NSURL *inputTrack;
    inputTrack = [[NSURL alloc] initWithString:self.inputText1.text];
    [self.spotifyPlayer playTrack:inputTrack];
}

- (IBAction)searchButton:(UIButton *)sender {
    
}
@end
