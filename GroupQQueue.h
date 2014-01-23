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
#import "GroupQQueueDelegate.h"

@interface GroupQQueue : NSObject <NSCoding>

@property (strong, nonatomic) id nowPlaying;                // The current song being played
@property (strong, nonatomic) NSMutableArray *queuedSongs;  // The queue of songs to play
@property (strong, nonatomic) NSMutableArray *previousSongs;  // A list of songs that have been previously played

@property (strong, nonatomic) id<GroupQQueueDelegate> delegate;

// Moves a song from 'position' to 'destination' in the queue. Position 0
// is the top of the queue (separate from nowPlaying). Position (queue.len)
// is the end of the queue.
- (void) moveSong: (int)position to: (int)destination;
// Adds songs to the queue
- (void) addSongs: (NSArray*) songs;
// Deletes a song from the queue
- (void) deleteSong: (int) index;
// Plays a song from the queue. This will move it to the nowPlaying slot
// and will delete the item from the queue.
- (void) playSong: (int) index;
// Adds a single song from Spotify to the queue
- (void) addSpotifySong: (SpotifyQueueItem *) song;
// Plays a previous song again
- (void) replayNow: (int) index;
// Adds a previous song to the queue so that it will be played next
- (void) replayNext: (int) index;

@end
