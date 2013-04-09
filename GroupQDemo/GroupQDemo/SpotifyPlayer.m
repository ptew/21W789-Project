//
//  SpotifyPlayer.m
//  SpotifyProofOfConcept
//
//  Created by Bradley Gross on 4/4/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import "SpotifyPlayer.h"

@interface SpotifyPlayer () {
// Private member variables (NOT PROPERTIES)
}

@end

@implementation SpotifyPlayer
- (SpotifyPlayer *)init{
    self = [super initWithPlaybackSession:[SPSession sharedSession]];
    return self;
}
- (void)playTrack:(SpotifyQueueItem *) songToPlay atTime:(NSTimeInterval)time{
    NSURL *trackURL = songToPlay.trackURI;
    
    //checks if there are no songs in the track queue.
    if ([[SPSession sharedSession] connectionState] == SP_CONNECTION_STATE_LOGGED_OUT){
        NSLog(@"Not logged into spotify");
    }
    
    [[SPSession sharedSession] trackForURL:trackURL callback:^(SPTrack *track){
        if(track != nil){
            [SPAsyncLoading waitUntilLoaded:track timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray * tracks, NSArray *notLoadedTracks){
                NSLog(@"Track loaded");
                [self playTrack:track callback:^(NSError *error){
                    NSLog(@"Track trying to play");
                    if(error){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Track"
                                                                        message:[error localizedDescription]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                    } else{
                        [self seekToTrackPosition:time];
                        [self.playerDelegate songDidStartPlaying];
                    }
                }];
            }];
        }
    }];
    return;
}

+ (SpotifyPlayer *) sharedPlayer {
    static SpotifyPlayer *sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlayer = [[SpotifyPlayer alloc] init];
    });
    return sharedPlayer;
}

#pragma mark SpotifyPlayer Delegate method

- (void) sessionDidEndPlayback:(id<SPSessionPlaybackProvider>)aSession {
    [self.playerDelegate songDidStopPlaying];
}
@end
