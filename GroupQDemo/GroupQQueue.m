//
//  GroupQQueue.m
//  GroupQDemo
//
//  Created by Jono Matthews on 4/7/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "GroupQQueue.h"

@implementation GroupQQueue
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.nowPlaying forKey:@"nowPlaying"];
    [aCoder encodeObject:self.queuedSongs forKey:@"queuedSongs"];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.nowPlaying = [aDecoder decodeObjectForKey:@"nowPlaying"];
        self.queuedSongs = [aDecoder decodeObjectForKey:@"queuedSongs"];
    }
    return self;
}

- (void) moveSong: (int)position to: (int)destination {
    if (position == destination)
        return;
    
    id songToMove = [self.queuedSongs objectAtIndex:position];
    if (position > destination) {
        [self.queuedSongs insertObject:songToMove atIndex:destination];
        [self.queuedSongs removeObjectAtIndex:position+1];
    }
    else {
        [self.queuedSongs insertObject:songToMove atIndex:destination];
        [self.queuedSongs removeObjectAtIndex:position];
    }
}
- (void) addSongs: (MPMediaItemCollection*) songs; {
    [self.queuedSongs addObjectsFromArray:songs.items];
}
- (void) deleteSong: (int) index {
    [self.queuedSongs removeObjectAtIndex:index];
};
- (void) playSong: (int) index {
    self.nowPlaying = [self.queuedSongs objectAtIndex:index];
    [self deleteSong:index];
}
- (void) addSpotifySong: (SpotifyQueueItem *) song {
    [self.queuedSongs addObject:song];
}

@end
