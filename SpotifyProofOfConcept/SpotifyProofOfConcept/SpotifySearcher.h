//
//  SpotifySearcher.h
//  SpotifyProofOfConcept
//
//  Created by T. S. Cobb on 4/5/13.
//  Copyright (c) 2013 Awesome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotifySearcher : NSObject

- (NSMutableArray*)searchByArtist:(NSString*)artist;
- (NSMutableArray*)searchByTrack:(NSString*)track;
- (NSMutableArray*)searchByAlbum:(NSString*)album;

@end
