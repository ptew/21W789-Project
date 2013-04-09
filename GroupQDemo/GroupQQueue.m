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
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.nowPlaying forKey:@"nowPlaying"];
    [aCoder encodeObject:self.queuedSongs forKey:@"queuedSongs"];
}

- (GroupQQueue*) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.nowPlaying = [aDecoder decodeObjectForKey:@"nowPlaying"];
        self.queuedSongs = [aDecoder decodeObjectForKey:@"queuedSongs"];
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
        [self.queuedSongs insertObject:songToMove atIndex:destination];
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
        self.nowPlaying = nil;
        [self.delegate queueDidChange];
        return;
    }
    self.nowPlaying = [self.queuedSongs objectAtIndex:index];
    [self deleteSong:index];
}

- (void) addSpotifySong: (SpotifyQueueItem *) song {
    [self.queuedSongs addObject:song];
    [self.delegate queueDidChange];
}

@end
