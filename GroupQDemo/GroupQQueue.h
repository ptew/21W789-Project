//
//  GroupQQueue.h
//  GroupQDemo
//
//  Created by Jono Matthews on 4/7/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Spotify.h"

@interface GroupQQueue : NSObject <NSCoding>
@property (strong, nonatomic) id nowPlaying;
@property (strong, nonatomic) NSMutableArray *queuedSongs;

- (void) moveSong: (int)position to: (int)destination;
- (void) addSongs: (NSArray*) songs;
- (void) deleteSong: (int) index;
- (void) playSong: (int) index;
- (void) addSpotifySong: (SpotifyQueueItem *) song;

@end
