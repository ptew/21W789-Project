//
//  SpotifyQueueItem.h
//  SpotifyProofOfConcept
//
//  Created by Bradley Gross on 4/5/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotifyQueueItem : NSObject <NSCoding>

//All of the track properties
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* artist;
@property (strong, nonatomic) NSString* album;
@property (strong, nonatomic) NSURL* trackURI;
//length refers to the length in seconds of the song with double acuracy.
@property double length;


- (SpotifyQueueItem*)initWithTitle:(NSString*)title artist:(NSString*) artist album: (NSString*) album trackURI: (NSURL*) trackURI length: (double) length;

#pragma mark NSCoding Constructor and methods
- (void)encodeWithCoder:(NSCoder*)encoder;

- (SpotifyQueueItem*)initWithCoder: (NSCoder*)decoder;

@end
