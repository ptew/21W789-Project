//
//  SpotifyConnection.m
//  SpotifyProofOfConcept
//
//  Created by T. S. Cobb on 4/4/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import "SpotifyConnection.h"
#include "appkey.c"

@implementation SpotifyConnection

- (SpotifyConnection *) initWithParent: (UIViewController *) who {
    self = [super init];
    self.parent = who;
    return self;
}

- (void) connect {
    NSError *error = nil;
    [SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size]
											   userAgent:@"com.spotify.SimplePlayer-iOS"
										   loadingPolicy:SPAsyncLoadingManual
												   error:&error];
    if (error != nil) {
		NSLog(@"CocoaLibSpotify init failed: %@", error);
		abort();
	}
    [[SPSession sharedSession] setDelegate:self];
}

- (SPLoginViewController *) getLoginScreen {
    SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
    if (controller == nil)
        NSLog(@"Could not create login controller");
    return controller;
}

-(UIViewController *)viewControllerToPresentLoginViewForSession:(SPSession *)aSession {
	return self.parent;
}

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
