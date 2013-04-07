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
        self.nowPlaying = [aDecoder decodeObjectForKey:@"queuedSongs"];
    }
}
@end
