//
//  SpotifyQueueItem.m
//  SpotifyProofOfConcept
//
//  Created by T. S. Cobb on 4/5/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import "SpotifyQueueItem.h"

@implementation SpotifyQueueItem

- (SpotifyQueueItem*) initWithTitle:(NSString *)title artist:(NSString *)artist album:(NSString *)album trackURI:(NSURL *)trackURI {
    self.title = title;
    self.artist = artist;
    self.album = album;
    self.trackURI = trackURI;
}
@end
