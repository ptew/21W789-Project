//
//  SpotifyConnection.m
//  SpotifyProofOfConcept
//
//  Created by Bradley Gross on 4/4/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import "SpotifyConnection.h"

@implementation SpotifyConnection

- (SpotifyConnection *) initWithParent: (UIViewController *) who {
    self = [super init];
    self.parent = who;
    return self;
}

- (void) connect {
    [[SPSession sharedSession] setDelegate:self];
}

- (SPLoginViewController *) getLoginScreen {
    SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
    if (controller == nil)
        NSLog(@"Could not create login controller");
    controller.edgesForExtendedLayout = UIRectEdgeNone;
    controller.extendedLayoutIncludesOpaqueBars=NO;
    controller.automaticallyAdjustsScrollViewInsets=NO;
    for (UIViewController* childViewController in controller.childViewControllers) {
        childViewController.edgesForExtendedLayout = UIRectEdgeNone;
        childViewController.extendedLayoutIncludesOpaqueBars=NO;
        childViewController.automaticallyAdjustsScrollViewInsets=NO;
    }
    return controller;
}

-(UIViewController *)viewControllerToPresentLoginViewForSession:(SPSession *)aSession {
	return self.parent;
}

#pragma mark SPSession Delegate Methods

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
    [self.delegate loggedInToSpotifySuccessfully];
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error; {
	[self.delegate failedToLoginToSpotifyWithError:error];
}

-(void)sessionDidLogOut:(SPSession *)aSession {
	
	SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
	
	if (self.parent.presentedViewController != nil) return;
	
	controller.allowsCancel = NO;
	
	[self.parent presentViewController:controller
											   animated:YES completion:NULL];
    [self.delegate loggedOutOfSpotify];
}

-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error; {}
-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {}
-(void)sessionDidChangeMetadata:(SPSession *)aSession; {}

-(void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage; {
	return;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
													message:aMessage
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}
@end
