//
//  GroupQQueue.m
//  GroupQDemo
//
//  Created by Jono Matthews on 4/7/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "GroupQQueue.h"

@implementation GroupQQueue

#pragma mark - Initialization and encoding/decoding

- (GroupQQueue*) init {
    self = [super init];
    self.nowPlaying = nil;
    self.queuedSongs = [[NSMutableArray alloc] init];
    self.previousSongs = [[NSMutableArray alloc] init];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.nowPlaying forKey:@"nowPlaying"];
    [aCoder encodeObject:self.queuedSongs forKey:@"queuedSongs"];
    [aCoder encodeObject:self.previousSongs forKey:@"previousSongs"];
}

- (GroupQQueue*) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.nowPlaying = [aDecoder decodeObjectForKey:@"nowPlaying"];
        self.queuedSongs = [aDecoder decodeObjectForKey:@"queuedSongs"];
        self.previousSongs = [aDecoder decodeObjectForKey:@"previousSongs"];
    }
    return self;
}


#pragma mark - Queue management

- (void) moveSong: (int)position to: (int)destination {
    if (position == destination)
        return;
    
    if(position >= self.queuedSongs.count || destination >= self.queuedSongs.count)
        return;
    
    id songToMove = [self.queuedSongs objectAtIndex:position];
    
    if (position > destination) {
        [self.queuedSongs insertObject:songToMove atIndex:destination];
        [self.queuedSongs removeObjectAtIndex:position+1];
    }
    else {
        [self.queuedSongs insertObject:songToMove atIndex:destination+1];
        [self.queuedSongs removeObjectAtIndex:position];
    }
    [self.delegate queueDidChange];
}

- (void) addSongs: (NSArray*) songs; {
    [self.queuedSongs addObjectsFromArray:songs];
    [self.delegate queueDidChange];
}

- (void) deleteSong: (int) index {
    if(index >= self.queuedSongs.count)
        return;
    
    [self.queuedSongs removeObjectAtIndex:index];
    [self.delegate queueDidChange];
}

- (void) playSong: (int) index {
    if(index >= self.queuedSongs.count) {
        return;
    }
    
    if (self.nowPlaying) {
        [self.previousSongs addObject:self.nowPlaying];
    }
    self.nowPlaying = [self.queuedSongs objectAtIndex:index];
    [self deleteSong:index];
}

- (void) addSpotifySong: (SpotifyQueueItem *) song {
    [self.queuedSongs addObject:song];
    [self.delegate queueDidChange];
}


- (void) replayNow: (int) index {
    [self.queuedSongs addObject:[self.previousSongs objectAtIndex:index]];
    [self playSong:([self.queuedSongs count] - 1)];
}


- (void) replayNext: (int) index {
    [self.queuedSongs addObject:[self.previousSongs objectAtIndex:index]];
    [self moveSong:([self.queuedSongs count] - 1) to:0];
}

@end
