//
//  SpotifyConnectionDelegate.h
//  GroupQDemo
//
//  Created by Bradley Gross on 4/8/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 All of the methods in this delegate deal with logging into and out of spotify.
*/
@protocol SpotifyConnectionDelegate <NSObject>
- (void)loggedInToSpotifySuccessfully;
- (void)failedToLoginToSpotifyWithError:(NSError*)error;
- (void)loggedOutOfSpotify;
@end
