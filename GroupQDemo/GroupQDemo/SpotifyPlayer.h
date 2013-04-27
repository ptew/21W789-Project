//
//  SpotifyPlayer.h
//  SpotifyProofOfConcept
//
//  Created by Bradley Gross on 4/4/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLibSpotify.h"
#import "SpotifyQueueItem.h"
#import "SpotifyPlayerDelegate.h"

@interface SpotifyPlayer : SPPlaybackManager

@property (strong, nonatomic) id<SpotifyPlayerDelegate> playerDelegate;

/*
 Plays a given spotify queue item based on the given track's trackURL. This requires and
 authenticated SPSession object which is done in the SpotifyConnection Class.
 */
- (IBAction)playTrack:(SpotifyQueueItem *) songToPlay atTime: (NSTimeInterval) time;
@end
