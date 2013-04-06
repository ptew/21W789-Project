//
//  SpotifyConnection.h
//  SpotifyProofOfConcept
//
//  Created by T. S. Cobb on 4/4/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLibSpotify.h>

@interface SpotifyConnection : NSObject <SPSessionDelegate>

@property (weak, nonatomic) UIViewController *parent;
@property (strong, nonatomic) SPPlaybackManager* player;

- (SpotifyConnection *) initWithParent: (UIViewController *) who;

- (void) connect;
- (SPLoginViewController *) getLoginScreen;

@end
