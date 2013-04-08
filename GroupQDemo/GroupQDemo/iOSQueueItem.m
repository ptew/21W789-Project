//
//  iOSQueueItem.m
//  GroupQDemo
//
//  Created by Jono Matthews on 4/8/13.
//  Copyright (c) 2013 Team Awesome. All rights reserved.
//

#import "iOSQueueItem.h"

@implementation iOSQueueItem

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.artist forKey:@"artist"];
    [aCoder encodeObject:self.album forKey:@"album"];
    [aCoder encodeObject:self.playbackDuration forKey:@"duration"];
    [aCoder encodeObject:self.persistentID forKey:@"persistentID"];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    self.title = [aDecoder decodeObjectForKey:@"title"];
    self.artist = [aDecoder decodeObjectForKey:@"artist"];
    self.album = [aDecoder decodeObjectForKey:@"album"];
    self.playbackDuration = [aDecoder decodeObjectForKey:@"duration"];
    self.persistentID = [aDecoder decodeObjectForKey:@"persistentID"];
    return self;
}

@end
