//
//  SpotifyConnection.h
//  SpotifyProofOfConcept
//
//  Created by Bradley Gross on 4/4/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLibSpotify.h>
#import "SpotifyConnectionDelegate.h"

/*
 This class handles the login and logout actions when logging into spotify.
 
 */
@interface SpotifyConnection : NSObject <SPSessionDelegate>

@property (weak, nonatomic) UIViewController *parent;

/*
 This Delegate fires the events related to logging in and out of spotify. Also it handles
 log in log out errors.
 */
@property (strong, nonatomic) id<SpotifyConnectionDelegate> delegate;

- (SpotifyConnection *) initWithParent: (UIViewController *) who;

/*
 Loads the spotify login view and handle's authenticating the SPSession. The login information
 is handled by spotify and the user name/ password are never touched by this library.
 */
- (void) connect;

/*
 retrieves the login screen from the SPLoginController to be displayed. This method uses the build
 in login view included in the LibSpotify API
 */
- (SPLoginViewController *) getLoginScreen;

@end
