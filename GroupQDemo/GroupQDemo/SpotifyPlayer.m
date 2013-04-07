//
//  SpotifyPlayer.m
//  SpotifyProofOfConcept
//
//  Created by T. S. Cobb on 4/4/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import "SpotifyPlayer.h"

@interface SpotifyPlayer () {
// Private member variables (NOT PROPERTIES)
}

// Private functions and properties
@property (strong, nonatomic) SPTrack *currentTrack;
@property (strong, nonatomic) SPPlaybackManager* playbackManager;

@end

@implementation SpotifyPlayer
- (SpotifyPlayer *)init{
    self = [super init];
    self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
    return self;
}
- (void)playTrack:(NSURL*) trackURL{
    //checks if there are no songs in the track queue.
    if ([[SPSession sharedSession] connectionState] == SP_CONNECTION_STATE_LOGGED_OUT){
        NSLog(@"Not logged into spotify");
    }
    
    //NSURL *testTrackURL;
    //testTrackURL = [[NSURL alloc] initWithString:(@"spotify:track:4go2hxLM6ijk0K76ZY0Nhd")];
    
    [[SPSession sharedSession] trackForURL:trackURL callback:^(SPTrack *track){
        if(track != nil){
            [SPAsyncLoading waitUntilLoaded:track timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray * tracks, NSArray *notLoadedTracks){
                NSLog(@"Track loaded");
                [self.playbackManager playTrack:track callback:^(NSError *error){
                    NSLog(@"Track trying to play");
                    if(error){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Track"
                                                                        message:[error localizedDescription]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                        [alert show];
                    } else{
                        NSLog(@"Track played?");
                        self.currentTrack = track;
                    }
                }];
            }];
        }
    }];
    return;
}
@end
