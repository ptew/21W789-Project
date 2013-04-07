//
//  SpotifyQueueItem.h
//  SpotifyProofOfConcept
//
//  Created by T. S. Cobb on 4/5/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotifyQueueItem : NSObject <NSCoding>
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* artist;
@property (strong, nonatomic) NSString* album;
@property (strong, nonatomic) NSURL* trackURI;

- (SpotifyQueueItem*)initWithTitle:(NSString*)title artist:(NSString*) artist album: (NSString*) album trackURI: (NSURL*) trackURI;

- (SpotifyQueueItem*)initWithCoder: (NSCoder*)decoder;
- (SpotifyQueueItem*)init;
- (void)encodeWithCoder:(NSCoder*)encoder;
@end
