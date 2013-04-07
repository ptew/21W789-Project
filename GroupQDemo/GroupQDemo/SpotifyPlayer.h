//
//  SpotifyPlayer.h
//  SpotifyProofOfConcept
//
//  Created by T. S. Cobb on 4/4/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLibSpotify.h"
#import "SpotifyQueueItem.h"
#import "SpotifyPlayerDelegate.h"

@interface SpotifyPlayer : SPPlaybackManager {
    // Public member variables (NOT PROPERTIES)
}

@property (strong, nonatomic) id<SpotifyPlayerDelegate> playerDelegate;

- (IBAction)playTrack:(SpotifyQueueItem *) trackURL;

+ (SpotifyPlayer *) sharedPlayer;
@end
