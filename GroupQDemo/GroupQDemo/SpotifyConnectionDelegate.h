//
//  SpotifyConnectionDelegate.h
//  GroupQDemo
//
//  Created by T. S. Cobb on 4/8/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spotify.h"

@protocol SpotifyConnectionDelegate <NSObject>
- (void)loggedInToSpotifySuccessfully;
- (void)failedToLoginToSpotifyWithError:(NSError*)error;
- (void)loggedOutOfSpotify;
@end
