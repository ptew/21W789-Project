//
//  SpotifyQueueItem.m
//  SpotifyProofOfConcept
//
//  Created by T. S. Cobb on 4/5/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import "SpotifyQueueItem.h"

@implementation SpotifyQueueItem

- (SpotifyQueueItem*) initWithTitle:(NSString *)title artist:(NSString *)artist album:(NSString *)album trackURI:(NSURL *)trackURI length:(double) length{
    self.title = title;
    self.artist = artist;
    self.album = album;
    self.trackURI = trackURI;
    self.length = length;
    return self;
}

- (SpotifyQueueItem*) init{
    return self;
}

- (SpotifyQueueItem*)initWithCoder:(NSCoder *)decoder{
    self.title = [decoder decodeObjectForKey:@"title"];
    self.artist = [decoder decodeObjectForKey:@"artist"];
    self.album =   [decoder decodeObjectForKey:@"album"];
    self.trackURI = [decoder decodeObjectForKey:@"trackURI"];
    self.length = [decoder decodeDoubleForKey:@"length"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.artist forKey:@"artist"];
    [encoder encodeObject:self.album forKey:@"album"];
    [encoder encodeObject:self.trackURI forKey:@"trackURI"];
    [encoder encodeDouble:self.length forKey:@"length"];
}
@end
